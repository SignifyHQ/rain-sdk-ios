import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services
import Factory
import BaseOnboarding

struct BackupWalletView: View {
  @StateObject var viewModel = BackupWalletViewModel()
  @Injected(\.contentViewFactory) var contentViewFactory
  
  var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      headerTitle
      selectBackupMethod
      Spacer()
      buttonGroup
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationLink(isActive: $viewModel.isNavigateToPersonalInformation) {
      let enterSSNView = EnterSSNView(
        viewModel: EnterSSNViewModel(isVerifySSN: true),
        onEnterAddress: {
          contentViewFactory.baseOnboardingNavigation.enterSSNDestinationView = .address(
            AnyView(AddressView())
          )
        }
      )
      
      PersonalInformationView(
        viewModel: PersonalInformationViewModel(),
        onEnterSSN: {
          contentViewFactory.baseOnboardingNavigation.personalInformationDestinationView = .enterSSN(
            AnyView(enterSSNView)
          )
        }
      )
    }
    .defaultToolBar(icon: .support) {
      viewModel.openSupportScreen()
    }
    .navigationBarBackButtonHidden(viewModel.isLoading)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension BackupWalletView {
  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L10N.Common.BackupWallet.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      Text(L10N.Common.BackupWallet.description)
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
    }
  }
  
  var selectBackupMethod: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(spacing: 4) {
        Text(Constants.Default.dotSymbol.rawValue)
          .foregroundColor(Colors.primary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        Text(L10N.Common.BackupWallet.SelectBackupMethod.title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      }
      backupMethodItem(method: .password)
      backupMethodItem(method: .iCloud)
    }
  }
  
  func backupMethodItem(method: BackupWalletViewModel.BackupMethod) -> some View {
    HStack(spacing: 12) {
      CircleSelected(isSelected: viewModel.selectedMethod == method)
      Text(method.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
    }
    .onTapGesture {
      viewModel.onBackupMethodSelected(method: method)
    }
    .disabled(viewModel.isLoading)
  }
  
  var buttonGroup: some View {
    VStack(spacing: 12) {
      FullSizeButton(
        title: L10N.Common.BackupWallet.BackupLater.button,
        isDisable: false,
        type: .tertiary
      ) {
        viewModel.onBackupLaterButtonTap()
      }
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: viewModel.selectedMethod == nil,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.onBackupButtonTap()
      }
    }
    .padding(.bottom, 12)
  }
}
