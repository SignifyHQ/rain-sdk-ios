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
  @Published var verificationCode: String = .empty
  @Published var secretKey: String = .empty
  @Published var qrCode = UIImage()
  @Published var toastMessage: String?
  
  lazy var getSecretKeyUseCase: GetSecretKeyUseCaseProtocol = {
    GetSecretKeyUseCase(repository: accountRepository)
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
        log.error(error.localizedDescription)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func enableMFAAuthentication() {
  }
}

// MARK: - View Helpers
extension SetupAuthenticatorAppViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func copyAddress() {
    UIPasteboard.general.string = secretKey
    toastMessage = LFLocalizable.Toast.Copy.message
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
}
