import Foundation
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import RainFeature
import GeneralFeature

struct ConfirmBuySellCryptoView: View {
  
  @StateObject var viewModel: ConfirmBuySellCryptoViewModel
  
  init(viewModel: ConfirmBuySellCryptoViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    contentView
      .background(Colors.background.swiftUIColor)
      .navigationBarTitleDisplayMode(.inline)
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .sellTransactionDetail(let entity):
          TransactionDetailView(
            accountID: entity.accountID,
            transactionId: entity.id ?? "",
            kind: .crypto,
            transactionInfo: [
              TransactionInformation(title: L10N.Common.TransactionDetail.TransactionType.title, value: L10N.Common.TransactionDetail.Sell.title),
              TransactionInformation(title: L10N.Common.TransactionDetail.Fee.title, value: "0", markValue: Constants.CurrencyUnit.usd.rawValue)
            ]
          )
        case .buyTransactionDetail(let entity):
          TransactionDetailView(
            accountID: entity.accountID,
            transactionId: entity.id ?? "",
            kind: .crypto,
            transactionInfo: [
              TransactionInformation(title: L10N.Common.TransactionDetail.TransactionType.title, value: L10N.Common.TransactionDetail.Buy.title),
              TransactionInformation(title: L10N.Common.TransactionDetail.Fee.title, value: "0", markValue: Constants.CurrencyUnit.usd.rawValue)
            ]
          )
        }
      }
      .track(name: String(describing: type(of: self)))
  }
  
}

// MARK: View Components
extension ConfirmBuySellCryptoView {
  var contentView: some View {
    VStack(spacing: 40) {
      titleView
      detailsView
      footerView
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 20)
  }
  
  var titleView: some View {
    Text(viewModel.title)
      .font(Fonts.Lato.regular.swiftUIFont(size: 18))
      .foregroundColor(Colors.label.swiftUIColor)
      .padding(.horizontal, 30)
      .multilineTextAlignment(.center)
  }
  
  var detailsView: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 12) {
        ForEach(viewModel.details) { detail in
          ConfirmBuySellCryptoView.InformationCell(
            item: detail,
            isHideDashDivider: detail.id == viewModel.details.last?.id
          )
        }
      }
    }
  }
  
  var footerView: some View {
    VStack(spacing: 16) {
      sellBuyDisclosure
        .padding(.bottom, 10)
      continueButton
      cryptoDisclosure
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: L10N.Common.Button.Confirm.title,
      isDisable: false,
      isLoading: $viewModel.showIndicator
    ) {
      viewModel.confirmButtonClicked()
    }
  }
  
  var sellBuyDisclosure: some View {
    Text(viewModel.disclosure)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .fixedSize(horizontal: false, vertical: true)
  }

  var cryptoDisclosure: some View {
    Text(L10N.Common.Zerohash.Disclosure.description)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .fixedSize(horizontal: false, vertical: true)
  }
}

extension ConfirmBuySellCryptoView {
  struct InformationCell: View {
    let item: ConfirmBuySellCryptoViewModel.RowDetail
    let isHideDashDivider: Bool
    
    init(item: ConfirmBuySellCryptoViewModel.RowDetail, isHideDashDivider: Bool) {
      self.item = item
      self.isHideDashDivider = isHideDashDivider
    }
    
    var body: some View {
      VStack(spacing: 20) {
        HStack(spacing: 2) {
          Text(item.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          Spacer()
          Text(item.value)
            .foregroundColor(item.valueColor)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
        GenImages.CommonImages.dash.swiftUIImage
          .resizable()
          .scaledToFit()
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.top, 4)
          .opacity(isHideDashDivider ? 0 : 1)
      }
    }
  }
}
