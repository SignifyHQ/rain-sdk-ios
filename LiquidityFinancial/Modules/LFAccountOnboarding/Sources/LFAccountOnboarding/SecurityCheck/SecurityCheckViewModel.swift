import Foundation
import LFUtilities

@MainActor
final class SecurityCheckViewModel: ObservableObject {
  @Published var isDisableButton: Bool = true
  @Published var isShowLogoutPopup: Bool = false
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  @Published var ssn: String = "" {
    didSet {
      checkSSNFilled()
    }
  }
  
  init() {}
}

// MARK: - API
extension SecurityCheckViewModel {
  func callAddDeviceApi() {
    isLoading = true
    //    callAddDevice { status, error in
    //      if status == true {
    //        callGetUserAPI()
    //      } else {
    //        showIndicator = false
    //        DispatchQueue.main.async {
    //          toastMessage = error?.localizedDescription ?? ""
    //        }
    //      }
    //    }
  }
  
  func callGetUserAPI() {
    //    userManager.getUserInformation { result in
    //      switch result {
    //        case .success:
    //          log.info("user was verified")
    //          coordinator.routeUser {
    //            DispatchQueue.main.async {
    //              showIndicator = false
    //            }
    //          }
    //        case let .failure(error):
    //          DispatchQueue.main.async {
    //            if let code = error.asErrorObject?.code, code == ErrorCode.deviceIdInvalid.rawValue {
    //              selection = 2
    //            } else {
    //              ssnViewModel.errorMessage = error.localizedDescription
    //            }
    //          }
    //      }
    //    }
  }
  
  func updateUserDetails() {
    //    if userManager.user != nil {
    //      if let idvTypeCheck = userManager.user?.idType {
    //        if idvTypeCheck == idvType.ssn.rawValue {
    //          if let ssnData = userManager.user?.idNumber {
    //            ssn = ssnData
    //          }
    //        }
    //      }
    //    }
  }
}

// MARK: - View Helpers
extension SecurityCheckViewModel {  
  func showLogoutPopup() {
    isShowLogoutPopup = true
  }
  
  func hideLogoutPopup() {
    isShowLogoutPopup = false
  }
  
  func logout() {
    // TODO: Will be implemented later
    // userManager.logout()
    isShowLogoutPopup = false
  }
}

// MARK: - Private Extension
extension SecurityCheckViewModel {
  func checkSSNFilled() {
    let ssnLengthInvalid = ssn.trimWhitespacesAndNewlines().count != Constants.MaxCharacterLimit.ssnLength.value
    isDisableButton = ssn.trimWhitespacesAndNewlines().isEmpty || ssnLengthInvalid
  }
}
