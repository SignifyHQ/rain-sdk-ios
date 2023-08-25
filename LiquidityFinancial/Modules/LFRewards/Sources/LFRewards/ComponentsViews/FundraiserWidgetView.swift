import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct FundraiserWidgetView: View {
  static let topNegativePadding: CGFloat = 64
  let fundraiser: FundraiserDetailModel
  let type: Kind
  @State private var showShare = false
  
  var body: some View {
    ZStack(alignment: .top) {
      image
      
      content
    }
    .sheet(isPresented: $showShare) {
      ShareView(viewModel: .init(data: .build(from: fundraiser)))
    }
  }
  
  private var image: some View {
    CachedAsyncImage(url: fundraiser.stickerUrl) { image in
      image
        .resizable()
        .scaledToFill()
        .clipShape(Circle())
        .applyIf(type == .small) {
          $0.overlay(Circle().stroke(ModuleColors.primary.swiftUIColor, lineWidth: 6))
        }
    } placeholder: {
      StickerPlaceholderView(overlay: .linear(ModuleColors.tertiaryBackground.swiftUIColor, 2))
    }
    .frame(width: type.size, height: type.size)
    .onTapGesture {
      showShare = true
    }
    .alignmentGuide(VerticalAlignment.top) {
      $0[VerticalAlignment.center] + Self.topNegativePadding - 50
    }
    .zIndex(1)
  }
  
  private var content: some View {
    VStack(spacing: 16) {
      VStack(spacing: 12) {
        Text(fundraiser.name)
          .font(Fonts.regular.swiftUIFont(size: 18))
          .foregroundColor(ModuleColors.label.swiftUIColor)
        
        Text(fundraiser.description)
          .font(Fonts.regular.swiftUIFont(size: 14))
          .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
      }
      .multilineTextAlignment(.center)
      
      FundraiserStatusView(fundraiser: fundraiser)
      
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(ModuleColors.label.swiftUIColor)
      
      FundraiserActionsView(fundraiser: fundraiser)
    }
    .padding(.top, 52)
    .padding([.horizontal, .bottom], 16)
    .frame(maxWidth: .infinity)
    .background(ModuleColors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
}

extension FundraiserWidgetView {
  enum Kind {
    case small
    case large
    
    var size: CGFloat {
      switch self {
      case .small:
        return 96
      case .large:
        return 120
      }
    }
  }
}
