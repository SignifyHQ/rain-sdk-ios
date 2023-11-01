import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct FundraiserHeaderView: View {
  let fundraiser: FundraiserDetailModel
  let imageSize: CGFloat
  let shareOnImageTap: Bool
  @State private var showDetails = false
  @State private var showShare = false
  
  public init(fundraiser: FundraiserDetailModel, imageSize: CGFloat = 80, shareOnImageTap: Bool = false) {
    self.fundraiser = fundraiser
    self.imageSize = imageSize
    self.shareOnImageTap = shareOnImageTap
  }
  
  public var body: some View {
    content
      .onTapGesture {
        showDetails = true
      }
      .navigationLink(isActive: $showDetails) {
        FundraiserDetailView(
          viewModel: FundraiserDetailViewModel(fundraiserDetail: fundraiser, whereStart: .dashboard),
          fundraiserDetailViewType: .view
        )
      }
      .sheet(isPresented: $showShare) {
        ShareView(viewModel: .init(data: .build(from: fundraiser)))
      }
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
      .fill(Colors.buttons.swiftUIColor.opacity(0.4))
      .frame(width: 24, height: 96)
      .cornerRadius(8)
      .overlay {
        GenImages.CommonImages.icRightArrow.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
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
      StickerPlaceholderView()
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
        .foregroundColor(Colors.label.swiftUIColor)
        .lineLimit(2)
        .layoutPriority(1)
      Text(fundraiser.description)
        .multilineTextAlignment(.leading)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .lineSpacing(1.17)
        .lineLimit(3)
    }
    .padding(.vertical, 8)
  }
}
