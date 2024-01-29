import SwiftUI
import LFRewards
import LFStyleGuide

public struct StickerView: View {
  @State private var showShare = false
  let type: Kind
  let sticker: Sticker
  
  public init(showShare: Bool = false, type: Kind, sticker: Sticker) {
    self.showShare = showShare
    self.type = type
    self.sticker = sticker
  }
  
  public var body: some View {
    ZStack(alignment: type == .profile ? .topTrailing : .top) {
      image
      counter
    }
    .onTapGesture {
      showShare = true
    }
    .sheet(isPresented: $showShare) {
      ShareView(viewModel: .init(
        data: .build(
          sticker: StickerModel(
            id: sticker.id,
            name: "",
            url: sticker.stickerUrl,
            count: sticker.donationCount,
            backgroundColor: nil,
            charityName: nil
          )
        )
      ))
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
public extension StickerView {
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
