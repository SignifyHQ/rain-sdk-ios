import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFRewards

struct PrideCardCauseView: View {
  @StateObject private var viewModel: PrideCardCauseViewModel
  
  init(viewModel: PrideCardCauseViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case let .fundraiserDetail(fundraiserID):
          FundraiserDetailView(
            viewModel: FundraiserDetailViewModel(fundraiserID: fundraiserID, whereStart: .dashboard),
            fundraiserDetailViewType: .select
          )
        }
      }
      .popup(item: $viewModel.showError, style: .toast) { message in
        ToastView(toastMessage: message)
      }
  }
}
  
// MARK: - Private View Components
extension PrideCardCauseView {
  var content: some View {
    Group {
      switch viewModel.status {
      case .idle, .loading:
        loading
      case let .success(data):
        success(data: data)
      case .failure:
        failure
      }
    }
  }
  
  var loading: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 45, height: 30)
    }
    .frame(max: .infinity)
  }
  
  var failure: some View {
    VStack(spacing: 32) {
      Spacer()
      Text(LFLocalizable.Causes.error)
        .font(Fonts.medium.swiftUIFont(size: 14))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
      FullSizeButton(title: LFLocalizable.Causes.retry, isDisable: false) {
        viewModel.retryTapped()
      }
    }
    .padding(30)
    .frame(maxWidth: .infinity)
  }
  
  func success(data: [FundraiserModel]) -> some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 24) {
        Group {
          ForEach(data, id: \.id) { model in
            item(fundraiser: model)
          }
          SuggestCauseButton()
          DonationsDisclosureView()
        }
        .padding(.horizontal, 30)
      }
      .padding(.bottom, 16)
    }
    .padding(.top, 20)
  }
  
  func item(fundraiser: FundraiserModel) -> some View {
    VStack(spacing: 16) {
      FundraiserItemView(fundraiser: fundraiser) { fundraiserID in
        viewModel.selectedItem(fundraiserID: fundraiserID)
      }
    }
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  func title(text: String) -> some View {
    Text(text)
      .font(Fonts.regular.swiftUIFont(size: 12))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      .padding(.leading, 10)
  }
}
