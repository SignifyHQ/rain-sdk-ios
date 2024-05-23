import SwiftUI
import NetSpendData
import LFStyleGuide
import LFUtilities
import LFLocalizable
import NetspendSdk
import GeneralFeature

public struct SelectBankAccountView: View {
  @StateObject private var viewModel: SelectBankAccountViewModel
  private let completeAction: (() -> Void)?
  
  public init(
    linkedAccount: [APILinkedSourceData],
    kind: MoveMoneyAccountViewModel.Kind,
    amount: String,
    completeAction: (() -> Void)?
  ) {
    _viewModel = .init(
      wrappedValue: SelectBankAccountViewModel(
        linkedAccount: linkedAccount,
        amount: amount,
        kind: kind
      )
    )
    self.completeAction = completeAction
  }
  
  public var body: some View {
    content
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(L10N.Common.SelectBankAccount.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            viewModel.addNewBankAccount()
          } label: {
            CircleButton(style: .plus)
          }
        }
      }
      .popup(item: $viewModel.popup) { item in
        switch item {
        case .limitReached:
          depositLimitReachedPopup
        }
      }
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .disabled(viewModel.isDisableView)
      .background(Colors.background.swiftUIColor)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case let .transactionDetai(id):
          TransactionDetailView(
            method: .transactionID(id),
            kind: viewModel.kind == .receive ? .deposit : .withdraw,
            popAction: completeAction
          )
        }
      }
  }
  
  private var content: some View {
    ZStack {
      VStack(spacing: 10) {
        if viewModel.isLoading {
          Spacer()
          loading
          Spacer()
        } else if viewModel.linkedBanks.isEmpty {
          Spacer()
          emptyView
          Spacer()
        } else {
          contacts
          Spacer()
            .frame(maxWidth: .infinity)
          bottomView
        }
      }
      .padding(.horizontal, 30)
      .padding(.vertical, 20)
      .background(Colors.background.swiftUIColor)
      externalLinkBank(controller: viewModel.netspendController)
    }
  }
  
  @ViewBuilder func externalLinkBank(controller: NetspendSdkViewController?) -> some View {
    if let controller {
      ExternalLinkBankViewController(
        controller: controller,
        onSuccess: viewModel.onLinkExternalBankSuccess,
        onFailure: viewModel.onLinkExternalBankFailure,
        onCancelled: viewModel.onPlaidUIDisappear
      )
    }
  }
  
  private var loading: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 30, height: 25)
        .padding(.top, 20)
    }
    .frame(maxWidth: .infinity)
  }
  
  var emptyView: some View {
    Group {
      VStack(alignment: .center, spacing: 24) {
        GenImages.Images.connectBankBanner.swiftUIImage
        FullSizeButton(
          title: L10N.Common.SelectBankAccount.connectABank,
          isDisable: false,
          isLoading: $viewModel.linkBankIndicator
        ) {
          viewModel.addNewBankAccount()
        }.padding(.horizontal, 20)
      }
      .fixedSize(horizontal: false, vertical: false)
    }
  }
  
  private var contacts: some View {
    Group {
      ForEach(viewModel.linkedBanks, id: \.sourceId) { item in
        bankRow(for: item)
      }
    }
  }
  
  var bottomView: some View {
    FullSizeButton(
      title: L10N.Common.Button.Continue.title,
      isDisable: viewModel.selectedBank == nil,
      isLoading: $viewModel.showIndicator
    ) {
      viewModel.continueTapped()
    }
  }
  
  @ViewBuilder
  func bankRow(for bank: APILinkedSourceData) -> some View {
    Button {
      viewModel.selectedBank = bank
    } label: {
      HStack(spacing: 8) {
        GenImages.CommonImages.Accounts.connectedAccounts.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        HStack(spacing: 8) {
          Text(viewModel.title(for: bank))
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.label.swiftUIColor)
        }
        Spacer()
        if let selectedBank = viewModel.selectedBank, selectedBank.sourceId == bank.sourceId {
          GenImages.Images.icKycQuestionCheck.swiftUIImage
            .scaledToFit()
            .frame(width: 20, height: 20)
            .padding(.trailing, 20)
        } else {
          Ellipse()
            .foregroundColor(.clear)
            .frame(width: 20, height: 20)
            .overlay(
              Ellipse()
                .inset(by: 0.50)
                .stroke(.white, lineWidth: 1)
            )
            .opacity(0.25)
            .padding(.trailing, 20)
        }
      }
    }
    .padding(.horizontal, 12)
    .frame(height: 56)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(9)
  }
  
  var depositLimitReachedPopup: some View {
    LiquidityAlert(
      title: L10N.Common.TransferView.LimitsReachedPopup.title,
      message: L10N.Common.TransferView.LimitsReachedPopup.message,
      primary: .init(
        text: L10N.Common.Button.ContactSupport.title,
        action: {
          viewModel.contactSupport()
        }
      ),
      secondary: .init(
        text: L10N.Common.Button.Skip.title,
        action: {
          viewModel.hidePopup()
        }
      )
    )
  }
}
