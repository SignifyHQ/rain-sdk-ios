import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import AccountData

public struct BackupWalletView: View {
  @StateObject private var viewModel: BackupWalletViewModel
  
  public init() {
    _viewModel = .init(wrappedValue: BackupWalletViewModel())
  }
  
  public var body: some View {
    ZStack {
      if viewModel.isLoading {
        loadingView
      } else {
        content
      }
    }
    .background(Colors.background.swiftUIColor)
  }
}

// MARK: View Components
private extension BackupWalletView {
  var content: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(L10N.Common.BackupWallet.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      backupMethodView(method: .iCloud)
      backupMethodView(method: .password, isBackedUp: viewModel.isBackedUpByPassword)
      Spacer()
      disclosureBottomView
    }
    .padding(30)
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .setupPIN:
        BackupByPinCodeView(purpose: .setup)
      }
    }
    .ignoresSafeArea(edges: .bottom)
    .navigationBarTitleDisplayMode(.inline)
    .track(name: String(describing: type(of: self)))
  }
  
  var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }
  
  func backupMethodView(
    method: BackupWalletViewModel.BackupMethod,
    isBackedUp: Bool = true
  ) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(alignment: .top) {
        method.image.swiftUIImage
          .resizable()
          .frame(48)
        Spacer()
        activeView
          .opacity(isBackedUp ? 1 : 0)
      }
      backupMethodDescription(method: method)
      if method == .password && !isBackedUp {
        FullSizeButton(title: L10N.Common.BackupWallet.SetupPinCode.title, isDisable: false) {
          viewModel.setupPinButtonTapped()
        }
      }
    }
    .padding(16)
    .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(12))
  }
  
  func backupMethodDescription(method: BackupWalletViewModel.BackupMethod) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(method.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .fontWeight(.medium)
        .foregroundColor(Colors.label.swiftUIColor)
      Text(method.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }
  
  var activeView: some View {
    HStack(spacing: 4) {
      Circle()
        .fill(Colors.primary.swiftUIColor)
        .frame(16)
        .overlay {
          GenImages.CommonImages.icCheckmark.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      Text(L10N.Common.BackupWallet.Active.title)
        .fontWeight(.medium)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.error.swiftUIColor)
    }
    .padding(.vertical, 7)
    .padding(.horizontal, 8)
    .background(Colors.buttons.swiftUIColor.cornerRadius(4))
  }
  
  var disclosureBottomView: some View {
    HStack(spacing: 12) {
      GenImages.CommonImages.Accounts.legal.swiftUIImage
        .resizable()
        .frame(24)
        .foregroundColor(Colors.error.swiftUIColor)
      Text(L10N.Common.BackupWallet.Disclosure.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
    .padding(.bottom, 12)
  }
}
