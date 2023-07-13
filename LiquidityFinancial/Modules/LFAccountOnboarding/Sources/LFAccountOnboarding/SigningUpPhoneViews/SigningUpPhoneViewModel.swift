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
  
}
