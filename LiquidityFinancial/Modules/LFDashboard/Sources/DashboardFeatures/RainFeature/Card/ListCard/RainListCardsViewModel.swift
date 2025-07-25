import AccountData
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
public final class RainListCardsViewModel: ObservableObject {
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
  
  lazy var getCardsUseCase: RainGetCardsUseCaseProtocol = {
    RainGetCardsUseCase(repository: rainCardRepository)
  }()
  
  lazy var getSecretCardInformationUseCase: RainSecretCardInformationUseCaseProtocol = {
    RainSecretCardInformationUseCase(repository: rainCardRepository)
  }()
  
  @Published var isInit: Bool = false
  @Published var isLoading: Bool = false
  @Published var isShowCardNumber: Bool = false
  @Published var isCardLocked: Bool = false
  @Published var isActivePhysical: Bool = false
  @Published var isHasPhysicalCard: Bool = false
  @Published var isShowListCardDropdown: Bool = false
  @Published var shouldShowAddToWalletButton: [String: Bool] = [:]
  @Published var toastMessage: String?
  
  @Published var cardsList: [CardModel] = []
  @Published var currentCard: CardModel = .virtualDefault
//  {
//    didSet {
//      loadTokenizationResponseData(card: currentCard)
//    }
//  }
  @Published var navigation: Navigation?
  @Published var sheet: Sheet?
  @Published var fullScreen: FullScreen?
  @Published var popup: ListCardPopup?
  
  private var isSwitchCard = true
  private var subscribers: Set<AnyCancellable> = []
  
  var tokenizationResponseData: [String: MppInitializeOemTokenizationResponseData?] = [:]
  var requestConfiguration: [String: PKAddPaymentPassRequestConfiguration?] = [:]
  
  var activeCardCount: Int {
    cardsList.filter{ $0.cardStatus != .closed }.count
  }
  
  var cardholderName: String {
    if let firstName = accountDataManager.userInfomationData.firstName,
       let lastName = accountDataManager.userInfomationData.lastName {
      
      return firstName + " " + lastName
    }
    
    return accountDataManager.userInfomationData.fullName ?? ""
  }
  
  public init() {
    fetchRainCards()
    observeRefreshListCards()
  }
}

// MARK: - API
extension RainListCardsViewModel {
  func callLockCardAPI() {
    isLoading = true
    Task {
      do {
        let card = try await lockCardUseCase.execute(cardID: currentCard.id)
        updateCardStatus(status: .disabled, id: card.cardId ?? currentCard.id)
      } catch {
        isCardLocked = false
        isLoading = false
        toastMessage = error.userFriendlyMessage
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
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func closeCard() {
    Task {
      defer { isLoading = false }
      hidePopup()
      isLoading = true
      
      do {
        _ = try await closeCardUseCase.execute(cardID: currentCard.id)
        popup = .closeCardSuccessfully
      } catch {
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Helpers
public extension RainListCardsViewModel {
  func fetchRainCards(
    withLoader: Bool = true
  ) {
    Task {
      if withLoader {
        isInit = true
      }
      
      do {
        let cards = try await getCardsUseCase.execute()
        
        cardsList = cards
          .map { card in
            mapToCardModel(card: card)
          }
        
        isHasPhysicalCard = cardsList
          .contains { card in
            card.cardType == .physical
          }
        
        cardsList = cardsList
          .filter {
            $0.cardStatus != .closed
          }
        
        currentCard = cardsList.first ?? .virtualDefault
        isActivePhysical = currentCard.cardStatus == .active
        isCardLocked = currentCard.cardStatus == .disabled
        
        if cardsList.isEmpty {
          NotificationCenter.default.post(name: .noLinkedCards, object: nil)
        } else {
          cardsList
            .enumerated()
            .forEach { index, card in
              guard card.cardStatus != .closed
              else {
                return
              }
              
              fetchSecretCardInformation(cardId: card.id)
            }
        }
      } catch {
        isInit = false
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
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
        toastMessage = error.userFriendlyMessage
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
    
    print("START TOKENIZATION")
    
    let mppCardParameters = MppCardDataParameters(
      cardId: cardMetadata.processorCardId,
      cardSecret: cardMetadata.timeBasedSecret
    )
    
    let isPassLibraryAvailable = PKPassLibrary.isPassLibraryAvailable()
    let canAddPaymentPass = PKAddPaymentPassViewController.canAddPaymentPass()
    
    print("START TOKENIZATION: IS PASS LIBRARY AVAILABLE", isPassLibraryAvailable)
    print("START TOKENIZATION: CAN ADD PAYMENT PASS", canAddPaymentPass)
    
    if (isPassLibraryAvailable && canAddPaymentPass) {
      MeaPushProvisioning.initializeOemTokenization(mppCardParameters) { (responseData, error) in
        
        print("START TOKENIZATION: RESPONSE DATA", responseData?.primaryAccountSuffix)
        print("START TOKENIZATION: RESPONSE DATA VALID:", responseData?.isValid() ?? false)
        
        if let responseData,
           responseData.isValid() {
          print("START TOKENIZATION: GOT RESPONSE DATA")
          var canAddPaymentPassWithPAI = true
          self.shouldShowAddToWalletButton[cardId] = false
          
          print("IDENTIFIER", responseData.primaryAccountIdentifier)
          
          if let primaryAccountIdentifier = responseData.primaryAccountIdentifier,
             !primaryAccountIdentifier.isEmpty {
            if #available(iOS 13.4, *) {
              canAddPaymentPassWithPAI = MeaPushProvisioning.canAddSecureElementPass(withPrimaryAccountIdentifier: primaryAccountIdentifier)
              print("IDENTIFIER", responseData.primaryAccountIdentifier, canAddPaymentPassWithPAI)
            } else {
              canAddPaymentPassWithPAI = MeaPushProvisioning.canAddPaymentPass(withPrimaryAccountIdentifier: primaryAccountIdentifier)
            }
          }
          
          if (canAddPaymentPassWithPAI) {
            print("Got Tokenization Response for card:", cardMetadata.pan)
            
            self.tokenizationResponseData[card.id] = responseData
            
            self.requestConfiguration[card.id] = self.tokenizationResponseData[card.id]??.addPaymentPassRequestConfiguration
            self.requestConfiguration[card.id]??.cardholderName = self.cardholderName
            
            print("Payment pass request configuration description:", self.requestConfiguration[card.id]??.localizedDescription ?? "nil")
            print("Payment pass request configuration cardholder name:", self.requestConfiguration[card.id]??.cardholderName ?? "nil")
            print("Payment pass request configuration payment network:", self.requestConfiguration[card.id]??.paymentNetwork ?? "nil")
            print("Payment pass request configuration primary account identifier:", self.requestConfiguration[card.id]??.primaryAccountIdentifier ?? "nil")
            print("Payment pass request configuration primary account suffix:", self.requestConfiguration[card.id]??.primaryAccountSuffix ?? "nil")
            print("Payment pass request configuration card details:", self.requestConfiguration[card.id]??.cardDetails ?? "nil")
            
            self.shouldShowAddToWalletButton[cardId] = true
          } else {
            print("CANNOT ADD CARD")
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
extension RainListCardsViewModel {
  func title(for card: CardModel) -> (title: String, lastFour: String) {
    switch card.cardType {
    case .virtual:
      return (title: L10N.Common.Card.Virtual.title + " " + L10N.Common.Card.Generic.title  + " ", lastFour: card.last4)
    case .physical:
      let panLast4 = card.cardStatus == .active ? card.last4 : "****"
      return (title: L10N.Common.Card.Physical.title + " " + L10N.Common.Card.Generic.title + " ", lastFour: panLast4)
    }
  }
  
  func onDisappear() {
    NotificationCenter.default.post(name: .refreshListCards, object: nil)
  }
  
  func activePhysicalSuccess(id: String) {
    guard id == currentCard.id, let index = cardsList.firstIndex(where: { $0.id == id
    }) else { return }
    isSwitchCard = false
    currentCard.cardStatus = .active
    cardsList[index].cardStatus = .active
    isActivePhysical = true
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }

  func lockCardToggled() {
    if currentCard.cardStatus == .active && isCardLocked {
      analyticsService.track(event: AnalyticsEvent(name: .tapsLockCard))
      callLockCardAPI()
    } else if currentCard.cardStatus == .disabled && !isCardLocked {
      analyticsService.track(event: AnalyticsEvent(name: .tapsUnlockCard))
      callUnLockCardAPI()
    }
  }
  
  func onTapAddToApplePay() {
    guard currentCard.cardStatus == .active else {
      return
    }
    let destinationView = RainApplePayViewController(
      viewModel: RainApplePayViewModel(cardModel: currentCard)
    )
    sheet = .applePay(AnyView(destinationView))
  }
  
  func onChangeCurrentCard() {
    isActivePhysical = currentCard.cardStatus == .active
    isCardLocked = currentCard.cardStatus == .disabled
    
    if isSwitchCard {
      isShowCardNumber = false
    } else {
      isSwitchCard = true
    }
  }
  
  func onTapOrderPhysicalCard() {
    let viewModel = RainOrderPhysicalCardViewModel { card in
      self.orderPhysicalSuccess(card: card)
    }
    let destinationView = RainOrderPhysicalCardView(viewModel: viewModel)
    navigation = .orderPhysicalCard(AnyView(destinationView))
  }
  
  func onTapCloseCard() {
    popup = .confirmCloseCard
  }
  
  func onTapViewCreditLimitBreakdown() {
    navigation = .creditLimitBreakdown
  }
  
  func hidePopup() {
    popup = nil
  }
  
  func primaryActionCloseCardSuccessfully(completion: @escaping () -> Void) {
    updateListCard(id: currentCard.id, completion: completion)
    popup = nil
  }
  
  func presentActivateCardView(activeCardView: AnyView) {
    switch currentCard.cardType {
    case .physical:
      fullScreen = .activatePhysicalCard(activeCardView)
    default:
      break
    }
  }
}

// MARK: - Private Functions
private extension RainListCardsViewModel {
  func observeRefreshListCards() {
    NotificationCenter.default.publisher(for: .refreshListCards)
      .sink { [weak self] _ in
        guard let self else { return }
        fetchRainCards()
      }
      .store(in: &subscribers)
  }
  
  func orderPhysicalSuccess(card: CardModel) {
    isHasPhysicalCard = true
    cardsList.insert(card, at: 0)
    currentCard = card
  }
  
  func mapToCardModel(card: RainCardEntity) -> CardModel {
    CardModel(
      id: card.cardId ?? card.rainCardId,
      cardType: CardType(rawValue: card.cardType.lowercased()) ?? .virtual,
      cardholderName: nil,
      expiryMonth: Int(card.expMonth ?? .empty) ?? 0,
      expiryYear: Int(card.expYear ?? .empty) ?? 0,
      last4: card.last4 ?? .empty,
      cardStatus: CardStatus(rawValue: card.cardStatus.lowercased()) ?? .unactivated
    )
  }
  
  func updateCardStatus(status: CardStatus, id: String) {
    isLoading = false
    
    guard id == currentCard.id, let index = cardsList.firstIndex(where: { $0.id == id }) else {
      return
    }
    isSwitchCard = false
    currentCard.cardStatus = status
    cardsList[index].cardStatus = status
    isActivePhysical = status == .active
  }
  
  func updateListCard(id: String, completion: @escaping () -> Void) {
    isLoading = false
    guard let index = cardsList.firstIndex(where: { $0.id == id }) else {
      return
    }
    
    cardsList.remove(at: index)
    
    if let firstCard = cardsList.first {
      currentCard = firstCard
    } else {
      NotificationCenter.default.post(name: .noLinkedCards, object: nil)
      completion()
    }
  }
}
  
// MARK: - Types
extension RainListCardsViewModel {
  enum Navigation {
    case orderPhysicalCard(AnyView)
    case creditLimitBreakdown
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
  
  enum FullScreen: Identifiable {
    case activatePhysicalCard(AnyView)
    
    public var id: String {
      switch self {
      case .activatePhysicalCard:
        return "activatePhysicalCard"
      }
    }
  }
  
  enum ListCardPopup {
    case confirmCloseCard
    case closeCardSuccessfully
    case roundUpPurchases
  }
}
