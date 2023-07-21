import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct DashboardView: View {
  @StateObject private var viewModel: DashboardViewModel
  
  init(option: TabOption, tabRedirection: @escaping ((TabOption) -> Void)) {
    _viewModel = .init(
      wrappedValue: DashboardViewModel(option: option, tabRedirection: tabRedirection)
    )
  }
  
  var body: some View {
    Group {
      switch viewModel.option {
      case .cash:
        CashView {
          viewModel.handleGuestUser()
        }
      case .rewards:
        EmptyView()
      case .assets:
        EmptyView()
      case .account:
        EmptyView()
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
      // .track(name: String(describing: type(of: self))) TODO: Will be implemented later
      //      .navigationLink(item: $viewModel.navigation) { navigation in
      //        switch navigation {
      //          case .directDeposit:
      //            LinkDirectDepositView()
      //          case .bankStatements:
      //            BankStatementsListView()
      //          case .referrals:
      //            ReferralsView()
      //          case let .addMoney(kind):
      //            MoveMoneyAccountView(kind: kind)
      //        }
      //      }
      //      .sheet(item: $viewModel.present) { item in
      //        switch item {
      //          case let .activateCardScreen(cardModel):
      //            ActivateCardView(cardDetails: cardModel)
      //          case .cashCardDetails:
      //            CardsDetailView(viewModel: .init())
      //              .embedInNavigation()
      //          case let .setCardPin(cardModel):
      //            SetCardPinView(cardDetails: cardModel, addCloseButton: true)
      //              .embedInNavigation()
      //          case let .pushNotification(viewModel):
      //            PushNotificationView(viewModel: viewModel)
      //              .embedInNavigation()
      //        }
      //      }
      //      .popup(item: $viewModel.popup) { popup in
      //        switch popup {
      //          case .createAccount:
      //            createAccountPopup
      //          case .inReview:
      //            inReviewPopup
      //          case .waitlistJoined:
      //            waitlistJoinedPopup
      //          case .notifications:
      //            notificationsPopup
      //        }
      //      }
    .onAppear {
      viewModel.appearOperations()
    }
  }
  
    //  private var createAccountPopup: some View {
    //    LiquidityAlert(
    //      title: "create_cardanoAccount".localizedString,
    //      message: "create_cardanoAccount_info".localizedString,
    //      primary: .init(text: "create_account".localizedString, action: viewModel.createAccountPopupPrimaryAction),
    //      secondary: .init(text: "backTo_guestMode".localizedString, action: viewModel.createAccountPopupSecondaryAction)
    //    )
    //  }
    //
    //  private var inReviewPopup: some View {
    //    LiquidityAlert(
    //      title: "inReview_popUp_title".localizedString,
    //      message: "inReview_popUp_sub_text".localizedString,
    //      primary: .init(text: "inReview_popUp_buttonTitle".localizedString, action: viewModel.inReviewPopupAction),
    //      secondary: nil
    //    )
    //  }
    //
    //  private var waitlistJoinedPopup: some View {
    //    LiquidityAlert(
    //      title: "waitlist_joined_title".localizedString,
    //      message: "waitlist_joined_message".localizedString,
    //      primary: .init(text: "ok".localizedString.uppercased(), action: viewModel.clearPopup),
    //      secondary: nil
    //    )
    //  }
    //
    //  private var notificationsPopup: some View {
    //    LiquidityAlert(
    //      title: "notify_alert_title".localizedString,
    //      message: "notify_alert_subtitle".localizedString,
    //      primary: .init(text: "notify_alert_action".localizedString, action: viewModel.notificationsPopupAction),
    //      secondary: .init(text: "notify_alert_dismiss".localizedString, action: viewModel.clearPopup)
    //    )
    //  }
}
