import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

struct TransactionCardView: View {
  @State private var isPresentShareSheetView = false
  let information: TransactionCardInformation
  
  var body: some View {
    VStack(spacing: 4) {
      headerTitle
      imageView
      message
      Button {
        // Temporarily hidden
      } label: {
        Text(LFLocalizable.TransactionCard.Share.title)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(shareTextColor)
      }
      .frame(width: 112, height: 34)
      .background(
        LinearGradient(
          gradient: Gradient(colors: shareBackgroundColor),
          startPoint: .bottomLeading,
          endPoint: .topTrailing
        )
        .cornerRadius(32)
      )
      .padding(.top, 12)
    }
    .onTapGesture {
      isPresentShareSheetView = true
    }
    .sheet(isPresented: $isPresentShareSheetView) {
      ShareSheetView(activityItems: [information.activityItem])
    }
    .padding(.vertical, 40)
    .background(information.backgroundColor)
    .cornerRadius(32)
  }
}

// MARK: - View Components
private extension TransactionCardView {
  var headerTitle: some View {
    VStack(spacing: 8) {
      Text(information.title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
      Text(information.rewardAmount)
        .font(Fonts.bold.swiftUIFont(size: 32))
    }
    .foregroundColor(textColor)
  }
  
  var cryptoImageView: some View {
    ZStack {
      LottieView(twinkle: .contrast)
        .frame(height: 160)
      GenImages.Images.transactionCard.swiftUIImage
    }
  }
  
  var donationImageView: some View {
    ZStack {
      LottieView(twinkle: .contrast)
        .frame(height: 160)
      if let stickerUrl = information.stickerUrl {
        CachedAsyncImage(url: URL(string: stickerUrl)) { image in
          image
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .overlay(Circle().stroke(Colors.contrast.swiftUIColor, lineWidth: 6))
        } placeholder: {
          StickerPlaceholderView(overlay: .linear(Colors.contrast.swiftUIColor, 6))
        }
        .frame(140)
      }
    }
    .padding(.top, 32)
    .padding(.bottom, 18)
  }
  
  var cashbackImageView: some View {
    ZStack {
      LottieView(twinkle: .sides)
      GenImages.Images.cashbackCard.swiftUIImage
    }
    .frame(maxWidth: .infinity)
  }
  
  var imageView: some View {
    Group {
      switch information.cardType {
      case .crypto:
        cryptoImageView
      case .donation:
        donationImageView
      case .cashback:
        cashbackImageView
      default:
        EmptyView()
      }
    }
  }
  
  @ViewBuilder var message: some View {
    if information.cardType != .cashback {
      Text(information.message)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(textColor)
        .lineSpacing(1.33)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 24)
    }
  }
}

// MARK: - View Helpers
private extension TransactionCardView {
  var shareBackgroundColor: [Color] {
    switch information.cardType {
    case .cashback:
      return [
        Colors.Gradients.Button.gradientButton0.swiftUIColor,
        Colors.Gradients.Button.gradientButton1.swiftUIColor
      ]
    default:
      return [Colors.whiteText.swiftUIColor]
    }
  }
  
  var shareTextColor: Color {
    switch information.cardType {
    case .cashback:
      return Colors.whiteText.swiftUIColor
    default:
      return Colors.darkText.swiftUIColor
    }
  }
  
  var textColor: Color {
    switch information.cardType {
    case .cashback:
      return Colors.darkText.swiftUIColor
    default:
      return Colors.contrast.swiftUIColor
    }
  }
}
