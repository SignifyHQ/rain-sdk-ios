import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct FundraiserItemView: View {
  let fundraiser: FundraiserModel
  let imageSize: CGFloat
  let shareOnImageTap: Bool
  let destination: AnyView
  
  @State private var showDetails = false
  @State private var showShare = false

  init(fundraiser: FundraiserModel, imageSize: CGFloat = 80, shareOnImageTap: Bool = false, destination: AnyView) {
    self.fundraiser = fundraiser
    self.imageSize = imageSize
    self.shareOnImageTap = shareOnImageTap
    self.destination = destination
  }
  
  var body: some View {
    content
      .onTapGesture {
        showDetails = true
      }
      .navigationLink(isActive: $showDetails) {
        FundraiserDetailView(viewModel: FundraiserDetailViewModel(fundraiser: fundraiser), destination: destination)
      }
//      .sheet(isPresented: $showShare) {
//        ShareView(viewModel: .init(data: .build(from: fundraiser)))
//      }
  }
  
  private var content: some View {
    HStack(spacing: 12) {
      HStack(alignment: .top) {
        stickerImage
        nameDescription
      }
      Spacer()
      verticalButton
    }
    .padding(8)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  private var verticalButton: some View {
    Rectangle()
      .fill(ModuleColors.buttons.swiftUIColor.opacity(0.4))
      .frame(width: 24, height: 96)
      .cornerRadius(8)
      .overlay {
        GenImages.CommonImages.icRightArrow.swiftUIImage
          .foregroundColor(ModuleColors.label.swiftUIColor)
      }
  }
  
  private var stickerImage: some View {
    CachedAsyncImage(url: fundraiser.stickerUrl) { image in
      image
        .resizable()
        .scaledToFill()
        .frame(width: 80, height: 80)
        .clipShape(Circle())
    } placeholder: {
      StickerPlaceholderView(overlay: .gradient)
    }
    .frame(width: imageSize, height: imageSize)
    .applyIf(shareOnImageTap) {
      $0.onTapGesture {
        showShare = true
      }
    }
    .padding(.leading, 8)
  }
  
  private var nameDescription: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(fundraiser.name)
        .multilineTextAlignment(.leading)
        .font(Fonts.bold.swiftUIFont(size: 14))
        .foregroundColor(ModuleColors.label.swiftUIColor)
        .lineLimit(2)
        .layoutPriority(1)
      if let desc = fundraiser.description {
        Text(desc)
          .multilineTextAlignment(.leading)
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
          .lineSpacing(1.17)
          .lineLimit(3)
      }
    }
    .padding(.vertical, 8)
  }
}
