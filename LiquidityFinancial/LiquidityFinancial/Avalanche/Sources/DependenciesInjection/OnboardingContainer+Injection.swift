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
  // Network
  var authorizationManager: Factory<AuthorizationManagerProtocol> {
    self {
      AuthorizationManager()
    }
  }
  
  // Network
  var onboardingAPI: Factory<OnboardingAPIProtocol> {
    self {
      LFNetwork<OnboardingRoute>()
    }
  }
  
  var netspendAPI: Factory<NetSpendAPIProtocol> {
    self {
      LFNetwork<NetSpendRoute>()
    }
  }
  
  // ViewModels
  var phoneNumberViewModel: Factory<PhoneNumberViewModel> {
    self {
      PhoneNumberViewModel(
        requestOtpUserCase: self.requestOtpUseCase.callAsFunction(),
        loginUseCase: self.loginUseCase.callAsFunction(),
        netspendRepository: self.netspendRepository.callAsFunction()
      )
    }
  }
  
  // Repositories
  var onboardingRepository: Factory<OnboardingRepositoryProtocol> {
    self {
      OnboardingRepository(onboardingAPI: self.onboardingAPI.callAsFunction(), auth: self.authorizationManager.callAsFunction())
    }
  }
  
  var netspendRepository: Factory<NetSpendRepositoryProtocol> {
    self {
      NetSpendRepository(netSpendAPI: self.netspendAPI.callAsFunction())
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
