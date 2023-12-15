import BiometricsManager
import SwiftUI
import LFUtilities
import LFAccessibility
import LFStyleGuide
import LFLocalizable

// MARK: - SetupBiometricPopup
public struct SetupBiometricPopup: View {
  let biometricType: BiometricType
  let primaryAction: () -> Void
  let secondaryAction: () -> Void
  
  public init(
    biometricType: BiometricType,
    primaryAction: @escaping () -> Void,
    secondaryAction: @escaping () -> Void
  ) {
    self.biometricType = biometricType
    self.primaryAction = primaryAction
    self.secondaryAction = secondaryAction
  }
  
  public var body: some View {
    PopupAlert(padding: 16) {
      VStack(spacing: 32) {
        if let biometricLogo = biometricType.image {
          biometricLogo
            .resizable()
            .frame(64)
            .foregroundColor(Colors.label.swiftUIColor)
            .padding(.top, 38)
        }
        contextView
        buttonGroup
      }
    }
  }
}

// MARK: View Components
private extension SetupBiometricPopup {
  var contextView: some View {
    VStack(spacing: 12) {
      Text(
        LFLocalizable.Authentication.SetupBiometrics.title(LFUtilities.cardFullName, biometricType.title)
          .uppercased()
      )
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .foregroundColor(Colors.label.swiftUIColor)
      .multilineTextAlignment(.center)
      Text(
        LFLocalizable.Authentication.SetupBiometrics.description(LFUtilities.cardFullName, biometricType.title)
      )
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      .multilineTextAlignment(.center)
      .lineSpacing(1.2)
    }
  }
  
  var buttonGroup: some View {
    HStack(spacing: 12) {
      FullSizeButton(
        title: LFLocalizable.Button.DonotAllow.title,
        isDisable: false,
        type: .secondary,
        action: secondaryAction
      )
      FullSizeButton(
        title: LFLocalizable.Button.Ok.title,
        isDisable: false,
        action: primaryAction
      )
    }
  }
}
