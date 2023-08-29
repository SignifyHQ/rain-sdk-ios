import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

public struct HomeView: View {
  @StateObject private var viewModel: HomeViewModel
  let tabOptions: [TabOption]
  
  public init(viewModel: HomeViewModel, tabOptions: [TabOption]) {
    _viewModel = .init(wrappedValue: viewModel)
    self.tabOptions = tabOptions
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      ZStack {
        ForEach(tabOptions, id: \.self) { option in
          DashboardView(option: option) { option in
            viewModel.tabSelected = option
          }
          .opacity(viewModel.tabSelected == option ? 1 : 0)
        }
      }
      tabBar
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        trailingNavigationBarView
      }
      ToolbarItem(placement: .navigationBarLeading) {
        leadingNavigationBarView
      }
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .searchCauses:
        EmptyView() // TODO: - Will be implemented later
      case .editRewards:
        EmptyView() // TODO: - Will be implemented later
      case .profile:
        ProfileView()
      }
    }
    .popup(item: $viewModel.popup) { popup in
      switch popup {
      case .notifications:
        notificationsPopup
      }
    }
    .onAppear {
      viewModel.appearOperations()
    }
  }
}

// MARK: - View Components
private extension HomeView {
  var leadingNavigationBarView: some View {
    Text(viewModel.tabSelected.title.uppercased())
      .font(Fonts.orbitronBold.swiftUIFont(size: Constants.FontSize.navigationBar.value))
      .foregroundColor(Colors.label.swiftUIColor)
      .padding(.leading, 12)
  }
  
  var tabBar: some View {
    HStack(spacing: 0) {
      ForEach(tabOptions, id: \.self) { option in
        tabItem(option: option)
        if option != tabOptions.last {
          Spacer()
        }
      }
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 0)
    .padding(.top, 8)
    .background(Colors.secondaryBackground.swiftUIColor)
  }
  
  func tabItem(option: TabOption) -> some View {
    VStack(spacing: 2) {
      option.imageAsset
        .foregroundColor(
          option == viewModel.tabSelected ? Colors.primary.swiftUIColor : Colors.label.swiftUIColor
        )
      Text(option.title)
        .foregroundColor(
          option == viewModel.tabSelected ? Colors.label.swiftUIColor : Colors.label.swiftUIColor.opacity(0.75)
        )
        .font(Fonts.orbitronMedium.swiftUIFont(size: 10))
    }
    .onTapGesture {
      viewModel.onSelectedTab(tab: option)
    }
  }
  
  var trailingNavigationBarView: some View {
    HStack(spacing: 12) {
      if viewModel.isShowGearButton {
        Button {
          viewModel.onClickedGearButton()
        } label: {
          GenImages.CommonImages.icGear.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      Button {
        viewModel.onClickedProfileButton()
      } label: {
        GenImages.CommonImages.icProfile.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
      }
      .padding(.trailing, 12)
    }
  }
  
  private var notificationsPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.NotificationPopup.title,
      message: LFLocalizable.NotificationPopup.subtitle,
      primary: .init(
        text: LFLocalizable.NotificationPopup.action,
        action: viewModel.notificationsPopupAction
      ),
      secondary: .init(
        text: LFLocalizable.NotificationPopup.dismiss,
        action: viewModel.clearPopup
      )
    )
  }
}
