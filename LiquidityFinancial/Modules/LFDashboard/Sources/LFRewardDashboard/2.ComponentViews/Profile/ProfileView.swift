import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct ProfileView: View {
  @StateObject private var viewModel = ProfileViewModel()
  @Environment(\.scenePhase) var scenePhase
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 24) {
        contact
        donationsInvites
        stickers
        accountSettings
        bottom
      }
      .padding([.top, .horizontal], 30)
    }
    .frame(maxWidth: .infinity)
    .blur(radius: viewModel.popup != nil ? 16 : 0)
    .background(Colors.background.swiftUIColor)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(LFLocalizable.Profile.Toolbar.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
    .navigationBarHidden(viewModel.popup != nil)
    .overlay(popupBackground)
    .onAppear {
      viewModel.onAppear()
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.checkNotificationsStatus()
      }
    })
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .depositLimits:
        EmptyView() // TODO: Will be implemented later
      case .referrals:
        ReferralsView()
      }
    }
    .popup(item: $viewModel.popup) { popup in
      switch popup {
      case .deleteAccount:
        deleteAccountPopup
      case .logout:
        logoutPopup
      }
    }
    .popup(isPresented: $viewModel.showContributionToast, style: .toast) {
      ToastView(toastMessage: LFLocalizable.Profile.ContributionToast.message)
    }
  }
}

// MARK: - View Components
private extension ProfileView {
  @ViewBuilder var popupBackground: some View {
    if viewModel.popup != nil {
      Colors.background.swiftUIColor.opacity(0.5).ignoresSafeArea()
    }
  }
  
  var contact: some View {
    VStack(spacing: 16) {
      userImage
      VStack(spacing: 4) {
        Text(viewModel.name)
          .font(Fonts.regular.swiftUIFont(size: 20))
          .foregroundColor(Colors.label.swiftUIColor)
        Text(viewModel.email)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
    }
  }
  
  var userImage: some View {
    ZStack {
      Circle()
        .fill(Colors.secondaryBackground.swiftUIColor)
        .frame(80)
        .overlay {
          GenImages.CommonImages.icUser.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      Circle()
        .stroke(
          Colors.primary.swiftUIColor,
          style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
        )
        .frame(92)
        .padding(1)
    }
  }
  
  var donationsInvites: some View {
    VStack(spacing: 10) {
      HStack(spacing: 10) {
        contributionItem(value: viewModel.totalDonations, title: LFLocalizable.Profile.TotalDonations.title)
        contributionItem(value: viewModel.totalDonated, title: LFLocalizable.Profile.TotalDonated.title)
      }
      ArrowButton(
        image: GenImages.CommonImages.icShareWithFriend.swiftUIImage,
        title: LFLocalizable.Profile.Referrals.title,
        value: LFLocalizable.Profile.Referrals.message
      ) {
        viewModel.showReferrals()
      }
    }
  }
  
  func contributionItem(value: String, title: String) -> some View {
    VStack(spacing: 4) {
      ZStack {
        Text(value)
          .font(Fonts.regular.swiftUIFont(size: 20))
          .foregroundColor(Colors.label.swiftUIColor)
          .hidden(viewModel.isLoadingContribution)
        
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
          .hidden(!viewModel.isLoadingContribution)
      }
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 4)
    .padding(.vertical, 16)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  @ViewBuilder var stickers: some View {
    if viewModel.showStickers {
      VStack(alignment: .leading, spacing: 16) {
        Text(LFLocalizable.Profile.Stickers.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .padding(.leading, 10)
        
        if viewModel.isLoadingContribution {
          Group {
            LottieView(loading: .primary)
              .frame(width: 45, height: 30)
              .padding()
          }
          .frame(height: 80)
          .frame(maxWidth: .infinity)
        } else {
          stickersCarousel
        }
      }
    }
  }
  
  var stickersCarousel: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 16) {
        ForEach(viewModel.stickers) { item in
          StickerView(type: .profile, sticker: item)
        }
      }
      .padding(.leading, 30)
    }
    .padding(.horizontal, -30)
  }
  
  var accountSettings: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(LFLocalizable.Profile.Accountsettings.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .padding(.leading, 10)
      VStack(spacing: 10) {
        informationCell(
          image: GenImages.CommonImages.icPhone.swiftUIImage,
          title: LFLocalizable.Profile.PhoneNumber.title,
          value: viewModel.phoneNumber
        )
        informationCell(
          image: GenImages.CommonImages.icMail.swiftUIImage,
          title: LFLocalizable.Profile.Email.title,
          value: viewModel.email
        )
        informationCell(
          image: GenImages.CommonImages.icMap.swiftUIImage,
          title: LFLocalizable.Profile.Address.title,
          value: viewModel.address
        )
        ArrowButton(image: GenImages.CommonImages.icWarning.swiftUIImage, title: LFLocalizable.Profile.DepositLimits.title, value: nil) {
          viewModel.depositLimitsTapped()
        }
        ArrowButton(image: GenImages.CommonImages.icQuestion.swiftUIImage, title: LFLocalizable.Profile.Help.title, value: nil) {
          viewModel.helpTapped()
        }
        if !viewModel.notificationsEnabled {
          ArrowButton(
            image: GenImages.CommonImages.icNotification.swiftUIImage,
            title: LFLocalizable.Profile.Notifications.title,
            value: nil
          ) {
            viewModel.notificationTapped()
          }
        }
      }
    }
  }
  
  var bottom: some View {
    VStack(spacing: 16) {
      VStack(spacing: 10) {
        FullSizeButton(title: LFLocalizable.Profile.Logout.title, isDisable: false, type: .secondary) {
          viewModel.logoutTapped()
        }
        HStack {
          Rectangle()
            .fill(Colors.label.swiftUIColor.opacity(0.5))
            .frame(height: 1)
          Text(LFLocalizable.Profile.Or.title)
            .font(Fonts.regular.swiftUIFont(size: 10))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
          Rectangle()
            .fill(Colors.label.swiftUIColor.opacity(0.5))
            .frame(height: 1)
        }
        .padding(.horizontal, 12)
        FullSizeButton(title: LFLocalizable.Profile.DeleteAccount.title, isDisable: false, type: .destructive) {
          viewModel.deleteAccountTapped()
        }
      }
      Text(LFLocalizable.Profile.Version.title(LFUtility.marketingVersion))
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
    .padding(.vertical, 16)
  }
  
  var deleteAccountPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Profile.DeleteAccount.message.uppercased(),
      primary: .init(text: LFLocalizable.Button.No.title, action: { viewModel.dismissPopup() }),
      secondary: .init(text: LFLocalizable.Button.Yes.title, action: { viewModel.deleteAccount() }),
      isLoading: $viewModel.isLoading
    )
  }
  
  var logoutPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Profile.Logout.message.uppercased(),
      primary: .init(text: LFLocalizable.Button.No.title, action: { viewModel.dismissPopup() }),
      secondary: .init(text: LFLocalizable.Button.Yes.title, action: { viewModel.logout() }),
      isLoading: $viewModel.isLoading
    )
  }
  
  func informationCell(image: Image, title: String, value: String) -> some View {
    HStack(spacing: 12) {
      image
        .foregroundColor(Colors.label.swiftUIColor)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: 10))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        Text(value)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.trailing, 24)
      }
      .lineLimit(2)
      .minimumScaleFactor(0.6)
      Spacer()
    }
    .padding(12)
    .padding(.leading, 6)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
}
