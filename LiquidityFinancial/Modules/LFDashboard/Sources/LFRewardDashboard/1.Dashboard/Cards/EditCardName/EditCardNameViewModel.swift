import Foundation
import Factory
import SolidData
import SolidDomain
import LFUtilities
import LFLocalizable
import Combine
import Services

@MainActor
final class EditCardNameViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  lazy var updateCardNameUseCase: SolidUpdateCardNameUseCaseProtocol = {
    SolidUpdateCardNameUseCase(repository: solidCardRepository)
  }()
  
  @Published var isDisableButton: Bool = true
  @Published var isShowDisclosure: Bool = false
  @Published var isUpdatingCardName: Bool = false
  @Published var cardName: String = .empty
  @Published var inlineErrorMessage: String?
  
  private let onSuccess: (String) -> Void
  private let currentCardName: String
  private let cardID: String
  
  private var subscribers: Set<AnyCancellable> = []

  init(cardID: String, cardName: String, onSuccess: @escaping ((String) -> Void)) {
    self.currentCardName = cardName
    self.cardID = cardID
    self.cardName = cardName
    self.onSuccess = onSuccess
    observeCardName()
  }
}

// MARK: - API Handler
extension EditCardNameViewModel {
  func updateCardNameAPI(completion: @escaping (() -> Void)) {
    Task {
      defer { isUpdatingCardName = false }
      isUpdatingCardName = true
      
      do {
        let parameter = APISolidCardNameParameters(
          name: cardName.removeRedundantWhiteSpace()
        )
        let card = try await updateCardNameUseCase.execute(cardID: cardID, parameters: parameter)
        onSuccess(card.name ?? cardName)
        completion()
      } catch {
        handleAPIError(error: error)
      }
    }
  }
}

// MARK: - View Handler
extension EditCardNameViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func onClickedInformationIcon() {
    isShowDisclosure.toggle()
  }
  
  func hideDisclosure() {
    isShowDisclosure = false
  }
}

// MARK: - Private Functions
private extension EditCardNameViewModel {
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
      isDisableButton = name == currentCardName || name.trimWhitespacesAndNewlines().isEmpty
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
}
