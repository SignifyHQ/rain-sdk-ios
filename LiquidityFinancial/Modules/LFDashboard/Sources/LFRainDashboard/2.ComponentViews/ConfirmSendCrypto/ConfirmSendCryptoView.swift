import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import ZerohashDomain
import Services
import GeneralFeature

struct ConfirmSendCryptoView: View {
  @StateObject private var viewModel: ConfirmSendCryptoViewModel
  private let completeAction: (() -> Void)?
  
  init(assetModel: AssetModel, amount: Double, address: String, nickname: String, feeLockedResponse: APILockedNetworkFeeResponse, completeAction: (() -> Void)? = nil) {
    _viewModel = .init(
      wrappedValue: ConfirmSendCryptoViewModel(
        assetModel: assetModel,
        amount: amount,
        address: address,
        nickname: nickname,
        feeLockedResponse: feeLockedResponse
      )
    )
    self.completeAction = completeAction
  }

  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(L10N.Common.ConfirmSendCryptoView.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case let .transactionDetail(transactionHash):
          TransactionDetailView(
            method: .transactionHash(transactionHash),
            kind: .crypto,
            isNewAddress: viewModel.nickname.isEmpty,
            walletAddress: viewModel.address,
            transactionInfo: viewModel.cryptoTransactions,
            popAction: {
              completeAction?()
            }
          )
        }
      }
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components

private extension ConfirmSendCryptoView {
  var content: some View {
    VStack(spacing: 16) {
      informationCell(
        title: L10N.Common.ConfirmSendCryptoView.amount,
        value: viewModel.amountInput,
        bonusValue: viewModel.assetModel.type?.title ?? .empty
      )
      if !viewModel.nickname.isEmpty {
        informationCell(
          title: L10N.Common.ConfirmSendCryptoView.to,
          value: viewModel.nickname
        )
      }
      informationCell(
        title: L10N.Common.ConfirmSendCryptoView.walletAddress,
        value: viewModel.address,
        isLastItem: true
      )
      informationCell(
        title: L10N.Common.ConfirmSendCryptoView.fee,
        value: viewModel.fee.formattedAmount(minFractionDigits: 2, maxFractionDigits: 18)
      )
      Spacer()
      footer
    }
    .padding(.top, 30)
    .padding(.horizontal, 30)
  }
  
  var footer: some View {
    VStack(spacing: 16) {
      continueButton
      VStack(spacing: 12) {
        cryptoDisclosure
        estimatedFeeDescription
      }
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

  func informationCell(title: String, value: String, bonusValue: String? = nil, isLastItem: Bool = false) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      HStack(spacing: 4) {
        Text(value)
          .foregroundColor(Colors.label.swiftUIColor)
        if let bonusValue = bonusValue {
          Text(bonusValue)
            .foregroundColor(Colors.primary.swiftUIColor)
        }
        Spacer()
      }
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      GenImages.CommonImages.dash.swiftUIImage
        .resizable()
        .scaledToFit()
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.top, 4)
        .opacity(isLastItem ? 0 : 1)
    }
  }
  
  @ViewBuilder var cryptoDisclosure: some View {
    Text(L10N.Common.Zerohash.Disclosure.description)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .fixedSize(horizontal: false, vertical: true)
  }
  
  @ViewBuilder var estimatedFeeDescription: some View {
    Text(L10N.Common.MoveCryptoInput.Send.estimatedFee)
      .multilineTextAlignment(.center)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .fixedSize(horizontal: false, vertical: true)
  }
}
