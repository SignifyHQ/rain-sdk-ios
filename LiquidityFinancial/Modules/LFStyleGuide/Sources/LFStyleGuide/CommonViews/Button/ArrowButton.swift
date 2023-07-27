import SwiftUI
import LFUtilities

public struct ArrowButton: View {
  public init(
    image: ImageAsset?,
    title: String,
    value: String?,
    trailingImage: ImageAsset? = nil,
    isLoading: Binding<Bool> = .constant(false),
    action: @escaping () -> Void = {}
  ) {
    self.image = image
    self.title = title
    self.value = value
    self.trailingImage = trailingImage
    _isLoading = isLoading
    self.action = action
  }
  
  let image: ImageAsset?
  let title: String
  let value: String?
  let trailingImage: ImageAsset?
  @Binding var isLoading: Bool
  
  let action: () -> Void
  
  public var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        leadingView
        Spacer()
        trailingView
      }
      .padding(.leading, 16)
      .padding(.trailing, 12)
      .frame(height: 56)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(10)
    }
  }
}

// MARK: - View Components
private extension ArrowButton {
  var leadingView: some View {
    HStack(spacing: 12) {
      if let image {
        image.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
      }
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
        if let value {
          Text(value)
            .font(Fonts.Inter.regular.swiftUIFont(size: 10))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            .lineLimit(1)
        }
      }
    }
  }
  
  @ViewBuilder var trailingView: some View {
    if isLoading {
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
    } else if let trailingImage {
      trailingImage.swiftUIImage
        .resizable()
        .frame(20)
        .foregroundColor(Colors.label.swiftUIColor)
    } else {
      CircleButton(style: .right)
    }
  }
}
