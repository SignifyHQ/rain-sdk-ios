import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFRewards
import Services
import GeneralFeature
import SolidFeature

struct RewardsView: View {
  @StateObject private var viewModel: RewardViewModel
  @State private var screenSize: CGSize = .zero
  
  private var emptySpaceHeight: CGFloat {
    // (main height - item height) / 2
    max(20, screenSize.height / 2 - 200)
  }
  
  private var item: UserRewardType {
    .cashBack
  }
  
  init(viewModel: RewardViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .track(name: String(describing: type(of: self)))
      .background(Colors.background.swiftUIColor)
      .refreshable {
        viewModel.refresh()
      }
      .readGeometry { geo in
        screenSize = geo.size
      }
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .transactions:
          TransactionListView(
            type: .cashback,
            currencyType: viewModel.currencyType,
            accountID: viewModel.fiatAccountID,
            transactionTypes: Constants.TransactionTypesRequest.rewardCashBack.types
          )
        case let .transactionDetail(transaction):
          TransactionDetailView(
            accountID: viewModel.fiatAccountID,
            transactionId: transaction.id,
            kind: .cashback,
            isPopToRoot: false
          )
        }
      }
  }
}

// MARK: - Private View Components
private extension RewardsView {
  var content: some View {
    Group {
      if viewModel.isFirstLoading {
        loadingView
      } else {
        ScrollView(showsIndicators: false) {
          VStack(spacing: 12) {
            header
            feed
            Spacer()
          }
          .padding(.vertical, 16)
          .padding(.horizontal, 30)
        }
      }
    }
  }
  
  var header: some View {
    HStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(Colors.background.swiftUIColor)
          .frame(64)
        if let image = item.image {
          image
            .resizable()
            .frame(38)
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(item.title ?? "")
          .font(Fonts.regular.swiftUIFont(size: 16))
          .foregroundColor(Colors.label.swiftUIColor)
        if item == .cashBack {
          Text(L10N.Common.UserRewardType.Cashback.description)
            .font(Fonts.regular.swiftUIFont(size: 12))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        } else {
          Text(item.subtitle(param: 0.75) ?? "")
            .font(Fonts.regular.swiftUIFont(size: 12))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        }
      }
      
      Spacer()
    }
    .padding(16)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  var feed: some View {
    Group {
      switch viewModel.feed {
      case let .success(items):
        transactions(items)
      default:
        transactions([])
      }
    }
  }
  
  var loadingView: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 45, height: 30)
    }
    .frame(max: .infinity)
  }
  
  var emptyView: some View {
    VStack(alignment: .center, spacing: 12) {
      Spacer(minLength: emptySpaceHeight)
      GenImages.Images.emptyRewards.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.horizontal, 40)
      Text(L10N.Common.RewardTabView.noRewards)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer(minLength: emptySpaceHeight)
    }
  }
  
  func transactions(_ items: [TransactionModel]) -> some View {
    Group {
      if items.isEmpty {
        emptyView
      } else {
        LazyVStack(alignment: .leading, spacing: 10) {
          HStack(alignment: .bottom) {
            Text(L10N.Common.Cashback.latest)
            Spacer()
            seeAllTransactions
              .opacity(items.isEmpty ? 0 : 1)
          }
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          ForEach(items) { transaction in
            TransactionRowView(item: transaction) {
              viewModel.transactionItemTapped(transaction)
            }
          }
        }
      }
    }
  }
  
  var seeAllTransactions: some View {
    Button {
      viewModel.seeAllTransactionsTapped()
    } label: {
      HStack(spacing: 8) {
        Text(L10N.Common.Cashback.seeAll)
        GenImages.CommonImages.icRightArrow.swiftUIImage
      }
      .frame(height: 30, alignment: .bottom)
    }
  }
}
