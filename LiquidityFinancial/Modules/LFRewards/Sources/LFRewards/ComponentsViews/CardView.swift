import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct CardView: View {
  let type: Kind
  @State private var sheet: Sheet?
  
  var body: some View {
    content
      .onTapGesture {
        onTapGesture()
      }
      .sheet(item: $sheet) { item in
        switch item {
        case let .fundraiser(viewModel):
          ShareView(viewModel: viewModel)
        case let .activityItems(activityItems):
          ShareSheetView(activityItems: activityItems)
        }
      }
  }
  
  private var content: some View {
    VStack(spacing: 0) {
      top
      animation
      message
      share
    }
    .padding(.vertical, 40)
    .background(backgroundColor)
    .cornerRadius(32)
  }
  
  private var backgroundColor: Color {
    switch type {
    case .donation:
      return ModuleColors.separator.swiftUIColor.opacity(0.5)
    case .shareDonation(let data):
      return data.backgroundColor ?? ModuleColors.separator.swiftUIColor.opacity(0.5)
    case .cashback:
      return ModuleColors.secondaryBackground.swiftUIColor
    }
  }
  
  private var top: some View {
    Group {
      switch type {
      case .donation, .cashback:
        VStack(spacing: 8) {
          title
          amount
        }
      case let .shareDonation(data):
        Text(data.title)
          .font(Fonts.Montserrat.black.swiftUIFont(size: 24))
          .foregroundColor(type.foregroundColor)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(.horizontal, 20)
  }
  
  private var title: some View {
    Text(type.title ?? "unknown")
      .font(Fonts.medium.swiftUIFont(size: 16))
      .foregroundColor(type.foregroundColor)
  }
  
  private var amount: some View {
    Text(type.amount ?? "unknown")
      .font(Fonts.bold.swiftUIFont(size: 32))
      .foregroundColor(type.foregroundColor)
  }
  
  private var animation: some View {
    Group {
      switch type {
      case let .donation(data):
        fundraiserAnimation(url: data.fundraiserDetail.stickerUrl)
      case .cashback:
        cashbackAnimation
      case let .shareDonation(data):
        fundraiserAnimation(url: data.imageUrl)
      }
    }
  }
  
  private func fundraiserAnimation(url: URL?) -> some View {
    ZStack {
      LottieView(twinkle: .contrast)
        .frame(height: 160)
      CachedAsyncImage(url: url) { image in
        image
          .resizable()
          .scaledToFill()
          .clipShape(Circle())
          .overlay(Circle().stroke(ModuleColors.primary.swiftUIColor, lineWidth: 6))
      } placeholder: {
        StickerPlaceholderView(overlay: .linear(type.foregroundColor, 6))
      }
      .frame(width: 140, height: 140)
    }
    .padding(.top, 32)
    .padding(.bottom, 18)
  }
  
  private var cashbackAnimation: some View {
    ZStack {
      LottieView(twinkle: .sides)
      ModuleImages.bgCashbackCard.swiftUIImage
    }
    .frame(maxWidth: .infinity)
  }
  
  private var message: some View {
    Text(type.message ?? "unknown")
      .font(Fonts.medium.swiftUIFont(size: 14))
      .foregroundColor(type.foregroundColor)
      .lineSpacing(1.33)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .padding(.horizontal, 24)
  }
  
  private var share: some View {
    Group {
      switch type {
      case .donation, .cashback:
        FullSizeButton(title: LFLocalizable.FundraiserActions.share, isDisable: false, type: type.shareButtonType, fontSize: 12, cornerRadius: 32) {

        }
        .frame(height: 34)
        .padding(.horizontal, 40)
        .padding(.top, 16)
        .disabled(true)
      case .shareDonation:
        Spacer()
          .frame(height: 20)
      }
    }
  }
  
  @MainActor
  private func onTapGesture() {
    switch type {
    case let .donation(data):
      sheet = .fundraiser(.init(data: .build(from: data.fundraiserDetail, donation: data.donation)))
    case let .cashback(data):
      let reward = data.cashback.formattedUSDAmount(absoluteValue: true)
      let item = LFLocalizable.CardShare.cashback(reward, LFUtilities.shareAppUrl)
      sheet = .activityItems([item])
    case .shareDonation:
      break
    }
  }
}

private extension CardView.Kind {
  var title: String? {
    switch self {
    case .donation:
      return LFLocalizable.CardShare.Title.donation
    case .cashback:
      return LFLocalizable.CardShare.Title.cashback
    case .shareDonation:
      return nil
    }
  }
  
  var amount: String? {
    switch self {
    case let .donation(data):
      return data.donation.formattedUSDAmount(absoluteValue: true)
    case let .cashback(data):
      return data.cashback.formattedUSDAmount(absoluteValue: true)
    case .shareDonation:
      return nil
    }
  }
  
  var message: String? {
    switch self {
    case let .donation(data):
      return LFLocalizable.CardShare.Message.donation(data.fundraiserDetail.charityName, data.fundraiserDetail.name)
    case let .shareDonation(data):
      return data.includeDonation ? data.messageDonation : data.messageGeneric
    case .cashback:
      return nil
    }
  }
  
  var foregroundColor: Color {
    switch self {
    case .donation, .shareDonation:
      return ModuleColors.primary.swiftUIColor
    case .cashback:
      return ModuleColors.label.swiftUIColor
    }
  }
  
  var shareButtonType: FullSizeButton.Kind {
    switch self {
    case .donation, .shareDonation:
      return .tertiary
    case .cashback:
      return .primary
    }
  }
}

  // MARK: - Types

extension CardView {
  enum Kind {
    case donation(DonationData)
    case cashback(CashbackData)
    case shareDonation(ShareItemData.ShareDonationData)
  }
  
  struct DonationData {
    let fundraiserDetail: FundraiserDetailModel
    let donation: Double
  }
  
  struct CashbackData {
    let cashback: Double
  }
  
  enum Sheet: Identifiable {
    case fundraiser(ShareViewModel)
    case activityItems([Any])
    
    var id: String {
      switch self {
      case .fundraiser: return "share"
      case .activityItems: return "activityItems"
      }
    }
  }
}
