import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct BiometricsBackupView: View {
  @Environment(\.dismiss)
  var dismiss
  
  @StateObject
  private var viewModel = BiometricsBackupViewModel()
  
  @State
  var shouldDismiss: Bool = false
  
  public init() {}
  
  public var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .navigationLink(
        item: $viewModel.navigation,
        destination: { navigation in
          switch navigation {
          case .passwordLogin:
            EnterPasswordView(
              purpose: .biometricsFallback,
              shouldDismissRoot: $viewModel.shouldDismiss
            )
          }
        }
      )
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .popup(item: $viewModel.popup) { popup in
        switch popup {
        case .biometricsLockout:
          biometricLockoutPopup
        }
      }
      .onChange(of: $viewModel.shouldDismiss.wrappedValue) { _ in
        dismiss()
      }
      .track(name: String(describing: type(of: self)))
      .embedInNavigation()
  }
}

// MARK: - View Components
private extension BiometricsBackupView {
  var content: some View {
    VStack {
      Spacer()
      
      if let image = viewModel.biometricType.image {
        image
          .resizable()
          .foregroundColor(Colors.label.swiftUIColor)
          .frame(100)
      }
      
      Spacer()
      
      buttonGroup
    }
    .padding([.horizontal, .bottom], 30)
  }
  
  var buttonGroup: some View {
    VStack(spacing: 12) {
      FullSizeButton(
        title: LFLocalizable.Authentication.BiometricsBackup.BiomericsButton.title(viewModel.biometricType.title),
        isDisable: false,
        type: .primary
      ) {
        viewModel.didTapBiometricsLogin()
      }
      
      FullSizeButton(
        title: LFLocalizable.Authentication.BiometricsBackup.PasswordButton.title,
        isDisable: false,
        type: .secondary
      ) {
        viewModel.didTapPasswordLogin()
      }
    }
  }
  
  var biometricLockoutPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Authentication.BiometricsLockoutError.title(viewModel.biometricType.title),
      message: LFLocalizable.Authentication.BiometricsLockoutError.message(viewModel.biometricType.title),
      primary: .init(text: LFLocalizable.Button.Ok.title) {
        viewModel.hidePopup()
      }
    )
  }
}
