import LFUtilities
import LFStyleGuide
import LFLocalizable
import SwiftUI

public struct SearchCausesView: View {
  public var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(LFLocalizable.SearchCauses.navigationTitle)
            .font(Fonts.regular.swiftUIFont(size: 16))
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      .onTapGesture {
        keyboardFocus = false
      }
  }
  
  public init(viewModel: SearchFundraiserViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  @StateObject private var viewModel: SearchFundraiserViewModel
  @FocusState private var keyboardFocus: Bool
  
  private var content: some View {
    VStack(spacing: 16) {
      SearchBar(searchText: $viewModel.searchText)
        .padding(.horizontal, 30)
        .task {
          keyboardFocus = true
        }
        .focused($keyboardFocus)
      
      switch viewModel.pagingState {
      case .idle, .failure:
        Spacer()
      case .loadingFirstPage:
        loading
      case .loaded, .loadingNextPage:
        results
      }
    }
    .padding(.vertical, 12)
  }
  
  private var loading: some View {
    Group {
      LottieView(loading: .mix)
        .frame(width: 30, height: 20)
    }
    .frame(max: .infinity)
  }
  
  private var noResults: some View {
    VStack(spacing: 8) {
      Spacer()
      Image(systemName: "magnifyingglass")
      Text(LFLocalizable.SearchCauses.noResults)
        .font(Fonts.regular.swiftUIFont(size: 12))
      Spacer()
    }
    .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
  }
  
  private var results: some View {
    Group {
      if viewModel.fundraisers.isEmpty {
        noResults
      } else {
        ScrollView {
          LazyVStack(spacing: 16) {
            ForEach(viewModel.fundraisers) { item in
              itemFundraiserView(fundraiser: item)
            }
            loadingIndicator
          }
          .padding(.horizontal, 30)
        }
      }
    }
  }
  
  private func itemFundraiserView(fundraiser: FundraiserModel) -> some View {
    VStack(spacing: 16) {
      FundraiserItemView(fundraiser: fundraiser, whereStart: .onboarding)
    }
    .background(ModuleColors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  private var loadingIndicator: some View {
    Group {
      if viewModel.pagingState == .loadingNextPage {
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
          .padding(.top, 6)
      }
    }
  }
}
