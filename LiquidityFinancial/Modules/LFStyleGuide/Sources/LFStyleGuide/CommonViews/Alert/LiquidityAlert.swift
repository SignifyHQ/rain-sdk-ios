import SwiftUI
import LFUtilities

// MARK: - LiquidityAlert
public struct LiquidityAlert: View {
  let image: ImageConfiguration
  let title: String
  let message: String?
  let primary: ButtonConfiguration
  let secondPrimary: ButtonConfiguration?
  let secondary: ButtonConfiguration?
  @Binding var isLoading: Bool
  
  public init(
    image: LiquidityAlert.ImageConfiguration = .appLogo,
    title: String,
    message: String? = nil,
    primary: LiquidityAlert.ButtonConfiguration,
    secondPrimary: LiquidityAlert.ButtonConfiguration? = nil,
    secondary: LiquidityAlert.ButtonConfiguration? = nil,
    isLoading: Binding<Bool> = .constant(false)
  ) {
    self.image = image
    self.title = title
    self.message = message
    self.primary = primary
    self.secondPrimary = secondPrimary
    self.secondary = secondary
    _isLoading = isLoading
  }
  
  public var body: some View {
    PopupAlert {
      VStack(spacing: 0) {
        image.asset.swiftUIImage
          .resizable()
          .frame(image.size)
          .padding(.bottom, 24)
        contextView
        buttonGroup
      }
    }
  }
}

// MARK: View Components
private extension LiquidityAlert {
  var contextView: some View {
    VStack(spacing: 20) {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
      if let message {
        Text(message)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .multilineTextAlignment(.center)
          .lineSpacing(1.33)
      }
    }
  }
  
  var buttonGroup: some View {
    VStack(spacing: 10) {
      FullSizeButton(
        title: primary.text,
        isDisable: false,
        isLoading: $isLoading,
        textColor: primary.textColor,
        backgroundColor: primary.backgroundColor,
        action: primary.action
      )
      if let secondPrimary = secondPrimary {
        FullSizeButton(
          title: secondPrimary.text,
          isDisable: false,
          textColor: primary.textColor,
          backgroundColor: primary.backgroundColor,
          action: secondPrimary.action
        )
      }
      if let secondary = secondary {
        FullSizeButton(
          title: secondary.text,
          isDisable: false,
          type: .secondary,
          textColor: primary.textColor,
          backgroundColor: primary.backgroundColor,
          action: secondary.action
        )
      }
    }
    .padding(.top, 30)
  }
}

// MARK: Types
extension LiquidityAlert {
  public struct ButtonConfiguration {
    let text: String
    let action: () -> Void
    let textColor: Color?
    let backgroundColor: Color?
    
    public init(
      text: String,
      textColor: Color? = nil,
      backgroundColor: Color? = nil,
      action: @escaping () -> Void
    ) {
      self.text = text
      self.textColor = textColor
      self.backgroundColor = backgroundColor
      self.action = action
    }
  }
  
  public struct ImageConfiguration {
    let asset: ImageAsset
    let size: CGSize
    
    public static var appLogo: Self {
      .init(asset: GenImages.Images.icLogo, size: .init(80))
    }
    
    public static var error: Self {
      .init(asset: GenImages.CommonImages.icXError, size: .init(80))
    }
  }
}
