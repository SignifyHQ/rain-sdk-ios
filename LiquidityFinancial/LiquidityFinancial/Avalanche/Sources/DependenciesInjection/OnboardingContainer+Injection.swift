import Foundation
import Factory
import OnboardingDomain
import LFNetwork
import OnboardingData
import LFAccountOnboarding
import DataUtilities
import AuthorizationManager
import NetSpendData

@MainActor
extension Container {
  
  //Coordinator
  var coordinator: Factory<AppCoordinatorProtocol> {
    self {
      AppCoordinator()
    }
  }
  // Network
  var onboardingAPI: Factory<OnboardingAPIProtocol> {
    self {
      LFNetwork<OnboardingRoute>()
    }
  }
  
  // ViewModels
  var phoneNumberViewModel: Factory<PhoneNumberViewModel> {
    self {
      PhoneNumberViewModel(
        requestOtpUserCase: self.requestOtpUseCase.callAsFunction(),
        loginUseCase: self.loginUseCase.callAsFunction()
      )
    }
  }
  
  // Repositories
  var onboardingRepository: Factory<OnboardingRepositoryProtocol> {
    self {
      OnboardingRepository(onboardingAPI: self.onboardingAPI.callAsFunction(), auth: self.authorizationManager.callAsFunction())
    }
  }

  // UseCases
  var loginUseCase: Factory<LoginUseCaseProtocol> {
    self {
      LoginUseCase(repository: self.onboardingRepository.callAsFunction())
    }
  }
  
  var requestOtpUseCase: Factory<RequestOTPUseCaseProtocol> {
    self {
      RequestOTPUseCase(repository: self.onboardingRepository.callAsFunction())
    }
  }
  
}
