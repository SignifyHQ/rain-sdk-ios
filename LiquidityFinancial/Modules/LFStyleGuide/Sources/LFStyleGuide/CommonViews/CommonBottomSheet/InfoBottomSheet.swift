import LFLocalizable
import LFUtilities
import SwiftUI

public struct InfoBottomSheet: View {
  @Environment(\.dismiss) private var dismiss

  var title: String
  var subtitle: String?
  var buttonTitle: String
  var imageView: (() -> AnyView)?
  var action: (() -> Void)?
  
  public init(
    title: String,
    subtitle: String? = nil,
    buttonTitle: String = L10N.Common.Common.Close.Button.title,
    imageView: (() -> AnyView)? = nil,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.buttonTitle = buttonTitle
    self.imageView = imageView
    self.action = action
  }
  
  public init<ImageView: View>(
    title: String,
    subtitle: String? = nil,
    buttonTitle: String = L10N.Common.Common.Close.Button.title,
    imageView: (() -> ImageView)? = nil,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.buttonTitle = buttonTitle
    self.imageView = imageView.map { closure in { AnyView(closure()) } }
    self.action = action
  }
  
  public var body: some View {
    VStack(spacing: 32) {
      headerView
      if let imageView {
        imageView()
      }
      contentView
      button
    }
    .padding(.horizontal, 24)
    .background(Colors.grey900.swiftUIColor)
  }
}

private extension InfoBottomSheet {
  var headerView: some View {
    Text(title)
      .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.main.value))
      .foregroundColor(Colors.textPrimary.swiftUIColor)
      .multilineTextAlignment(.center)
      .padding(.top, 24)
  }
  
  @ViewBuilder
  var contentView: some View {
    if let subtitle = subtitle {
      Text(subtitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var button: some View {
    FullWidthButton(
      backgroundColor: Colors.buttonSurfacePrimary.swiftUIColor,
      title: buttonTitle,
      action: {
        action?() ?? dismiss()
      }
    )
    .frame(maxWidth: .infinity)
    .padding(.bottom, 16)
  }
}
