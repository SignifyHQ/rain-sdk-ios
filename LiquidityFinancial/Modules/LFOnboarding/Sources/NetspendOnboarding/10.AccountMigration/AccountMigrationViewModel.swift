import Factory
import Services
import BaseOnboarding
import AccountDomain

@MainActor
final class AccountMigrationViewModel: AccountMigrationViewModelProtocol {
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.nsOnboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.accountRepository) var accountRepository
  
  lazy var requestAccountMigrationUseCase: RequestMigrationStatusUseCaseProtocol = {
    RequestMigrationStatusUseCase(repository: accountRepository)
  }()

  init() {}
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func logout() {
    onboardingFlowCoordinator.forcedLogout()
  }
  
  func requestMigration() {
    Task {
      try? await requestAccountMigrationUseCase.execute()
    }
  }
}
