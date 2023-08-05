import SwiftUI

public struct FullSizeButton: View {
  @Binding var isLoading: Bool
  let type: Kind
  let title: String
  let isDisable: Bool
  let fontSize: CGFloat
  let height: CGFloat
  let cornerRadius: CGFloat
  let textColor: Color?
  let backgroundColor: Color?
  let action: () -> Void
  
  public init(
    title: String,
    isDisable: Bool,
    isLoading: Binding<Bool> = .constant(false),
    type: Kind = .primary,
    fontSize: CGFloat = 14.0,
    height: CGFloat = 40,
    cornerRadius: CGFloat = 10,
    textColor: Color? = nil,
    backgroundColor: Color? = nil,
    action: @escaping () -> Void
  ) {
    self.type = type
    self.title = title
    self.isDisable = isDisable
    self.textColor = textColor
    self.backgroundColor = backgroundColor
    self.fontSize = fontSize
    self.height = height
    self.cornerRadius = cornerRadius
    self.action = action
    _isLoading = isLoading
  }
  
  public var body: some View {
    ZStack {
      lottieAnimation
      buttonView
        .disabled(isDisable)
    }
  }
}

  // MARK: - View Components
private extension FullSizeButton {
  var lottieAnimation: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
    }
    .frame(height: height)
    .hidden(!isLoading)
  }
  
  var buttonView: some View {
    Button(action: action) {
      Text(title)
        .font(Fonts.bold.swiftUIFont(fixedSize: fontSize))
        .foregroundColor(textColor ?? buttonTextColor)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
    .frame(height: height)
    .applyIf(showGradientBackground) {
      $0.background(
        LinearGradient(
          gradient: Gradient(colors: linearGradientColor),
          startPoint: .bottomLeading,
          endPoint: .topTrailing
        )
        .opacity(isDisable ? 0.5 : 1.0)
      )
    }
    .applyIf(!showGradientBackground) {
      $0.background(backgroundColor ?? colorBackground)
    }
    .opacity(isDisable ? 0.5 : 1.0)
    .cornerRadius(cornerRadius)
    .hidden(isLoading)
  }
}

  // MARK: - Private Variables
private extension FullSizeButton {
  var buttonTextColor: Color {
    switch type {
    case .primary:
      return Colors.buttonText.swiftUIColor
    case .secondary, .tertiary:
      return Colors.label.swiftUIColor
    case .destructive:
      return Colors.error.swiftUIColor
    case .contrast:
      return Colors.primary.swiftUIColor
    case .white:
      return Colors.background.swiftUIColor
    }
  }
  
  var showGradientBackground: Bool {
    switch type {
    case .primary:
      return true
    case .contrast, .destructive, .secondary, .tertiary, .white:
      return false
    }
  }
  
  var colorBackground: Color {
    switch type {
    case .destructive, .secondary:
      return Colors.buttons.swiftUIColor
    case .tertiary:
      return Colors.secondaryBackground.swiftUIColor
    case .contrast:
      return Colors.buttons.swiftUIColor
    case .primary:
      return .clear
    case .white:
      return Colors.label.swiftUIColor
    }
  }
  
  var linearGradientColor: [Color] {
    guard let backgroundColor else {
      return [Colors.primary.swiftUIColor]
    }
    return [backgroundColor]
  }
}

  // MARK: - Types
public extension FullSizeButton {
  enum Kind {
    case primary
    case secondary
    case tertiary
    case destructive
    case contrast
    case white
  }
}
