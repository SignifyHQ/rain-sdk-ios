import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import ExternalFundingData

public struct FundingAccountsView: View {
  @StateObject private var viewModel: FundingAccountsViewModel
  @Binding var achInformation: ACHModel
  
  public init(linkedContacts: [LinkedSourceContact], achInformation: Binding<ACHModel>) {
    _viewModel = .init(
      wrappedValue: FundingAccountsViewModel(linkedContacts: linkedContacts)
    )
    _achInformation = achInformation
  }
  
  public var body: some View {
    content
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(L10N.Common.FundingAccounts.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        }
      }
      .background(Colors.background.swiftUIColor)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .addMoney:
          MoveMoneyAccountView(kind: .receive)
        }
      }
      .sheet(item: $viewModel.plaidConfig) { item in
        PlaidLinkView(configuration: item.config)
      }
      .popup(item: $viewModel.popup) { item in
        switch item {
        case let .delete(data):
          deletePopup(linkedSource: data)
        case .plaidLinkingError:
          plaidLinkingErrorPopup
        }
      }
      .disabled(viewModel.isDisableView)
      .onAppear {
        viewModel.trackAccountViewAppear()
      }
  }
}

 // MARK: - Private View Components
private extension FundingAccountsView {
  var content: some View {
    VStack(spacing: 10) {
      if viewModel.isLoading {
        loading
      } else {
        if viewModel.linkedContacts.isNotEmpty {
          VStack(alignment: .leading, spacing: 12) {
            Text(L10N.Common.FundingAccounts.connected)
              .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            contacts
              .frame(maxWidth: .infinity)
          }
        }
        VStack(alignment: .leading, spacing: 12) {
          Text(L10N.Common.FundingAccounts.title)
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          AddFundsView(
            viewModel: viewModel.addFundsViewModel,
            achInformation: $achInformation,
            isDisableView: $viewModel.isDisableView,
            options: [.directDeposit, .oneTime]
          )
        }
      }
      Spacer()
        .frame(maxWidth: .infinity)
    }
    .padding(.horizontal, 30)
    .padding(.vertical, 20)
    .background(Colors.background.swiftUIColor)
  }
  
  var loading: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 30, height: 25)
        .padding(.top, 20)
    }
    .frame(maxWidth: .infinity)
  }

  var contacts: some View {
    Group {
      ForEach(viewModel.linkedContacts, id: \.sourceId) { item in
        ConnectedFundingAccountRow(sourceData: item) {
          viewModel.openDeletePopup(linkedSource: item)
        }
      }
    }
  }
  
  func deletePopup(linkedSource: LinkedSourceContact) -> some View {
    LiquidityAlert(
      title: L10N.Common.FundingAccounts.Delete.title.uppercased(),
      message: nil,
      primary: .init(text: L10N.Common.ConnectedView.DeletePopup.primaryButton) {
        viewModel.deleteAccount(id: linkedSource.sourceId)
      },
      secondary: .init(text: L10N.Common.Button.Close.title) {
        viewModel.hidePopup()
      },
      isLoading: $viewModel.isDeleting
    )
  }
  
  var plaidLinkingErrorPopup: some View {
    LiquidityAlert(
      title: L10N.Common.PlaidLink.Popup.title,
      message: L10N.Common.PlaidLink.Popup.description,
      primary: .init(
        text: L10N.Common.PlaidLink.ContactSupport.title,
        action: {
          viewModel.plaidLinkingErrorPrimaryAction()
        }
      )
    )
  }
}
