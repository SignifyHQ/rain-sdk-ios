import AccountDomain
import Factory
import LFUtilities
import SwiftUI

@MainActor
public class PromocodeViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var presentationDetent: PresentationDetent = .height(370)
  @Published var isLoading: Bool = false
  
  @Published var promocode: String = "" {
    didSet {
      errorMessage = nil
    }
  }
  @Published var isSuccessState: Bool = false
  @Published var errorMessage: String?
  
  lazy var applyPromocodeUseCase: ApplyPromoCodeUseCaseProtocol = {
    ApplyPromoCodeUseCase(repository: accountRepository)
  }()
  
  lazy var savePopupShownUseCaseProtocol: SavePopupShownUseCaseProtocol = {
    SavePopupShownUseCase(repository: accountRepository)
  }()
  
  var isContinueButtonEnabled: Bool {
    if isSuccessState || promocode.trimWhitespacesAndNewlines().count > 3 {
      return true
    }
    
    return false
  }
  
  public init() {
    
  }
  
  func applyPromocode() {
    Task {
      isLoading = true
      defer {
        isLoading = false
      }
      
      let promocodeTrimmed = promocode.trimWhitespacesAndNewlines()
      
      do {
        // Don't pass phone number for existing user, it is only required in the onboarding
        try await applyPromocodeUseCase.execute(phoneNumber: nil, promocode: promocodeTrimmed)
        
        withAnimation {
          self.isSuccessState = true
        }
      } catch {
        errorMessage = error.asErrorObject?.userFriendlyMessage ?? error.userFriendlyMessage
      }
    }
  }
  
  func saveFrntShown() {
    Task {
      do {
        try await savePopupShownUseCaseProtocol.execute(campaign: "FRNT")
      } catch {
        log.error(error)
      }
    }
  }
  
  func resetState() {
    withAnimation(nil) {
      promocode = ""
      isSuccessState = false
    }
  }
}
