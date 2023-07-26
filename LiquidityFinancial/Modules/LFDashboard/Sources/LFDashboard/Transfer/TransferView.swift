import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct TransferView: View {
  @StateObject private var viewModel: TransferViewModel
  
  @Environment(\.dismiss) private var dismiss

  init(viewModel: TransferViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }

  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .defaultToolBar(icon: .both, navigationTitle: viewModel.navigationTitle, openIntercom: {
        // TODO: Will be implemeted later
        // intercomService.openIntercom()
      })
      .navigationBarBackButtonHidden(true)
  }

  private var content: some View {
    VStack(spacing: 0) {
      Text(viewModel.title)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.top, 44)

      Text(viewModel.transfer.transactionDateInLocalZone)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.60))
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .center)

      Text(viewModel.amount)
        .font(Fonts.Inter.bold.swiftUIFont(size: 50))
        .foregroundColor(viewModel.amountColor)
        .padding(.top, 24)
        .frame(maxWidth: .infinity, alignment: .center)

      Text(viewModel.subtitle)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.60))
        .padding(.top, 8)
        .frame(maxWidth: .infinity, alignment: .center)

      GenImages.CommonImages.dash.swiftUIImage
        .resizable()
        .scaledToFit()
        .padding(.top, 32)

      TransferStatusView(data: .build(from: viewModel.transfer))
        .padding(.top, 32)

      Spacer()

      HStack(spacing: 4) {
        (viewModel.isPending ? GenImages.Images.statusPending : GenImages.Images.statusCompleted).swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)

        Text(
          viewModel.isPending ? TransactionStatus.pending.localizedDescription() :
            TransactionStatus.completed.localizedDescription()
        )
        .font(Fonts.Inter.medium.swiftUIFont(size: 14))
        .foregroundColor(Colors.label.swiftUIColor)
      }
      .padding(.bottom, 16)
    }
    .scrollOnOverflow()
  }
}
