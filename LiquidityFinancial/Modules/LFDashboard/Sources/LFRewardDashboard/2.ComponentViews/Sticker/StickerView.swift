import SwiftUI
import LFStyleGuide

struct StickerView: View {
  @State private var showShare = false
  let type: Kind
  let sticker: Sticker
  
  var body: some View {
    ZStack(alignment: type == .profile ? .topTrailing : .top) {
      image
      counter
    }
    .onTapGesture {
      showShare = true
    }
    .sheet(isPresented: $showShare) {
      EmptyView() // TODO: Will be implemented later
    }
  }
  
  private var image: some View {
    CachedAsyncImage(url: sticker.stickerUrl) { image in
      image
        .resizable()
        .scaledToFill()
        .clipShape(Circle())
    } placeholder: {
      StickerPlaceholderView()
    }
    .frame(type == .profile ? 80 : 140)
    .padding(.top, sticker.donationCount == nil ? 0 : type.imageTopPadding)
  }
  
  private var counter: some View {
    Group {
      if let count = sticker.donationCount {
        ZStack {
          Circle()
            .strokeBorder(Colors.background.swiftUIColor, lineWidth: type == .profile ? 2 : 4)
            .background(
              Circle()
                .foregroundColor(Colors.primary.swiftUIColor)
            )
            .frame(type == .profile ? 24 : 48)
          Text("\(count)")
            .font(Fonts.bold.swiftUIFont(size: type == .profile ? 10 : 20))
            .foregroundColor(Colors.secondaryBackground.swiftUIColor)
        }
      }
    }
  }
}

// MARK: - Types
extension StickerView {
  enum Kind {
    case profile
    case transaction
    
    var imageTopPadding: CGFloat {
      switch self {
      case .profile:
        return 0
      case .transaction:
        return 24
      }
    }
  }
}
