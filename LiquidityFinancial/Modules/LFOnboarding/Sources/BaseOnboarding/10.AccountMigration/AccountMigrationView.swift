import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFAccessibility
import Services

public struct AccountMigrationView<ViewModel: AccountMigrationViewModelProtocol>: View {
  @StateObject private var viewModel: ViewModel
  
  public init(viewModel: ViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack(spacing: 24) {
      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 80)
      descriptionView
      Spacer()
      buttonGroupView
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .background(Colors.background.swiftUIColor)
    .onAppear {
      viewModel.requestMigration()
    }
    .defaultToolBar(icon: .support, openSupportScreen: {
      viewModel.openSupportScreen()
    })
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension AccountMigrationView {
  var descriptionView: some View {
    VStack(spacing: 12) {
      Text(LFLocalizable.AccountMigrationView.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .accessibilityIdentifier(LFAccessibility.AccountLockedScreen.contactSupportTitle)
      Text(LFLocalizable.AccountMigrationView.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .multilineTextAlignment(.center)
        .accessibilityIdentifier(LFAccessibility.AccountLockedScreen.contactSupportDescription)
    }
    .padding(.horizontal, 12)
  }
  
  var buttonGroupView: some View {
    VStack(spacing: 10) {
      FullSizeButton(
        title: LFLocalizable.Button.ContactSupport.title,
        isDisable: false,
        textColor: Colors.contrast.swiftUIColor
      ) {
        viewModel.openSupportScreen()
      }
      .accessibilityIdentifier(LFAccessibility.AccountLockedScreen.contactSupportButton)
      FullSizeButton(
        title: LFLocalizable.Button.Logout.title,
        isDisable: false,
        type: .secondary,
        textColor: Colors.error.swiftUIColor
      ) {
        viewModel.logout()
      }
      .accessibilityIdentifier(LFAccessibility.AccountLockedScreen.logoutButton)
    }
  }
}
