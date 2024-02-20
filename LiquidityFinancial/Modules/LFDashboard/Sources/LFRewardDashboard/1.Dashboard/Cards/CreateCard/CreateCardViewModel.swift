import Foundation
import Factory
import SolidData
import SolidDomain
import LFUtilities
import LFLocalizable
import Combine
import Services

@MainActor
final class CreateCardViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.accountDataManager) var accountDataManager

  lazy var createVirtualCardUseCase: SolidCreateVirtualCardUseCaseProtocol = {
    SolidCreateVirtualCardUseCase(repository: solidCardRepository)
  }()
  
  @Published var isDisableButton: Bool = false
  @Published var isCreatingCard: Bool = false
  @Published var isShowCardNameDisclosure: Bool = false
  @Published var cardName: String = .empty
  @Published var inlineErrorMessage: String?
  
  private var subscribers: Set<AnyCancellable> = []

  init() {
    observeCardName()
  }
}

// MARK: - API Handler
extension CreateCardViewModel {
  func createCardAPI() {
    Task {
      isCreatingCard = true
      
      do {
        // TODO: MinhNguyen - Call the new create card API after
        let accounts = self.accountDataManager.fiatAccounts
        guard let accountID = accounts.first?.id else {
          return
        }
        let card = try await createVirtualCardUseCase.execute(accountID: accountID)
        let cardModel = CardModel(
          id: card.id,
          cardName: card.name,
          cardType: CardType(rawValue: card.type) ?? .virtual,
          cardholderName: nil,
          expiryMonth: Int(card.expirationMonth) ?? 0,
          expiryYear: Int(card.expirationYear) ?? 0,
          last4: card.panLast4,
          popularBackgroundColor: nil, // TODO: MinhNguyen - Update in phase 3
          popularTextColor: nil, // TODO: MinhNguyen - Update in phase 3
          cardStatus: CardStatus(rawValue: card.cardStatus) ?? .unactivated
        )
        
        postDidCardCreateSuccessNotification(card: cardModel)
      } catch {
        isCreatingCard = false
        handleAPIError(error: error)
      }
    }
  }
}

// MARK: - View Handler
extension CreateCardViewModel {
  func onClickedCardNameInformationIcon() {
    isShowCardNameDisclosure.toggle()
  }
  
  func hideDisclosure() {
    isShowCardNameDisclosure = false
  }
}

// MARK: - Private Functions
private extension CreateCardViewModel {
  func observeCardName() {
    $cardName
      .receive(on: DispatchQueue.main)
      .sink { [weak self] cardName in
        self?.validateCardName(with: cardName)
      }
      .store(in: &subscribers)
  }
  
  func validateCardName(with name: String) {
    if name.isValid(for: .containsSpecialCharacterExceptSpace) {
      isDisableButton = true
      inlineErrorMessage = L10N.Common.Card.EditCardName.specialCharactersError
    } else {
      isDisableButton = false
      inlineErrorMessage = nil
    }
  }
  
  func handleAPIError(error: Error) {
    log.error(error.userFriendlyMessage )
    guard let errorCode = error.asErrorObject?.code else {
      inlineErrorMessage = error.userFriendlyMessage
      return
    }
    
    switch errorCode {
    case Constants.ErrorCode.cardNameConflict.value:
      inlineErrorMessage = L10N.Common.Card.EditCardName.cardNameExisted
    default:
      inlineErrorMessage = error.userFriendlyMessage
    }
  }
  
  func postDidCardCreateSuccessNotification(card: CardModel) {
    NotificationCenter.default.post(
      name: .didCardCreateSuccess,
      object: nil,
      userInfo: [Constants.UserInfoKey.card: card]
    )
  }
}
