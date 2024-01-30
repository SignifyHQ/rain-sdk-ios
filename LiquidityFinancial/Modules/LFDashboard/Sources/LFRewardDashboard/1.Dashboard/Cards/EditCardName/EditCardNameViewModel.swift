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
  @LazyInjected(\.customerSupportService) var customerSupportService

  @Published var isDisableButton: Bool = true
  @Published var isShowDisclosure: Bool = false
  @Published var isUpdatingCardName: Bool = false
  @Published var cardName: String = .empty
  @Published var inlineErrorMessage: String?
  
  private let onSuccess: (String) -> Void
  private let currentCardName: String
  
  private var subscribers: Set<AnyCancellable> = []

  init(cardName: String, onSuccess: @escaping ((String) -> Void)) {
    self.currentCardName = cardName
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
        // TODO: MinhNguyen - Will implement in ENG-3938
        let parameter = cardName.removeRedundantWhiteSpace()
        print("Debug >> \(parameter)")
        onSuccess(parameter)
        completion()
      } catch {
        inlineErrorMessage = error.userFriendlyMessage
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
}
