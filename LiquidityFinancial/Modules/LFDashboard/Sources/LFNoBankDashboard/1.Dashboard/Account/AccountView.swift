import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import BaseDashboard
import Factory

struct AccountsView: View {
  @Injected(\.analyticsService) var analyticsService
  
  @Environment(\.scenePhase) var scenePhase
  
  @StateObject private var viewModel: AccountViewModel
  
  @State var openSafariType: AccountViewModel.OpenSafariType?
  
  init(viewModel: AccountViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .track(name: String(describing: type(of: self)))
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .debugMenu:
          DBAdminMenuView(environment: viewModel.networkEnvironment.title)
        case .taxes:
          TaxesView()
        case .rewards:
          CurrentRewardView(notIncludeFiat: true)
        case .wallet(asset: let asset):
          ReceiveCryptoView(assetModel: asset)
        }
      }
      .sheet(item: $viewModel.sheet, content: { sheet in
        switch sheet {
        case .legal:
          if let url = URL(string: LFUtilities.termsURL) {
            WebView(url: url)
              .ignoresSafeArea()
          }
        }
      })
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .fullScreenCover(item: $openSafariType, content: { type in
        switch type {
        case .legal(let url):
          SFSafariViewWrapper(url: url)
        }
      })
      .background(Colors.background.swiftUIColor)
  }
}

// MARK: - View Components
private extension AccountsView {
  @ViewBuilder
  var content: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        
        if viewModel.assets.isNotEmpty {
          section(title: LFLocalizable.AccountView.wallets) {
            ForEach(viewModel.assets, id: \.externalAccountId) { asset in
              assetCell(asset: asset)
            }
          }
        }
        
        section(title: LFLocalizable.AccountView.shortcuts) {
          shortcutSection
        }
        
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 12)
      .padding(.horizontal, 30.0)
    }
  }
  
  var bottomDisclosure: some View {
    Text(LFLocalizable.AccountView.Disclosure.message)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
  }
  
  func section<V: View>(title: String, @ViewBuilder content: () -> V) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      content()
    }
  }
  
  var shortcutSection: some View {
    VStack {
      ArrowButton(
        image: GenImages.CommonImages.icRewards.swiftUIImage,
        title: LFLocalizable.AccountView.rewards,
        value: nil
      ) {
        viewModel.openReward()
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.tax.swiftUIImage,
        title: LFLocalizable.AccountView.taxes,
        value: nil
      ) {
        viewModel.openTaxes()
      }
      if !viewModel.notificationsEnabled {
        ArrowButton(
          image: GenImages.CommonImages.Accounts.notifications.swiftUIImage,
          title: LFLocalizable.AccountView.notifications,
          value: nil
        ) {
          viewModel.notificationTapped()
        }
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.legal.swiftUIImage,
        title: LFLocalizable.AccountView.legal,
        value: nil
      ) {
        guard let url = viewModel.getUrl() else { return }
        openSafariType = .legal(url)
      }
      ArrowButton(image: GenImages.CommonImages.icQuestion.swiftUIImage, title: LFLocalizable.Profile.Help.title, value: nil) {
        viewModel.helpTapped()
      }
      if viewModel.showAdminMenu {
        ArrowButton(
          image: GenImages.CommonImages.personAndBackgroundDotted.swiftUIImage,
          title: "ADMIN MENU",
          value: nil
        ) {
          viewModel.navigation = .debugMenu
        }
      }
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.checkNotificationsStatus()
      }
    })
  }
}

// MARK: - View Components
private extension AccountsView {
  @ViewBuilder func assetCell(asset: AssetModel) -> some View {
    if let assetType = asset.type {
      Button {
        viewModel.openWalletAddress(asset: asset)
      } label: {
        HStack(spacing: 8) {
          assetType.image
          Text(LFLocalizable.AccountView.Wallet.title(assetType.title))
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          Spacer()
          HStack(spacing: 0) {
            Text(
              LFLocalizable.AccountView.HiddenValue.title(
                viewModel.getLastFourDigits(from: asset.externalAccountId ?? .empty)
              )
            )
            .foregroundColor(textColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
      }
    }
  }
}

// MARK: - View Helpers
private extension AccountsView {
  var textColor: Color {
    switch LFStyleGuide.target {
    case .Cardano:
      return Colors.whiteText.swiftUIColor
    default:
      return Colors.primary.swiftUIColor
    }
  }
}
