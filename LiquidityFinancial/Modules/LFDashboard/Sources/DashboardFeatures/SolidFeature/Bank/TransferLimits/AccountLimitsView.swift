import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

public struct AccountLimitsView: View {
  @StateObject private var viewModel = AccountLimitsViewModel()
  @State private var selectedAnnotation: AccountLimitsSection?
  @State private var screenSize: CGSize = .zero
  @State private var selectedTab: TransactionLimitType = .deposit

  public init() {}
  
  public var body: some View {
    ZStack {
      if viewModel.isFetchingTransferLimit {
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
      } else if viewModel.isFetchTransferLimitFail {
        failure
      } else {
        VStack(alignment: .leading, spacing: 24) {
          headerTabView
          ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
              accountLimitsView
            }
          }
          Spacer()
          requestLimitIncreaseButton
        }
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .popup(item: $viewModel.popup) { item in
      switch item {
      case .createTicketSuccess:
        createTicketSuccessPopup
      case .ticketExisted:
        ticketExistedPopup
      }
    }
    .readGeometry { geo in
      screenSize = geo.size
    }
    .padding(.top, 20)
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .frame(max: .infinity)
    .background(Colors.background.swiftUIColor)
    .onTapGesture {
      selectedAnnotation = nil
    }
    .defaultToolBar(navigationTitle: L10N.Common.TransferLimit.Screen.title)
  }
}

// MARK: - View Components
private extension AccountLimitsView {
  var headerTabView: some View {
    HStack(spacing: 0) {
      tabItem(type: .deposit)
      tabItem(type: .withdraw)
    }
    .padding(.horizontal, 8)
    .frame(width: screenSize.width, height: 40)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(32)
  }
  
  func tabItem(type: TransactionLimitType) -> some View {
    HStack {
      Spacer()
      Text(type.title)
        .foregroundColor(selectedTab == type ? Colors.contrast.swiftUIColor : Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      Spacer()
    }
    .contentShape(Rectangle())
    .onTapGesture {
      Haptic.impact(.light).generate()
      selectedTab = type
      selectedAnnotation = nil
    }
    .frame(width: (screenSize.width - (screenSize.width > 0 ? 8.0 : 0)) / 2, height: 32)
    .background(
      LinearGradient(
        colors: selectedTab == type ? gradientColor : [],
        startPoint: .leading,
        endPoint: .trailing
      )
    )
    .cornerRadius(32)
  }
  
  @ViewBuilder var accountLimitsView: some View {
    switch selectedTab {
    case .deposit:
      depositLimitsView
    case .withdraw:
      withdrawLimitsView
    default:
      EmptyView()
    }
  }
  
  var depositLimitsView: some View {
    VStack(alignment: .leading, spacing: 50) {
      accountLimitsSection(
        type: AccountLimitsSection.totalDeposit,
        model: viewModel.model
      )
      accountLimitsSection(
        type: AccountLimitsSection.cardDeposit,
        model: viewModel.model
      )
      accountLimitsSection(
        type: AccountLimitsSection.bankDeposit,
        model: viewModel.model
      )
    }
  }
  
  var withdrawLimitsView: some View {
    VStack(alignment: .leading, spacing: 50) {
      accountLimitsSection(
        type: AccountLimitsSection.totalWithdraw,
        model: viewModel.model
      )
      accountLimitsSection(
        type: AccountLimitsSection.cardWithdraw,
        model: viewModel.model
      )
      accountLimitsSection(
        type: AccountLimitsSection.bankWithdraw,
        model: viewModel.model
      )
    }
  }
  
  private func sectionHeader(type: AccountLimitsSection) -> some View {
    HStack(spacing: 5) {
      Text(type.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      GenImages.CommonImages.info.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
        .onTapGesture {
          Haptic.impact(.light).generate()
          if selectedAnnotation == type {
            selectedAnnotation = nil
          } else {
             selectedAnnotation = type
          }
        }
    }
  }
  
  @ViewBuilder func accountLimitsSection(type: AccountLimitsSection, model: AccountLimitsUIModel) -> some View {
    VStack(alignment: .leading, spacing: 24) {
      if type == .totalDeposit {
        sectionHeader(type: type)
          .isHidden(hidden: model.deposit.depositTotalEmpty)
        
        accountLimitItem(
          title: TransferPeriod.day.title,
          value: model.deposit.depositTotalDaily
        )
        accountLimitItem(
          title: TransferPeriod.month.title,
          value: model.deposit.depositTotalMonthly
        )
      }
      if type == .cardDeposit {
        sectionHeader(type: type)
          .isHidden(hidden: model.deposit.depositCardEmpty)
        
        accountLimitItem(
          title: TransferPeriod.day.title,
          value: model.deposit.depositCardDaily
        )
        accountLimitItem(
          title: TransferPeriod.month.title,
          value: model.deposit.depositCardMonthly
        )
      }
      if type == .bankDeposit {
        sectionHeader(type: type)
          .isHidden(hidden: model.deposit.depositAcHEmpty)
        
        accountLimitItem(
          title: TransferPeriod.day.title,
          value: model.deposit.depositAchDaily
        )
        accountLimitItem(
          title: TransferPeriod.month.title,
          value: model.deposit.depositAchMonthly
        )
      }
      
      if type == .totalWithdraw {
        sectionHeader(type: type)
          .isHidden(hidden: model.withdrawal.withdrawalTotalEmpty)
        
        accountLimitItem(
          title: TransferPeriod.day.title,
          value: model.withdrawal.withdrawalTotalDaily
        )
        accountLimitItem(
          title: TransferPeriod.month.title,
          value: model.withdrawal.withdrawalTotalMonthly
        )
      }
      if type == .cardWithdraw {
        sectionHeader(type: type)
          .isHidden(hidden: model.withdrawal.withdrawalCardEmpty)
        
        accountLimitItem(
          title: TransferPeriod.day.title,
          value: model.withdrawal.withdrawalCardDaily
        )
        accountLimitItem(
          title: TransferPeriod.month.title,
          value: model.withdrawal.withdrawalCardMonthly
        )
      }
      if type == .bankWithdraw {
        sectionHeader(type: type)
          .isHidden(hidden: model.withdrawal.withdrawalAcHEmpty)
        
        accountLimitItem(
          title: TransferPeriod.day.title,
          value: model.withdrawal.withdrawalAchDaily
        )
        accountLimitItem(
          title: TransferPeriod.month.title,
          value: model.withdrawal.withdrawalAchMonthly
        )
      }
      
    }
    .overlay(alignment: .top) {
      annotationView(type: type)
    }
  }
  
  @ViewBuilder func accountLimitItem(title: String, value: Double?) -> some View {
    if let limitAmount = value, limitAmount > 0 {
      VStack(spacing: 16) {
        HStack {
          Text(title)
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          Spacer()
          Text(limitAmount.formattedUSDAmount())
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundStyle(
              LinearGradient(
                colors: textColor,
                startPoint: .leading,
                endPoint: .trailing
              )
            )
        }
        GenImages.CommonImages.dash.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
  }
  
  @ViewBuilder func annotationView(type: AccountLimitsSection) -> some View {
    if let annotation = selectedAnnotation, selectedAnnotation == type {
      AnnotationView(
        description: annotation.message,
        corners: [.topLeft, .topRight, .bottomLeft, .bottomRight]
      )
      .offset(x: screenSize.width * 0.12, y: 28)
      .frame(width: screenSize.width * 0.65)
    }
  }
  
  var requestLimitIncreaseButton: some View {
    FullSizeButton(
      title: L10N.Common.TransferLimit.RequestLimitIncrease.title,
      isDisable: false,
      isLoading: $viewModel.isRequesting
    ) {
      selectedAnnotation = nil
      viewModel.requestLimitIncrease()
    }
  }
  
  var failure: some View {
    VStack(spacing: 32) {
      Spacer()
      Text(L10N.Common.TransferLimit.Error.title)
        .font(Fonts.medium.swiftUIFont(size: 14))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
      FullSizeButton(title: L10N.Common.Button.Retry.title, isDisable: false) {
        viewModel.getAccountLimits()
      }
    }
    .frame(maxWidth: .infinity)
  }
  
  var createTicketSuccessPopup: some View {
    LiquidityAlert(
      title: L10N.Common.TransferLimit.CreateSupportTicket.success,
      message: L10N.Common.TransferLimit.IncreaseLimit.message,
      primary: .init(
        text: L10N.Common.Button.Ok.title,
        action: {
          viewModel.hidePopup()
        }
      )
    )
  }
  
  var ticketExistedPopup: some View {
    LiquidityAlert(
      title: L10N.Common.TransferLimit.CreateSupportTicket.title,
      message: L10N.Common.TransferLimit.IncreaseLimitInReview.message,
      primary: .init(
        text: L10N.Common.Button.Ok.title,
        action: {
          viewModel.hidePopup()
        }
      )
    )
  }
}

// MARK: - View Helpers
private extension AccountLimitsView {
  var gradientColor: [Color] {
    switch LFStyleGuide.target {
    case .CauseCard:
      return [
        Colors.Gradients.Button.gradientButton0.swiftUIColor,
        Colors.Gradients.Button.gradientButton1.swiftUIColor
      ]
    default:
      return [Colors.primary.swiftUIColor]
    }
  }
  
  var textColor: [Color] {
    switch LFStyleGuide.target {
    case .Cardano:
      return [Colors.whiteText.swiftUIColor]
    default:
      return gradientColor
    }
  }
}
