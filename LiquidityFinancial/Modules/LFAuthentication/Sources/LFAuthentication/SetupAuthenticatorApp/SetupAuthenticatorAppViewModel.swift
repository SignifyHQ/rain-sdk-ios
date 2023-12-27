import AccountData
import AccountDomain
import Combine
import CoreImage.CIFilterBuiltins
import Factory
import Foundation
import LFLocalizable
import LFUtilities
import SwiftUI

@MainActor
final class SetupAuthenticatorAppViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService

  @Published var isInit: Bool = false
  @Published var isVerifyingTOTP: Bool = false
  @Published var verificationCode: String = .empty
  @Published var recoveryCode: String = .empty
  @Published var secretKey: String = .empty
  @Published var qrCode = UIImage()
  @Published var toastMessage: String?
  @Published var popup: Popup?
  
  var isDisableVerifyButton: Bool {
    verificationCode.trimWhitespacesAndNewlines().count != Constants.MaxCharacterLimit.mfaCode.value
  }
  
  lazy var getSecretKeyUseCase: GetSecretKeyUseCaseProtocol = {
    GetSecretKeyUseCase(repository: accountRepository)
  }()
  
  lazy var enableMFAUseCase: EnableMFAUseCaseProtocol = {
    EnableMFAUseCase(repository: accountRepository)
  }()
  
  init() {
    getSecretKey()
  }
}

// MARK: - API
extension SetupAuthenticatorAppViewModel {
  func getSecretKey() {
    Task {
      defer { isInit = false }
      isInit = true
      
      do {
        let response = try await getSecretKeyUseCase.execute()
        secretKey = response.secretKey.trimmingCharacters(in: ["="])
        qrCode = generateQRCode()
      } catch {
        handleError(error: error)
      }
    }
  }
  
  func enableMFAAuthentication() {
    Task {
      defer { isVerifyingTOTP = false }
      isVerifyingTOTP = true
      
      do {
        let response = try await enableMFAUseCase.execute(code: verificationCode)
        recoveryCode = response.recoveryCode
        popup = .recoveryCode
      } catch {
        handleError(error: error)
      }
    }
  }
}

// MARK: - View Helpers
extension SetupAuthenticatorAppViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func copyText(text: String) {
    UIPasteboard.general.string = text
    toastMessage = LFLocalizable.Toast.Copy.message
  }
  
  func didRecoveryCodeSave() {
    popup = .mfaTurnedOn
  }
  
  func hidePopup() {
    popup = nil
  }
}

// MARK: - Private Functions
private extension SetupAuthenticatorAppViewModel {
  func generateQRCode() -> UIImage {
    guard let totpURL = generateTOTPURL() else {
      return UIImage()
    }
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(totpURL.utf8)
    
    if let outputImage = filter.outputImage,
       let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
      return UIImage(cgImage: cgimg)
    }
    
    return UIImage()
  }
  
  func generateTOTPURL() -> String? {
    if let accountName = accountDataManager.userInfomationData.email,
       let issuerEncoded = LFUtilities.cardFullName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
      return "otpauth://totp/\(issuerEncoded):\(accountName)?secret=\(secretKey)&issuer=\(issuerEncoded)"
    }
    
    return nil
  }
  
  func handleError(error: Error) {
    log.error(error.localizedDescription)
    toastMessage = error.userFriendlyMessage
  }
}

// MARK: - Types
extension SetupAuthenticatorAppViewModel {
  enum Popup {
    case recoveryCode
    case mfaTurnedOn
  }
}
