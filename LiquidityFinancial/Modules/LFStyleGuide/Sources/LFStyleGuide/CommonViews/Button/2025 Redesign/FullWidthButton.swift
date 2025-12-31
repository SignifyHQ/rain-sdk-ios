import SwiftUI
import LFUtilities

public struct FullWidthButton: View {
  @Binding var isLoading: Bool
  
  let type: Kind
  let height: CGFloat
  let cornerRadius: CGFloat
  let tintColor: Color?
  let backgroundColor: Color?
  let borderColor: Color?
  let icon: Image?
  let iconPlacement: IconPlacement
  let title: String
  let font: SwiftUICore.Font
  let contentAlignment: ContentAlignment
  let isDisabled: Bool
  let titlePadding: CGFloat
  let action: () -> Void
  
  public init(
    type: Kind = .primary,
    height: CGFloat = 48,
    cornerRadius: CGFloat = 24,
    tintColor: Color? = nil,
    backgroundColor: Color? = nil,
    borderColor: Color? = nil,
    icon: Image? = nil,
    iconPlacement: IconPlacement = .leading(spacing: 4),
    title: String,
    font: SwiftUICore.Font = Fonts.medium.swiftUIFont(fixedSize: Constants.FontSize.small.value),
    contentAlignment: ContentAlignment = .center,
    isDisabled: Bool = false,
    isLoading: Binding<Bool> = .constant(false),
    titlePadding: CGFloat = 16,
    action: @escaping () -> Void
  ) {
    self.type = type
    
    self.height = height
    self.cornerRadius = cornerRadius
    
    self.tintColor = tintColor
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    
    self.icon = icon
    self.iconPlacement = iconPlacement
    self.title = title
    
    self.font = font
    
    self.contentAlignment = contentAlignment
    
    self.isDisabled = isDisabled
    _isLoading = isLoading
    
    self.titlePadding = titlePadding
    
    self.action = action
  }
  
  public var body: some View {
    ZStack {
      buttonView
        .disabled(isDisabled || isLoading)
      
      lottieAnimation
    }
  }
}

  // MARK: - View Components
private extension FullWidthButton {
  var lottieAnimation: some View {
    Group {
      DefaultLottieView(
        loading: .ctaFast
      )
      .frame(
        width: 30,
        height: 20
      )
    }
    .frame(
      height: height
    )
    .hidden(!isLoading)
  }
  
  var buttonView: some View {
    Button(
      action: action
    ) {
      HStack(
        spacing: iconPlacement.spacing
      ) {
        if contentAlignment == .trailing {
          Spacer()
        }
        
        if let icon = icon,
           case .leading = iconPlacement {
          icon
        }
        
        Text(title)
          .font(font)
        
        if let icon = icon,
           case .trailing = iconPlacement {
          icon
        }
        
        if contentAlignment == .leading {
          Spacer()
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.horizontal, titlePadding)
      .hidden(isLoading)
    }
    .frame(
      height: height
    )
    .foregroundColor(tintColor ?? defaultTintColor)
    .background(backgroundColor ?? defaultBackgroundColor)
    .cornerRadius(cornerRadius)
    .applyIf(defaultBorderColor != .clear){
      $0.overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .inset(by: 0.5)
          .stroke(defaultBorderColor, lineWidth: 1)
      )
    }
    .opacity((isDisabled || isLoading) ? 0.5 : 1.0)
  }
}

// MARK: - Private Variables
private extension FullWidthButton {
  var defaultTintColor: Color {
    Colors.titlePrimary.swiftUIColor
  }
  
  var defaultBorderColor: Color {
    switch type {
    case .secondary:
      borderColor ?? Colors.titlePrimary.swiftUIColor
    case .alternativeBordered:
      borderColor ?? Colors.backgroundLight.swiftUIColor
    default:
        .clear
    }
  }
  
  var defaultBackgroundColor: Color {
    switch type {
    case .primary:
      Colors.buttonPrimary.swiftUIColor
    case .secondary:
      Colors.buttonSecondary.swiftUIColor
    case .alternative, .alternativeBordered:
      Colors.buttonAlternative.swiftUIColor
    case .alternativeLight:
      Colors.grey400.swiftUIColor
    }
  }
}

  // MARK: - Types
public extension FullWidthButton {
  enum Kind {
    case primary
    case secondary
    case alternative
    case alternativeLight
    case alternativeBordered
  }
  
  enum IconPlacement {
    case leading(spacing: CGFloat)
    case trailing(spacing: CGFloat)
    
    var spacing: CGFloat {
      switch self {
      case let .leading(spacing), let .trailing(spacing):
        return spacing
      }
    }
  }
  
  enum ContentAlignment {
    case leading
    case center
    case trailing
  }
}
