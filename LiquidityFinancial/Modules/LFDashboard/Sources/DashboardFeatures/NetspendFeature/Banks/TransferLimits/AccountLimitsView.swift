import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import NetSpendData

public struct AccountLimitsView: View {
  @StateObject private var viewModel = AccountLimitsViewModel()
  @State private var selectedAnnotation: AccountLimitSection?
  @State private var screenSize: CGSize = .zero
  @State private var selectedTab: AccountLimitsType = .deposit

  public init() {}
  
  public var body: some View {
    ZStack {
      if viewModel.isFetchingTransferLimit {
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
      } else if viewModel.isFetchTransferLimitFail {
        failure
      } else {
        VStack(alignment: .leading, spacing: 20) {
          headerTabView
          ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
              transferLimitsView
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
    .padding(.top, 16)
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .frame(max: .infinity)
    .background(Colors.background.swiftUIColor)
    .onTapGesture {
      selectedAnnotation = nil
    }
    .defaultToolBar(navigationTitle: LFLocalizable.TransferLimit.Screen.title)
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
  
  func tabItem(type: AccountLimitsType) -> some View {
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
  
  @ViewBuilder var transferLimitsView: some View {
    switch selectedTab {
    case .deposit:
      depositLimitsView
    case .withdraw:
      withdrawLimitsView
    default:
      EmptyView()
    }
  }
  
  var spendingLimitsView: some View {
    VStack(alignment: .leading, spacing: 50) {
      acountLimitsSection(
        type: AccountLimitSection.spendingLimit,
        transferSection: viewModel.spendingLimits.spendingLimits
      )
      acountLimitsSection(
        type: AccountLimitSection.financialInstitutionsLimit,
        transferSection: viewModel.spendingLimits.financialInstitutionLimits
      )
    }
  }
  
  var depositLimitsView: some View {
    VStack(alignment: .leading, spacing: 50) {
      acountLimitsSection(
        type: AccountLimitSection.sendToCard,
        transferSection: viewModel.depositLimits.sendToCardLimits
      )
      acountLimitsSection(
        type: AccountLimitSection.cardDeposit,
        transferSection: viewModel.depositLimits.externalCardLimits
      )
      acountLimitsSection(
        type: AccountLimitSection.bankDeposit,
        transferSection: viewModel.depositLimits.externalBankLimits
      )
    }
  }
  
  var withdrawLimitsView: some View {
    VStack(alignment: .leading, spacing: 50) {
      acountLimitsSection(
        type: AccountLimitSection.cardWithdraw,
        transferSection: viewModel.withdrawalLimits.externalCardLimits
      )
      acountLimitsSection(
        type: AccountLimitSection.bankWithdraw,
        transferSection: viewModel.withdrawalLimits.externalBankLimits
      )
    }
  }
  
  @ViewBuilder func acountLimitsSection(type: AccountLimitSection, transferSection: [NetspendLimitValue]) -> some View {
    if !transferSection.isEmpty {
      VStack(alignment: .leading, spacing: 24) {
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
        accountLimitItem(
          title: LimitsPeriodType.day.title,
          value: transferSection.first { $0.interval == LimitsPeriodType.day.rawValue }?.amount.toDouble
        )
        accountLimitItem(
          title: LimitsPeriodType.week.title,
          value: transferSection.first { $0.interval == LimitsPeriodType.week.rawValue }?.amount.toDouble
        )
        accountLimitItem(
          title: LimitsPeriodType.month.title,
          value: transferSection.first { $0.interval == LimitsPeriodType.month.rawValue }?.amount.toDouble
        )
        accountLimitItem(
          title: LimitsPeriodType.perTransaction.title,
          value: transferSection.first { $0.interval == LimitsPeriodType.perTransaction.rawValue }?.amount.toDouble
        )
      }
      .overlay(alignment: .top) {
        annotationView(type: type)
      }
    }
  }
  
  @ViewBuilder func accountLimitItem(title: String, value: Double?) -> some View {
    if let limitAmount = value {
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
  
  @ViewBuilder func annotationView(type: AccountLimitSection) -> some View {
    if let annotation = selectedAnnotation, selectedAnnotation == type {
      AnnotationView(
        description: annotation.message,
        corners: [.topLeft, .topRight, .bottomLeft, .bottomRight]
      )
      .offset(x: screenSize.width * 0.242, y: 28)
      .frame(width: screenSize.width * 0.65)
    }
  }
  
  var requestLimitIncreaseButton: some View {
    FullSizeButton(
      title: LFLocalizable.TransferLimit.RequestLimitIncrease.title,
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
      Text(LFLocalizable.TransferLimit.Error.title)
        .font(Fonts.medium.swiftUIFont(size: 14))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
      FullSizeButton(title: LFLocalizable.Button.Retry.title, isDisable: false) {
        viewModel.getTransferLimitConfigs()
      }
    }
    .frame(maxWidth: .infinity)
  }
  
  var createTicketSuccessPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.TransferLimit.CreateSupportTicket.title,
      message: LFLocalizable.TransferLimit.IncreaseLimit.message,
      primary: .init(
        text: LFLocalizable.Button.Ok.title,
        action: {
          viewModel.hidePopup()
        }
      )
    )
  }
  
  var ticketExistedPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.TransferLimit.CreateSupportTicket.title,
      message: LFLocalizable.TransferLimit.IncreaseLimitInReview.message,
      primary: .init(
        text: LFLocalizable.Button.Ok.title,
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
