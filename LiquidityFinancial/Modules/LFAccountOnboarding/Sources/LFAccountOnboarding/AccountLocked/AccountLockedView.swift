import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFServices

struct AccountLockedView: View {
  @StateObject private var viewModel = AccountLockedViewModel()
  
  var body: some View {
    VStack(spacing: 24) {
      GenImages.Images.lockedAccount.swiftUIImage
      descriptionView
      Spacer()
      buttonGroupView
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .background(Colors.background.swiftUIColor)
    .defaultToolBar(icon: .support, openSupportScreen: {
      viewModel.openSupportScreen()
    })
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension AccountLockedView {
  var descriptionView: some View {
    VStack(spacing: 12) {
      Text(LFLocalizable.AccountLocked.ContactSupport.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(LFLocalizable.AccountLocked.ContactSupport.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .multilineTextAlignment(.center)
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
      FullSizeButton(
        title: LFLocalizable.Button.Logout.title,
        isDisable: false,
        type: .secondary,
        textColor: Colors.error.swiftUIColor
      ) {
        viewModel.logout()
      }
    }
  }
}
