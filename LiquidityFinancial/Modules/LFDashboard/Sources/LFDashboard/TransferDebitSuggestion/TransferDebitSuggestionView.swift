import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFBank

struct TransferDebitSuggestionView: View {
  @StateObject private var viewModel: TransferDebitSuggestionViewModel
  
  init(data: TransferDebitSuggestionViewModel.Data) {
    _viewModel = .init(wrappedValue: .init(data: data))
  }
  
  var body: some View {
    Group {
      if viewModel.shouldShow {
        ZStack(alignment: .top) {
          image
          content
        }
        .padding(.vertical, 20)
      }
    }
    .navigationLink(isActive: $viewModel.showDebitView) {
      AddBankWithDebitView()
    }
  }
}

// MARK: - View Components
private extension TransferDebitSuggestionView {
  var content: some View {
    VStack(alignment: .center) {
      Text(LFLocalizable.TransferDebitSuggestion.title)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.background.swiftUIColor)
      Spacer().frame(height: 12)
      Text(LFLocalizable.TransferDebitSuggestion.Body.title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.background.swiftUIColor)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
      Spacer().frame(height: 16)
      FullSizeButton(
        title: LFLocalizable.TransferDebitSuggestion.Connect.title,
        isDisable: false,
        type: .white,
        fontSize: Constants.FontSize.ultraSmall.value,
        height: 34,
        cornerRadius: 17
      ) {
        viewModel.connectTapped()
      }
    }
    .padding(.top, 120)
    .padding(.bottom, 24)
    .background(Colors.primary.swiftUIColor)
    .cornerRadius(32)
  }
  
  var image: some View {
    GenImages.Images.debitSuggestion.swiftUIImage
      .alignmentGuide(VerticalAlignment.top) {
        $0[VerticalAlignment.top] + 16
      }
      .zIndex(1)
  }
}
