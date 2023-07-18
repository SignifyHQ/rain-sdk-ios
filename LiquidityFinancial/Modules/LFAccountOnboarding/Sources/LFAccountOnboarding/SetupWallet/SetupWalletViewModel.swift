import SwiftUI

// MARK: - SetupWalletViewModel

class SetupWalletViewModel: ObservableObject {
  
  @Published var showIndicator = false
  @Published var toastMessage: String?
  @Published var selection: Int?
  @Published var isTermsAgreed = false
  
}
