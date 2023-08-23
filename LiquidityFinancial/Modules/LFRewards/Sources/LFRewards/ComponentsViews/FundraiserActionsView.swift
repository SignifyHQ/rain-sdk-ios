import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct FundraiserActionsView: View {
  let fundraiser: FundraiserDetailModel
  
  let canOpenDonation: Bool
  public init(fundraiser: FundraiserDetailModel, canOpenDonation: Bool = false) {
    self.fundraiser = fundraiser
    self.canOpenDonation = canOpenDonation
  }
  
  public var body: some View {
    content
      .sheet(isPresented: $share) {
        ShareView(viewModel: .init(data: .build(from: fundraiser)))
      }
      .navigationLink(item: $navigation) { navigation in
        switch navigation {
        case let .donate(fundraiserModel):
          DonationInputView(type: .buyDonation(fundraiser: fundraiserModel))
        case let .more(fundraiserModel):
          MoreWaysToSupportView(viewModel: MoreWaysToSupportViewModel(fundraiser: fundraiserModel))
        }
      }
  }
  
  @State private var share = false
  @State private var navigation: Navigation?
  
  private var content: some View {
    HStack(spacing: 10) {
      item(.share)
      if canOpenDonation {
        item(.donate)
      }
      item(.more)
    }
  }
  
  private func item(_ item: Item) -> some View {
    Button {
      action(for: item)
    } label: {
      HStack(spacing: 4) {
        item.image
        Text(item.title)
          .font(Fonts.bold.swiftUIFont(size: 12))
      }
      .minimumScaleFactor(0.75)
      .foregroundColor(ModuleColors.label.swiftUIColor)
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity)
      .background(ModuleColors.background.swiftUIColor)
      .cornerRadius(8)
    }
  }
  
  private func action(for item: Item) {
    switch item {
    case .share:
      share = true
    case .donate:
      navigation = .donate(fundraiser)
    case .more:
      navigation = .more(fundraiser)
    }
  }
  
  // swiftlint:disable force_unwrapping
  private var activityItems: [Any] {
    if let url = fundraiser.charityUrl {
      return [url]
    } else {
      return [URL(string: "https://liquidity.cc")!]
    }
  }
}

extension FundraiserActionsView {
  enum Item {
    case share
    case donate
    case more
    
    var image: Image {
      switch self {
      case .share:
        return ModuleImages.icShared.swiftUIImage
      case .donate:
        return ModuleImages.icDonate.swiftUIImage
      case .more:
        return ModuleImages.icMore.swiftUIImage
      }
    }
    
    var title: String {
      switch self {
      case .share:
        
        return LFLocalizable.FundraiserActions.share
      case .donate:
        return LFLocalizable.FundraiserActions.donate
      case .more:
        return LFLocalizable.FundraiserActions.more
      }
    }
  }
  
  enum Sheet: Identifiable {
    case share(activityItems: [Any])
    
    var id: String {
      switch self {
      case .share:
        return "share"
      }
    }
  }
}

private extension FundraiserActionsView {
  enum Navigation {
    case donate(FundraiserDetailModel)
    case more(FundraiserDetailModel)
  }
}
