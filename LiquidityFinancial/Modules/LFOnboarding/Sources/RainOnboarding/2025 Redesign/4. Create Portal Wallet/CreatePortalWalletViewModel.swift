import BaseOnboarding
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import PortalData
import PortalDomain
import PortalSwift
import Services

@MainActor
public final class CreatePortalWalletViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.onboardingCoordinator) var onboardingCoordinator
  
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.portalService) var portalService
  
  @Published var navigation: OnboardingNavigation?
  
  @Published var areTermsAgreed: Bool = false
  
  @Published var isLoading: Bool = false
  @Published var currentToast: ToastData? = nil
  
  lazy var createPortalWalletUseCase: CreatePortalWalletUseCaseProtocol = {
    CreatePortalWalletUseCase(repository: portalRepository)
  }()
  
  lazy var backupWalletUseCase: BackupWalletUseCaseProtocol = {
    BackupWalletUseCase(repository: portalRepository)
  }()
  
  lazy var verifyAndUpdatePortalWalletUseCase: VerifyAndUpdatePortalWalletUseCaseProtocol = {
    VerifyAndUpdatePortalWalletUseCase(repository: portalRepository)
  }()
  
  lazy var getBackupMethodsUseCase: GetBackupMethodsUseCaseProtocol = {
    GetBackupMethodsUseCase(repository: portalRepository)
  }()
  
  var isContinueButtonEnabled: Bool {
    return areTermsAgreed
  }
  
  let userAgreement = "Portal Services User Agreement"
  let privacyPolicy = "Portal Privacy Policy"
  let regulatoryDisclosures = "Regulatory Disclosures"
  
  init() {}
}

// MARK: - Binding Observables
extension CreatePortalWalletViewModel {}

// MARK: - Handling UI/UX Logic
extension CreatePortalWalletViewModel {}

// MARK: - Handling Interations
extension CreatePortalWalletViewModel {
  func onSupportButtonTap() {
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTap() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        guard let walletAddress = await portalService.getWalletAddress(),
              !walletAddress.isEmpty
        else {
          // Initiate the wallet creation process if no wallet is found
          try await self.createPortalWallet()
          
          return
        }
        // If the wallet already exists, only back it up if needed
        try await backupCreatedWalletIfNeeded()
      } catch {
        // If the wallet was created previously, only back it up if needed
        if let error = error as? LFPortalError,
           error == .walletAlreadyExists {
          try await backupCreatedWalletIfNeeded()
          
          return
        }
        // In all other cases, only show the error toast
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
}

// MARK: - API Calls
extension CreatePortalWalletViewModel {
  private func createPortalWallet() async throws {
    // Attempt to create a new Portal wallet
    let walletAddress = try await createPortalWalletUseCase.execute()
    log.debug("Portal wallet creation successful: \(walletAddress)")
    // Backup the portal wallet with iCloud automatically after creation
    try await performCloudPortalWalletBackup()
  }
  
  private func performCloudPortalWalletBackup(
  ) async throws {
    try await backupWalletUseCase.execute(backupMethod: .iCloud, password: nil)
    log.debug("Portal wallet iCloud backup share saved successfully")
    // Verify wallet address and save in the database for the current user
    try await verifyAndUpdatePortalWallet()
  }
  
  private func backupCreatedWalletIfNeeded(
  ) async throws {
    // Check if backup share was saved in the database
    async let isWalletBackedUp = checkWalletBackupStatus()
    // Perform wallet backup if the share wasn't stored previously
    guard try await isWalletBackedUp
    else {
      try await performCloudPortalWalletBackup()
      
      return
    }
    // Only confirm wallet address and save it in the database in the case
    // when the backup share is already stored
    try await verifyAndUpdatePortalWallet()
  }
  
  private func checkWalletBackupStatus(
  ) async throws -> Bool {
    // Get the stored backup methods from the database
    let response = try await getBackupMethodsUseCase.execute()
    // Check if iCloud is one of the stored backup methods
    let backupMethods = response
      .backupMethods
      .map {
        BackupMethods(rawValue: $0)
      }
    
    return backupMethods.contains(.iCloud)
  }
  
  private func verifyAndUpdatePortalWallet(
  ) async throws {
    try await verifyAndUpdatePortalWalletUseCase.execute()
    // Navigate to nex step
    navigation = try await onboardingCoordinator.getOnboardingNavigation()
  }
}

// MARK: - Helper Functions
extension CreatePortalWalletViewModel {
  func getURL(
    tappedString: String
  ) -> URL? {
    let urlMapping: [String: String] = [
      userAgreement: LFUtilities.portalTermsURL,
      privacyPolicy: LFUtilities.portalPrivacyURL,
      regulatoryDisclosures: LFUtilities.portalSecurityURL
    ]
    
    return urlMapping[tappedString].flatMap { URL(string: $0) }
  }
}

// MARK: - Private Enums
extension CreatePortalWalletViewModel {
  enum SafariNavigation: String, Identifiable {
    var id: String {
      self.rawValue
    }
    
    case userAgreement
    case privacyPolicy
    case regulatoryDisclosures
  }
}
