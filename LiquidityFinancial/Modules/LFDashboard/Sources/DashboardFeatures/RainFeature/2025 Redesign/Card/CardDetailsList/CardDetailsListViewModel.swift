import AccountData
import BaseOnboarding
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import MeaPushProvisioning
import OnboardingData
import PassKit
import RainData
import RainDomain
import Services
import SwiftUI

@MainActor
public final class CardDetailsListViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rainCardRepository) var rainCardRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.rainService) var rainService

  lazy var lockCardUseCase: RainLockCardUseCaseProtocol = {
    RainLockCardUseCase(repository: rainCardRepository)
  }()
  
  lazy var unLockCardUseCase: RainUnlockCardUseCaseProtocol = {
    RainUnlockCardUseCase(repository: rainCardRepository)
  }()
  
  lazy var closeCardUseCase: RainCloseCardUseCaseProtocol = {
    RainCloseCardUseCase(repository: rainCardRepository)
  }()
  
  lazy var cancelCardOrderUseCase: RainCancelCardOrderUseCaseProtocol = {
    RainCancelCardOrderUseCase(repository: rainCardRepository)
  }()
  
  lazy var getCardsUseCase: RainGetCardsUseCaseProtocol = {
    RainGetCardsUseCase(repository: rainCardRepository)
  }()
  
  lazy var getCardDetailUseCase: RainGetCardDetailUseCaseProtocol = {
    RainGetCardDetailUseCase(repository: rainCardRepository)
  }()
  
  lazy var getCardOrdersUseCase: RainGetCardOrdersUseCaseProtocol = {
    RainGetCardOrdersUseCase(repository: rainCardRepository)
  }()
  
  lazy var getSecretCardInformationUseCase: RainSecretCardInformationUseCaseProtocol = {
    RainSecretCardInformationUseCase(repository: rainCardRepository)
  }()
  
  lazy var createCardUseCase: RainCreateVirtualCardUseCaseProtocol = {
    RainCreateVirtualCardUseCase(repository: rainCardRepository)
  }()
  
  @Published var isInit: Bool = false
  @Published var isLoading: Bool = false
  @Published var isShowCardNumber: Bool = false
  @Published var isCardLocked: Bool = false
  @Published var isShowListCardDropdown: Bool = false
  @Published var shouldShowAddToWalletButton: [String: Bool] = [:]
  @Published var toastData: ToastData?
  @Published var isShowingShippingInProgress: Bool = false
  @Published var isShowingShippingPost30Days: Bool = false
  @Published var cardsList: [CardModel] = []
  @Published var allVirtualCards: [CardModel] = []
  @Published var currentCard: CardModel = .virtualDefault {
    didSet {
      if currentCardId != currentCard.id {
        currentCardId = currentCard.id
      }
    }
  }
  
  @Published var currentCardId: String = .empty {
    didSet {
      if let newCard = cardsList.first(where: { $0.id == currentCardId }), currentCard != newCard {
        currentCard = newCard
      }
    }
  }
  @Published var cardDetail: CardDetail?
  @Published var navigation: Navigation?
  @Published var sheet: Sheet?
  @Published var popup: ListCardPopup?
  
  var isSwitchCard = true
  private var subscribers: Set<AnyCancellable> = []
  
  var tokenizationResponseData: [String: MppInitializeOemTokenizationResponseData?] = [:]
  var requestConfiguration: [String: PKAddPaymentPassRequestConfiguration?] = [:]
  
  private var virtualCardCount: Int = 0
  
  var remainingVirtualCardCount: Int {
    Constants.virtualCardCountLimit - virtualCardCount
  }
  
  var isFinalVirtualCard: Bool {
    remainingVirtualCardCount <= 0
  }
  
  var isPhysicalCardOrderAvailable: Bool = false
  
  var isShowingCloseCard: Bool {
    (currentCard.cardStatus == .active || currentCard.cardStatus == .disabled)
    && cardsList.isNotEmpty
  }
  
  var isShowingShowCardNumber: Bool {
    currentCard.cardType != .physical
    && currentCard.cardStatus == .active
    && cardsList.isNotEmpty
  }
  
  var isShowingLockCard: Bool {
    (currentCard.cardStatus == .active || currentCard.cardStatus == .disabled)
    && cardsList.isNotEmpty
  }
  
  var shouldShowDisabledCardsButton: Bool {
    allVirtualCards.filter { $0.cardStatus == .closed }.isNotEmpty && currentCard.cardType != .physical
  }
  
  var isShowingShippingDetails: Bool {
    currentCard.cardType == .physical
    && ((currentCard.cardStatus == .unactivated && cardDetail?.shippingAddress != nil) || currentCard.cardStatus == .pending)
  }
  
  var isShowingActivatePhysicalCard: Bool {
    currentCard.cardType == .physical
    && currentCard.cardStatus == .unactivated
  }
  
  var isShowingCancelOrder: Bool {
    currentCard.cardType == .physical
    && currentCard.cardStatus == .pending
  }
  
  var isShowingShippingDetailPost30Days: Bool {
    guard
      let createdAt = cardDetail?.shippingAddress?.createdAtDate
    else { return false }
    
    return currentCard.cardType == .physical
    && currentCard.cardStatus == .unactivated
    && Date().timeIntervalSince(createdAt) > 30 * 24 * 60 * 60 // 30 days
  }
  
  var isShowingCanceledCardOrder: Bool {
    currentCard.cardType == .physical
    && currentCard.cardStatus == .rejected
  }
  
  var cardholderName: String {
    if let firstName = accountDataManager.userInfomationData.firstName,
       let lastName = accountDataManager.userInfomationData.lastName {
      
      return firstName + " " + lastName
    }
    
    return accountDataManager.userInfomationData.fullName ?? ""
  }
  
  // Check if a card with FRNT experience was created for the user
  public var hasFrntCard: Bool {
    // Check cached value while the cards are loading to avoid unneeded flicker
    if cardsList.isEmpty {
      return accountDataManager.hasFrntCard
    }
    
    return cardsList
      .contains { card in
        card.tokenExperiences?.contains("FRNT") == true
      }
  }
  
  public init() {
    fetchRainCards()
    observeRefreshListCards()
  }
}

// MARK: Observable
extension CardDetailsListViewModel {
  func observeRefreshListCards() {
    NotificationCenter.default.publisher(for: .refreshListCards)
      .sink { [weak self] _ in
        guard let self else { return }
        fetchRainCards()
      }
      .store(in: &subscribers)
  }
}

// MARK: Handle Interactions
extension CardDetailsListViewModel {
  func onDisappear() {
    NotificationCenter.default.post(name: .refreshListCards, object: nil)
  }
  
  func activePhysicalSuccess(id: String) {
    cardDetail = nil
    
    guard id == currentCard.id, let index = cardsList.firstIndex(where: { $0.id == id
    }) else { return }
    isSwitchCard = false
    
    // Replace the entire card object to trigger UI update
    var updatedCurrentCard = currentCard
    updatedCurrentCard.cardStatus = .active
    currentCard = updatedCurrentCard
    
    var updatedCard = cardsList[index]
    updatedCard.cardStatus = .active
    cardsList[index] = updatedCard
  }
  
  func onShippingDetailsTap() {
    var currentCardDetail: CardDetail? = cardDetail
    
    if currentCard.cardStatus == .pending,
       let shippingAddress = currentCard.shippingAddress {
      currentCardDetail = CardDetail(cardId: currentCard.id, shippingAddress: shippingAddress)
    }
    
    guard let currentCardDetail
    else {
      return
    }
    
    navigation = .shippingDetails(cardDetail: currentCardDetail)
  }
  
  func onLockCardToggle() {
    if currentCard.cardStatus == .active && isCardLocked {
      analyticsService.track(event: AnalyticsEvent(name: .tapsLockCard))
      callLockCardAPI()
    } else if currentCard.cardStatus == .disabled && !isCardLocked {
      analyticsService.track(event: AnalyticsEvent(name: .tapsUnlockCard))
      callUnLockCardAPI()
    }
  }
  
  func onCurrentCardChange() {
    isCardLocked = currentCard.cardStatus == .disabled
    
    if isSwitchCard {
      isShowCardNumber = false
    } else {
      isSwitchCard = true
    }
  }
  
  func onCardItemTap(card: CardModel) {
    guard let tappedIndex = cardsList.firstIndex(where: { $0.id == card.id }) else {
      return
    }
    
    // Use a smoother animation
    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
      cardsList.remove(at: tappedIndex)
      cardsList.append(card)
      currentCard = card
      isShowCardNumber = false
    }
  }
  
  @MainActor
  func onOrderPhysicalCardTap() {
    let viewModel = ShippingAddressEntryViewModel { card in
      self.orderPhysicalSuccess(card: card)
    }
    let destinationView = ShippingAddressEntryView(viewModel: viewModel)
    navigation = .orderPhysicalCard(AnyView(destinationView))
  }
  
  func onRequestANewVirtualCardTap() {
    popup = .confirmCreateNewCard
  }
  
  func onCloseCardTap() {
    popup = .confirmCloseCard
  }
  
  func onCancelCardOrderTap() {
    popup = .confirmCardOrderCancel
  }
  
  func onViewCreditLimitBreakdownTap() {
    navigation = .creditLimitBreakdown
  }
  
  func hidePopup() {
    popup = nil
  }
  
  func showCardClosedSuccessfullyMessage() {
    toastData = .init(type: .success, title: "Your virtual card has been successfully disabled and closed. Order a new card today to start spending!")
  }
  
  func cardClosedSuccessAction() {
    hidePopup()
    updateListCard(id: currentCard.id, completion: {})
  }
  
  func navigateActivateCardView() {
    switch currentCard.cardType {
    case .physical:
      navigation = .activatePhysicalCard
    default:
      break
    }
  }
  
  func orderPhysicalSuccess(card: CardModel) {
    cardsList.removeAll(where: { $0.cardStatus == .canceled })
    cardsList.append(card)
    currentCard = card
    isShowCardNumber = false
    navigation = nil
    popup = .cardOrderSuccessfully
    isShowingShippingInProgress = true
  }
  
  func updateCardStatus(status: CardStatus, id: String) {
    isLoading = false
    
    guard id == currentCard.id, let index = cardsList.firstIndex(where: { $0.id == id }) else {
      return
    }
    isSwitchCard = false
    
    // Replace the entire card object to trigger UI update
    var updatedCurrentCard = currentCard
    updatedCurrentCard.cardStatus = status
    currentCard = updatedCurrentCard
    
    var updatedCard = cardsList[index]
    updatedCard.cardStatus = status
    cardsList[index] = updatedCard
  }
  
  func updateListCard(id: String, completion: @escaping () -> Void) {
    isLoading = false
    guard let index = cardsList.firstIndex(where: { $0.id == id }) else {
      return
    }
    
    let _ = cardsList.remove(at: index)
    if let card = cardsList.last {
      currentCard = card
    } else {
      NotificationCenter.default.post(name: .noLinkedCards, object: nil)
      completion()
    }
  }
}

// MARK: - API
extension CardDetailsListViewModel {
  func callLockCardAPI() {
    isLoading = true
    Task {
      do {
        let card = try await lockCardUseCase.execute(cardID: currentCard.id)
        updateCardStatus(status: .disabled, id: card.cardId ?? currentCard.id)
      } catch {
        isCardLocked = false
        isLoading = false
        toastData = .init(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
  
  func callUnLockCardAPI() {
    isLoading = true
    Task {
      do {
        let card = try await unLockCardUseCase.execute(cardID: currentCard.id)
        updateCardStatus(status: .active, id: card.cardId ?? currentCard.id)
      } catch {
        isCardLocked = true
        isLoading = false
        toastData = .init(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
  
  func closeCard(
    with type: CardType
  ) {
    Task {
      defer {
        isLoading = false
      }
      
      hidePopup()
      isLoading = true
      
      do {
        _ = try await closeCardUseCase.execute(cardID: currentCard.id)
        updateListCard(id: currentCard.id, completion: {})
        
        popup = type == .virtual ? .closeVirtualCardSuccessfully : .closePhysicalCardSuccessfully
      } catch {
        log.error(error.userFriendlyMessage)
        toastData = .init(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
  
  func cancelCardOrder(
    shouldTakeToNewCardOrder: Bool = false
  ) {
    Task {
      defer {
        isLoading = false
      }
      
      hidePopup()
      isLoading = true
      
      do {
        _ = try await cancelCardOrderUseCase.execute(cardID: currentCard.id)
        
        if shouldTakeToNewCardOrder {
          onOrderPhysicalCardTap()
        } else {
          popup = .cardOrderCanceledSuccessfully
        }
      } catch {
        log.error(error.userFriendlyMessage)
        toastData = .init(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
  
  func createNewCard() {
    Task {
      popup = nil
      
      defer { isLoading = false }
      isLoading = true
      
      do {
        
        _ = try await createCardUseCase.execute()
        NotificationCenter.default.post(name: .createdCard, object: nil)
        fetchRainCards(withLoader: false)
        analyticsService.track(event: AnalyticsEvent(name: .createCardSuccess))
        toastData = .init(type: .success, title: "A new virtual card has been successfully added to your account. Add to Apple Wallet and start using it today!")
      } catch {
        toastData = .init(type: .error, title: error.userFriendlyMessage)
        analyticsService.track(event: AnalyticsEvent(name: .createCardError))
      }
    }
  }
  
  func fetchRainCards(
    withLoader: Bool = true
  ) {
    Task {
      defer {
        isLoading = false
      }
      
      if withLoader {
        isInit = true
      } else {
        isLoading = true
      }
      
      do {
        let cards = try await getCardsUseCase.execute()
        let cardOrders = try await getCardOrdersUseCase.execute()
          .map { order in
            CardModel(order: order)
          }
        
        var newCards: [CardModel] = []
        // Map card orders to card model
        newCards = cardOrders
          .filter { card in
            card.cardStatus == .pending
          }
        
        // Add created cards to the list
        newCards += cards.map { card in
          CardModel(card: card)
        }
        // Saving the number of all virtual cards (active and closed)
        virtualCardCount = newCards.filter { $0.cardType == .virtual }.count
        // Storing all virtual cards to show in the disabled virtual cards scren
        allVirtualCards = newCards.filter({ $0.cardType == .virtual })
        // Checking if the user has ordered a physical card before
        isPhysicalCardOrderAvailable = newCards.filter { $0.cardType == .physical }.isEmpty
        
        if withLoader {
          cardsList = newCards
            .filter { $0.cardStatus != .closed }
            .sorted { a, b in
              a.cardType != .virtual && b.cardType == .virtual
            }
        } else {
          // Remove previously fetched card orders if they are no longer pending
          cardsList.removeAll { oldCard in
            newCards.first(where: { newCard in newCard.id == oldCard.id }) == nil
          }
          // Update or insert but preserve order
          for newCard in newCards {
            if let index = cardsList.firstIndex(where: { $0.id == newCard.id }) {
              cardsList[index] = newCard
            } else {
              cardsList.append(newCard) // keep order
            }
          }
          
          cardsList = cardsList.filter { $0.cardStatus != .closed }
        }
        
        // Add temp card to show canceled state
        if let canceledOrderCard = checkCanceledCardStatus(allCards: newCards, orders: cardOrders) {
          cardsList.append(canceledOrderCard)
        }
        
        // Cache the value for frnt card available
        accountDataManager.hasFrntCard = cardsList
          .contains { card in
            card.tokenExperiences?.contains("FRNT") == true
          }
        
        // Check if the previously selected card is still in the list and keep it selected, otherwise, select the last one in the list, the list view is display the last on top
        currentCard = cardsList.last
        ?? .virtualDefault
        
        isCardLocked = currentCard.cardStatus == .disabled
        
        if cardsList.filter({ card in card.cardStatus != .pending }).isEmpty {
          isInit = false
          
          NotificationCenter.default.post(name: .noLinkedCards, object: nil)
        } else {
          cardsList
            .enumerated()
            .forEach { index, card in
              guard card.cardStatus != .closed && card.cardStatus != .pending
              else {
                return
              }
              
              fetchSecretCardInformation(cardId: card.id)
              fetchCardShippingDetail(cardId: card.id)
            }
        }
      } catch {
        isInit = false
        log.error(error.userFriendlyMessage)
        toastData = .init(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
  
  private func checkCanceledCardStatus(allCards: [CardModel], orders: [CardModel]) -> CardModel? {
    // Have active physical
    if self.cardsList.contains(where: { $0.cardType == .physical }) {
      return nil
    }
    
    // Latest canceled order if any
    let rejectedOrder = orders
      .filter { card in
        card.cardStatus == .rejected
      }
      .sorted { $0.updatedAtDate ?? .distantPast > $1.updatedAtDate ?? .distantPast }
      .first
    
    // Dont have canceled order
    guard let rejectedOrder else {
      return nil
    }
    
    // Latest closed/canceled physical card if any
    let latestCanceledPhysicalCard = allCards
      .filter({ $0.cardType == .physical && ($0.cardStatus == .canceled || $0.cardStatus == .closed) })
      .sorted { $0.updatedAtDate ?? .distantPast > $1.updatedAtDate ?? .distantPast }
      .first
    
    // Dont have physical card before
    guard let latestCanceledPhysicalCard else {
      return rejectedOrder
    }
    
    let isNewerCanceledOrder = latestCanceledPhysicalCard.updatedAtDate ?? .distantPast < rejectedOrder.updatedAtDate ?? .distantPast
    return isNewerCanceledOrder ? rejectedOrder : nil
  }
  
  private func fetchCardShippingDetail(
    cardId: String
  ) {
    Task {
      guard let card = cardsList.first(where: { $0.id == cardId }),
            card.cardStatus == .unactivated,
            card.cardType == .physical
      else {
        return
      }
      
      do {
        let detail = try await getCardDetailUseCase.execute(cardID: cardId)
        cardDetail = CardDetail(entity: detail)
        isShowingShippingPost30Days = true
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  private func fetchSecretCardInformation(
    cardId: String
  ) {
    Task {
      defer { isInit = false }
      
      guard let card = cardsList.first(where: { $0.id == cardId }),
            card.cardStatus == .active
      else {
        return
      }
      
      do {
        let sessionID = rainService.generateSessionId()
        let secretInformation = try await getSecretCardInformationUseCase.execute(sessionID: sessionID, cardID: card.id)
        
        let pan = rainService.decryptData(
          ivBase64: secretInformation.encryptedPanEntity.iv,
          dataBase64: secretInformation.encryptedPanEntity.data
        )
        let cvv = rainService.decryptData(
          ivBase64: secretInformation.encryptedCVCEntity.iv,
          dataBase64: secretInformation.encryptedCVCEntity.data
        )
        
        let cardMetaData = CardMetaData(
          pan: pan,
          cvv: cvv,
          processorCardId: secretInformation.processorCardId,
          timeBasedSecret: secretInformation.timeBasedSecret
        )
        
        if let index = cardsList.firstIndex(of: card) {
          cardsList[index].metadata = cardMetaData
          loadTokenizationResponseData(cardId: cardId)
        }
      } catch {
        log.error(error.userFriendlyMessage)
        toastData = .init(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
  
  private func loadTokenizationResponseData(
    cardId: String
  ) {
    guard let card = cardsList.first(where: { $0.id == cardId }),
          let cardMetadata = card.metadata
    else {
      return
    }
    
    let mppCardParameters = MppCardDataParameters(
      cardId: cardMetadata.processorCardId,
      cardSecret: cardMetadata.timeBasedSecret
    )
    
    let isPassLibraryAvailable = PKPassLibrary.isPassLibraryAvailable()
    let canAddPaymentPass = PKAddPaymentPassViewController.canAddPaymentPass()
    
    if (isPassLibraryAvailable && canAddPaymentPass) {
      MeaPushProvisioning.initializeOemTokenization(mppCardParameters) { (responseData, error) in
        
        if let responseData,
           responseData.isValid() {
          var canAddPaymentPassWithPAI = true
          self.shouldShowAddToWalletButton[cardId] = false
          
          if let primaryAccountIdentifier = responseData.primaryAccountIdentifier,
             !primaryAccountIdentifier.isEmpty {
            if #available(iOS 13.4, *) {
              canAddPaymentPassWithPAI = MeaPushProvisioning.canAddSecureElementPass(withPrimaryAccountIdentifier: primaryAccountIdentifier)
            } else {
              canAddPaymentPassWithPAI = MeaPushProvisioning.canAddPaymentPass(withPrimaryAccountIdentifier: primaryAccountIdentifier)
            }
          }
          
          if (canAddPaymentPassWithPAI) {
            self.tokenizationResponseData[card.id] = responseData
            
            self.requestConfiguration[card.id] = self.tokenizationResponseData[card.id]??.addPaymentPassRequestConfiguration
            self.requestConfiguration[card.id]??.cardholderName = self.cardholderName
            
            self.shouldShowAddToWalletButton[cardId] = true
          } else {
            self.shouldShowAddToWalletButton[cardId] = false
          }
        }
      }
    }
  }
  
  func completeTokenization(
    certificates: [Data],
    nonce: Data,
    nonceSignature: Data
  ) async throws -> PKAddPaymentPassRequest? {
    guard let tokenizationResponseData = tokenizationResponseData[currentCard.id],
          let tokenizationReceipt = tokenizationResponseData?.tokenizationReceipt
    else {
      return nil
    }
    
    let tokenizationData = MppCompleteOemTokenizationData(
      tokenizationReceipt: tokenizationReceipt,
      certificates: certificates,
      nonce: nonce,
      nonceSignature: nonceSignature
    )
    
    let responseData = try await MeaPushProvisioning.completeOemTokenization(tokenizationData)
    if responseData.isValid() {
      return responseData.addPaymentPassRequest
    }
    
    return nil
  }
}

// MARK: - View Helpers
extension CardDetailsListViewModel {
  func title(for card: CardModel) -> (title: String, lastFour: String) {
    switch card.cardType {
    case .virtual:
      return (title: L10N.Common.Card.Virtual.title + " " + L10N.Common.Card.Generic.title  + " ", lastFour: card.last4)
    case .physical:
      let panLast4 = card.cardStatus == .active ? card.last4 : "****"
      return (title: L10N.Common.Card.Physical.title + " " + L10N.Common.Card.Generic.title + " ", lastFour: panLast4)
    }
  }
}

// MARK: - Enums
extension CardDetailsListViewModel {
  enum Navigation {
    case orderPhysicalCard(AnyView)
    case creditLimitBreakdown
    case disabledCardList
    case activatePhysicalCard
    case shippingDetails(cardDetail: CardDetail)
  }
  
  enum Sheet: Identifiable {
    case applePay(AnyView)
    
    public var id: String {
      switch self {
      case .applePay:
        return "applePay"
      }
    }
  }
  
  enum ListCardPopup: Identifiable {
    var id: Self {
      self
    }
    
    case confirmCloseCard
    case closeVirtualCardSuccessfully
    case closePhysicalCardSuccessfully
    case confirmCardOrderCancel
    case cardOrderCanceledSuccessfully
    case confirmLockCard
    case confirmCreateNewCard
    case cardOrderSuccessfully
    case delayedCardOrder
  }
}
