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
            EnterPasswordView(shouldDismissRoot: $shouldDismiss)
          }
        }
      )
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .onChange(
        of: shouldDismiss,
        perform: { _ in
          dismiss()
        }
      )
      .track(name: String(describing: type(of: self)))
      .embedInNavigation()
  }
}

// MARK: - View Components
private extension BiometricsBackupView {
  var content: some View {
    VStack {
      Spacer()
      
      if let image = viewModel.biometricType.image, viewModel.isBiometricEnabled {
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
      if viewModel.isBiometricEnabled {
        FullSizeButton(
          title: LFLocalizable.Authentication.BiometricsBackup.BiomericsButton.title(viewModel.biometricType.title),
          isDisable: false,
          type: .primary
        ) {
          viewModel.didTapBiometricsLogin()
        }
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
}
