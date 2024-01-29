import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFRewards
import Services

public struct CausesView: View {
  @StateObject private var viewModel: CausesViewModel
  
  public init(viewModel: CausesViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  public var body: some View {
    content
      .track(name: String(describing: type(of: self)))
      .background(Colors.background.swiftUIColor)
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case let .fundraiserDetail(fundraiserID):
          FundraiserDetailView(
            viewModel: FundraiserDetailViewModel(fundraiserID: fundraiserID, whereStart: .dashboard),
            fundraiserDetailViewType: .select
          )
        case .selectFundraiser(let causeModel, let fundraisers):
          SelectFundraiserView(
            viewModel: SelectFundraiserViewModel(causeModel: causeModel, fundraisers: fundraisers, showSkipButton: false),
            whereStart: .dashboard
          )
        }
      }
      .popup(item: $viewModel.showError, style: .toast) { _ in
        ToastView(toastMessage: L10N.Common.genericErrorMessage)
      }
  }
}
  
// MARK: - Private View Components
private extension CausesView {
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
      Text(L10N.Common.Causes.error)
        .font(Fonts.medium.swiftUIFont(size: 14))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
      FullSizeButton(title: L10N.Common.Causes.retry, isDisable: false) {
        viewModel.retryTapped()
      }
    }
    .padding(30)
    .frame(maxWidth: .infinity)
  }
  
  func success(data: CausesViewModel.Data) -> some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 24) {
        if !data.trending.isEmpty {
          trending(items: data.trending)
        }
        Group {
          explore(items: data.causes)
          DonationsDisclosureView()
        }
        .padding(.horizontal, 30)
      }
      .padding(.bottom, 16)
    }
    .disabled(viewModel.isLoadingFundraisers != nil)
    .padding(.top, 20)
  }
  
  private func trending(items: [CategoriesTrendingModel]) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      title(text: L10N.Common.Causes.trending)
        .padding(.horizontal, 30)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 6) {
          ForEach(items) { item in
            trendingItem(item: item)
          }
          Spacer().frame(width: 30)
        }
        .padding(.leading, 30)
      }
    }
  }
  
  func explore(items: [CauseModel]) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      title(text: L10N.Common.Causes.explore)
      exploreGrid(items: items)
    }
  }
  
  func exploreGrid(items: [CauseModel]) -> some View {
    LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 3), spacing: 12) {
      ForEach(items) { cause in
        Button {
          viewModel.selected(cause: cause)
        } label: {
          CauseItemView(cause: cause, isLoading: viewModel.isLoadingFundraisers == cause)
        }
      }
    }
  }
  
  func trendingItem(item: CategoriesTrendingModel) -> some View {
    Button {
      viewModel.selected(fundraiser: item)
    } label: {
      ZStack(alignment: .topTrailing) {
        fundraiserItem(item: item)
          .frame(maxWidth: 200)
        newBadge
      }
    }
    .padding(.trailing, 6)
  }
  
  func fundraiserItem(item: CategoriesTrendingModel) -> some View {
    HStack(spacing: 12) {
      CachedAsyncImage(url: item.stickerURL) { image in
        image
          .resizable()
          .scaledToFill()
          .clipShape(Circle())
      } placeholder: {
        Circle()
          .fill(Colors.primary.swiftUIColor)
      }
      .frame(width: 32, height: 32)
      
      VStack(alignment: .leading, spacing: 2) {
        if let name = viewModel.getCauseName(from: item.id ?? "") {
          Text(name)
            .font(Fonts.regular.swiftUIFont(size: 10))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        }
        
        Text(item.name ?? "")
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(Colors.label.swiftUIColor)
      }
      .lineLimit(1)
    }
    .padding(12)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
    .padding(.top, 6)
  }
  
  var newBadge: some View {
    Text(L10N.Common.Causes.new)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor)
      .padding(.horizontal, 6)
      .padding(.vertical, 4)
      .background(Color.red)
      .cornerRadius(16)
      .padding(.trailing, -6)
  }
  
  func title(text: String) -> some View {
    Text(text)
      .font(Fonts.regular.swiftUIFont(size: 12))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      .padding(.leading, 10)
  }
}
