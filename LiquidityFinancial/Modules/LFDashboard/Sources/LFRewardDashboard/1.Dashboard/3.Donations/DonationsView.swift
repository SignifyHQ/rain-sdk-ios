import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFRewards
import LFTransaction
import Combine
import Services

struct DonationsView: View {
  @StateObject private var viewModel: DonationsViewModel
  @State private var screenSize: CGSize = .zero
  
  private var emptySpaceHeight: CGFloat {
    // (main height - item height) / 2
    max(20, screenSize.height / 2 - 280)
  }
  
  init(viewModel: DonationsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    Group {
      if viewModel.isLoading {
        loading
      } else {
        ScrollView(showsIndicators: false) {
          VStack(spacing: 8) {
            if let fundraiser = viewModel.selectedFundraiser {
              selectedFundraiser(fundraiser)
            } else {
              selectFundraiser
            }
            
            segmentControl
              .padding(.top, 12)
            
            feed
              .padding(.top, 8)
            Spacer()
          }
          .padding(.top, 16)
          .padding(.horizontal, 30)
        }
      }
    }
    .track(name: String(describing: type(of: self)))
    .background(Colors.background.swiftUIColor)
    .onAppear {
      viewModel.onAppear()
    }
    .refreshable {
      viewModel.refresh()
    }
    .readGeometry { geo in
      screenSize = geo.size
    }
    .sheet(isPresented: $viewModel.showRoundUpDonation, content: {
      RoundUpView(
        viewModel: RoundUpViewModel(onFinish: {
          viewModel.showRoundUpDonation.toggle()
        })
      )
    })
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .causeCategories(let causes):
        SelectCauseCategoriesView(
          viewModel: SelectCauseCategoriesViewModel(causes: causes),
          whereStart: .dashboard
        )
      case .transactionDetail(let donationID, let fundraisersID):
        TransactionDetailView(
          accountID: viewModel.accountDataManager.fiatAccountID,
          transactionId: donationID,
          fundraisersId: fundraisersID,
          kind: .donation,
          isPopToRoot: false
        )
      }
    }
  }
}

  // MARK: - Subviews

extension DonationsView {
  private var loading: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 45, height: 30)
    }
    .frame(max: .infinity)
  }
  
  private var selectFundraiser: some View {
    ZStack(alignment: .top) {
      VStack(spacing: 0) {
        Spacer()
          .frame(height: 72)
        VStack(spacing: 0) {
          Spacer()
            .frame(height: 105)
          FullSizeButton(title: LFLocalizable.Donations.selectFundraiser, isDisable: false) {
            viewModel.selectCharityTapped()
          }
          .padding(.horizontal, 16)
          .padding(.bottom, 16)
          .padding(.top, 8)
        }
        .background(Colors.secondaryBackground.swiftUIColor)
        .cornerRadius(10)
      }
      ModuleImages.bgSelectFundraiser.swiftUIImage
        .resizable()
        .frame(width: 315, height: 177)
    }
  }
  
  private func selectedFundraiser(_ fundraiser: FundraiserDetailModel) -> some View {
    VStack(spacing: 16) {
      FundraiserHeaderView(fundraiser: fundraiser, imageSize: 88, shareOnImageTap: true)
      GenImages.CommonImages.dash.swiftUIImage
        .resizable()
        .frame(height: 1)
        .foregroundColor(Colors.label.swiftUIColor)
      FundraiserActionsView(fundraiser: fundraiser)
    }
    .padding(16)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  private var segmentControl: some View {
    HStack(spacing: 0) {
      ForEach(DonationsViewModel.Option.allCases) { option in
        Text(option.title)
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(Colors.label.swiftUIColor.opacity(viewModel.selectedOption == option ? 1.0 : 0.5))
          .frame(height: 28)
          .frame(maxWidth: .infinity)
          .background(
            Rectangle()
              .fill(viewModel.selectedOption == option ? Colors.secondaryBackground.swiftUIColor : Colors.buttons.swiftUIColor)
              .cornerRadius(32)
          )
          .padding(4)
          .onTapGesture {
            withAnimation(.interactiveSpring()) {
              viewModel.selectedOption = option
            }
          }
      }
    }
    .frame(height: 32)
    .frame(maxWidth: .infinity)
    .background(Colors.buttons.swiftUIColor)
    .cornerRadius(32)
  }
  
  private var feed: some View {
    Group {
      switch viewModel.selectedOption {
      case .userDonations:
        handleFeed(feed: viewModel.contributionData)
      case .fundraiserDonations:
        handleFeed(feed: viewModel.latestDonationData)
      }
    }
  }
  
  private func handleFeed(feed: DataStatus<RewardTransactionRowModel>) -> some View {
    Group {
      switch feed {
      case .failure,
          .idle:
        transactions(items: [])
      case .loading:
        LottieView(loading: .mix)
          .frame(width: 30, height: 20)
      case let .success(items):
        transactions(items: items)
      }
    }
  }
  
  var emptyView: some View {
    VStack(alignment: .center, spacing: 12) {
      Spacer(minLength: emptySpaceHeight)
      GenImages.Images.emptyRewards.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.horizontal, 40)
      Text(LFLocalizable.RewardTabView.noRewards)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer(minLength: emptySpaceHeight)
    }
  }
  
  private func transactions(items: [RewardTransactionRowModel]) -> some View {
    Group {
      if items.isEmpty {
        emptyView
      } else {
        VStack(spacing: 10) {
          ForEach(items) { donation in
            RewardTransactionRow(item: donation) {
              viewModel.transactionItemTapped(
                donationID: donation.id,
                fundraisersID: donation.fundraiserId ?? .empty
              )
            }
          }
        }
      }
    }
  }
}
