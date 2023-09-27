import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

public struct TransferLimitsView: View {
  @StateObject private var viewModel = TransferLimitsViewModel()
  @State private var selectedAnnotation: TransferLimitSection?
  @State private var screenSize: CGSize = .zero
  @State private var selectedTab: TransferLimitConfig.TransactionType = .spending

  public init() {}
  
  public var body: some View {
    ZStack {
      if viewModel.isFetchingTransferLimit {
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
      } else if viewModel.isFetchTransferLimitFail {
        failure
      } else {
        VStack(alignment: .leading) {
          ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
              headerTabView
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
    .padding(.top, 20)
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Colors.background.swiftUIColor)
    .onTapGesture {
      selectedAnnotation = nil
    }
    .defaultToolBar(navigationTitle: LFLocalizable.TransferLimit.Screen.title)
  }
}

// MARK: - View Components
private extension TransferLimitsView {
  var headerTabView: some View {
    HStack(spacing: 0) {
      tabItem(type: .spending)
      tabItem(type: .deposit)
      tabItem(type: .withdraw)
    }
    .padding(.horizontal, 8)
    .frame(width: screenSize.width, height: 40)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(32)
  }
  
  func tabItem(type: TransferLimitConfig.TransactionType) -> some View {
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
    .frame(width: (screenSize.width - (screenSize.width > 0 ? 8.0 : 0)) / 3, height: 32)
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
    case .spending:
      spendingLimitsView
    default:
      EmptyView()
    }
  }
  
  var spendingLimitsView: some View {
    VStack(alignment: .leading, spacing: 50) {
      transferLimitSection(
        type: TransferLimitSection.spendingLimit,
        transferSection: viewModel.spendingTransferLimitConfigs.spending
      )
      transferLimitSection(
        type: TransferLimitSection.financialInstitutionsLimit,
        transferSection: viewModel.spendingTransferLimitConfigs.financialInstitutionsSpending
      )
    }
  }
  
  var depositLimitsView: some View {
    VStack(alignment: .leading, spacing: 50) {
      transferLimitSection(
        type: TransferLimitSection.sendToCard,
        transferSection: viewModel.depositTransferLimitConfigs.sendToCard
      )
      transferLimitSection(
        type: TransferLimitSection.cardDeposit,
        transferSection: viewModel.depositTransferLimitConfigs.debitCard
      )
      transferLimitSection(
        type: TransferLimitSection.bankDeposit,
        transferSection: viewModel.depositTransferLimitConfigs.bankAccount
      )
    }
  }
  
  var withdrawLimitsView: some View {
    VStack(alignment: .leading, spacing: 50) {
      transferLimitSection(
        type: TransferLimitSection.cardWithdraw,
        transferSection: viewModel.withdrawTransferLimitConfigs.debitCard
      )
      transferLimitSection(
        type: TransferLimitSection.bankWithdraw,
        transferSection: viewModel.withdrawTransferLimitConfigs.bankAccount
      )
    }
  }
  
  @ViewBuilder func transferLimitSection(type: TransferLimitSection, transferSection: [TransferLimitConfig]) -> some View {
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
                // selectedAnnotation = type TODO: - Will be implemented later
              }
            }
        }
        transferLimitItem(
          title: TransferLimitConfig.TransferPeriod.day.title,
          value: transferSection.first { $0.period == .day }?.amount
        )
        transferLimitItem(
          title: TransferLimitConfig.TransferPeriod.week.title,
          value: transferSection.first { $0.period == .week }?.amount
        )
        transferLimitItem(
          title: TransferLimitConfig.TransferPeriod.month.title,
          value: transferSection.first { $0.period == .month }?.amount
        )
        transferLimitItem(
          title: TransferLimitConfig.TransferPeriod.perTransaction.title,
          value: transferSection.first { $0.period == .perTransaction }?.amount
        )
      }
      .overlay(alignment: .top) {
        annotationView(type: type)
      }
    }
  }
  
  @ViewBuilder func transferLimitItem(title: String, value: Double?) -> some View {
    if let limitAmount = value {
      VStack(spacing: 16) {
        HStack {
          Text(title)
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          Spacer()
          Text(limitAmount.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol))
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
  
  @ViewBuilder func annotationView(type: TransferLimitSection) -> some View {
    if let annotation = selectedAnnotation, selectedAnnotation == type {
      AnnotationView(
        description: annotation.message,
        corners: [.topRight, .bottomLeft, .bottomRight]
      )
      .offset(x: screenSize.width * 0.242, y: 28)
      .frame(width: screenSize.width * 0.52)
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
private extension TransferLimitsView {
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
