import Foundation
import OnboardingDomain

@MainActor
public class SigningUpPhoneViewModel: ObservableObject {
  
  let requestOtpUserCase: RequestOTPUseCaseProtocol
  let loginUserCase: LoginUseCaseProtocol
  
  public init(requestOtpUserCase: RequestOTPUseCaseProtocol, loginUserCase: LoginUseCaseProtocol) {
    self.requestOtpUserCase = requestOtpUserCase
    self.loginUserCase = loginUserCase
  }

  func performLogin(phone: String, code: String) {
    Task {
      do {
        let formatPhone = "+1\(phone)"
        let accessTokens = try await loginUserCase.execute(phoneNumber: formatPhone, code: code)
        print(accessTokens)
      } catch {
        print(error)
      }
    }
  }
  
  func performGetOTP(phone: String) {
    Task {
      do {
        let formatPhone = "+1\(phone)"
        let otp = try await requestOtpUserCase.execute(phoneNumber: formatPhone)
        print(otp)
      } catch {
        print(error)
      }
    }
  }
  
}
