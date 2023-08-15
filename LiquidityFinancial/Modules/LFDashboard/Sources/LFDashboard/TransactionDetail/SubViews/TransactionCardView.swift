import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct TransactionCardView: View {
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
}

private extension TransactionCardView.Kind {
  var title: String? {
    switch self {
    case .crypto:
      return LFLocalizable.TransactionCard.Crypto.title
    case .donation:
      return LFLocalizable.TransactionCard.Donation.title
    case .cashback:
      return LFLocalizable.TransactionCard.Cashback.title
    case .shareDonation:
      return nil
    }
  }
  
  var amount: String? {
    switch self {
    case let .crypto(data):
      return data.reward.formattedAmount(minFractionDigits: 3, maxFractionDigits: 3)
    case let .donation(data):
      return data.donation.formattedAmount(prefix: "$", minFractionDigits: 2, absoluteValue: true)
    case let .cashback(data):
      return data.cashback.formattedAmount(prefix: "$", minFractionDigits: 2, absoluteValue: true)
    case .shareDonation:
      return nil
    }
  }
  
  var message: String? {
    switch self {
    case let .crypto(data):
      let reward = data.reward.formattedAmount(minFractionDigits: 3, maxFractionDigits: 3)
      let purchase = data.purchase.formattedAmount(prefix: "$", minFractionDigits: 2, absoluteValue: true)
      return LFLocalizable.TransactionCard.Crypto.message(reward, purchase, LFUtility.appName)
    case let .donation(data):
      return LFLocalizable.TransactionCard.Donation.message(data.fundraiser.charity.name, data.fundraiser.name)
    case let .shareDonation(data):
      return data.includeDonation ? data.messageDonation : data.messageGeneric
    case .cashback:
      return nil
    }
  }
  
  var foregroundColor: Color {
    switch self {
    case .crypto:
      return Colors.buttons.swiftUIColor
    case .donation, .shareDonation:
      return Colors.primary.swiftUIColor
    case .cashback:
      return Colors.label.swiftUIColor
    }
  }
  
  var shareButtonType: FullSizeButton.Kind {
    switch self {
    case .crypto:
      return .white
    case .donation, .shareDonation:
      return .tertiary
    case .cashback:
      return .primary
    }
  }
}

// MARK: - Types
extension TransactionCardView {
  enum Kind {
    case crypto(CryptoData)
    case donation(DonationData)
    case cashback(CashbackData)
    case shareDonation(ShareDonationData)
  }
  
  struct CryptoData {
    let purchase: Double
    let reward: Double
  }
  
  struct DonationData {
    let fundraiser: Fundraiser
    let donation: Double
  }
  
  struct CashbackData {
    let cashback: Double
  }
  
  struct ShareDonationData {
    let title: String
    let messageGeneric: String
    let messageDonation: String
    let backgroundColor: Color?
    let imageUrl: URL?
    var includeDonation: Bool
    
    init(title: String, message: String, backgroundColor: Color?, imageUrl: URL? = nil) {
      self.title = title
      messageGeneric = message
      messageDonation = message
      self.backgroundColor = backgroundColor
      self.imageUrl = imageUrl
      includeDonation = false
    }
    
    init(fundraiser: Fundraiser, donation: Double?) {
      title = fundraiser.name
      backgroundColor = fundraiser.backgroundColor?.asHexColor
      imageUrl = fundraiser.sticker.url
      messageGeneric = LFLocalizable.TransactionCard.ShareDonationGeneric.message(fundraiser.charity.name, LFUtility.appName, fundraiser.name)
      if let donation {
        let amount = donation.formattedAmount(prefix: "$", minFractionDigits: 2, absoluteValue: true)
        messageDonation = LFLocalizable.TransactionCard.ShareDonationAmount.message(
          amount, fundraiser.charity.name, LFUtility.appName, fundraiser.name
        )
      } else {
        messageDonation = messageGeneric
      }
      includeDonation = false
    }
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

// MARK: - View Components
private extension TransactionCardView {
  var content: some View {
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
  
  var backgroundColor: Color {
    switch type {
    case .crypto:
      return Colors.primary.swiftUIColor
    case let .donation(data):
      return data.fundraiser.backgroundColor?.asHexColor ?? Colors.separator.swiftUIColor.opacity(0.5)
    case let .shareDonation(data):
      return data.backgroundColor ?? Colors.separator.swiftUIColor.opacity(0.5)
    case .cashback:
      return Colors.secondaryBackground.swiftUIColor
    }
  }
  
  var top: some View {
    Group {
      switch type {
      case .crypto, .donation, .cashback:
        VStack(spacing: 8) {
          title
          amount
        }
      case let .shareDonation(data):
        Text(data.title)
          .font(Fonts.black.swiftUIFont(size: 20))
          .foregroundColor(type.foregroundColor)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(.horizontal, 20)
  }
  
  @ViewBuilder var title: some View {
    if let title = type.title {
      Text(title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(type.foregroundColor)
    }
  }
  
  @ViewBuilder var amount: some View {
    if let amount = type.amount {
      Text(amount)
        .font(Fonts.bold.swiftUIFont(size: 32))
        .foregroundColor(type.foregroundColor)
    }
  }
  
  var animation: some View {
    Group {
      switch type {
      case .crypto:
        cryptoAnimation
      case let .donation(data):
        fundraiserAnimation(url: data.fundraiser.sticker.url)
      case .cashback:
        cashbackAnimation
      case let .shareDonation(data):
        fundraiserAnimation(url: data.imageUrl)
      }
    }
  }
  
  var cryptoAnimation: some View {
    ZStack {
      LottieView(twinkle: .contrast)
        .frame(height: 160)
      GenImages.Images.transactionCard.swiftUIImage
    }
  }
  
  func fundraiserAnimation(url: URL?) -> some View {
    ZStack {
      LottieView(twinkle: .contrast)
        .frame(height: 160)
      CachedAsyncImage(url: url) { image in
        image
          .resizable()
          .scaledToFill()
          .clipShape(Circle())
          .overlay(Circle().stroke(Colors.primary.swiftUIColor, lineWidth: 6))
      } placeholder: {
        StickerPlaceholderView(overlay: .linear(type.foregroundColor, 6))
      }
      .frame(width: 140, height: 140)
    }
    .padding(.top, 32)
    .padding(.bottom, 18)
  }
  
  var cashbackAnimation: some View {
    ZStack {
      LottieView(twinkle: .sides)
      GenImages.Images.cashbackCard.swiftUIImage
    }
    .frame(maxWidth: .infinity)
  }
  
  @ViewBuilder var message: some View {
    if let message = type.message {
      Text(message)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(type.foregroundColor)
        .lineSpacing(1.33)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 24)
    }
  }
  
  var share: some View {
    Group {
      switch type {
      case .crypto, .donation, .cashback:
        FullSizeButton(
          title: LFLocalizable.TransactionCard.Share.title,
          isDisable: false,
          type: type.shareButtonType,
          fontSize: 12,
          height: 34,
          cornerRadius: 32
        ) {}
            .padding(.top, 16)
            .disabled(true)
      case .shareDonation:
        Spacer()
          .frame(height: 20)
      }
    }
  }
}

// MARK: - View Helpers
extension TransactionCardView {
  @MainActor
  func onTapGesture() {
    switch type {
    case let .crypto(data):
      let reward = data.reward.formattedAmount(minFractionDigits: 3, maxFractionDigits: 3)
      let item = LFLocalizable.TransactionCard.ShareCrypto.title(reward, LFUtility.appName, LFUtility.shareAppUrl)
      sheet = .activityItems([item])
    case let .donation(data):
      sheet = .fundraiser(.init(data: .build(from: data.fundraiser, donation: data.donation)))
    case let .cashback(data):
      let reward = data.cashback.formattedAmount(prefix: "$", minFractionDigits: 2, absoluteValue: true)
      let item = LFLocalizable.TransactionCard.ShareCashback.title(reward, LFUtility.appName, LFUtility.shareAppUrl)
      sheet = .activityItems([item])
    case .shareDonation:
      break
    }
  }
}
