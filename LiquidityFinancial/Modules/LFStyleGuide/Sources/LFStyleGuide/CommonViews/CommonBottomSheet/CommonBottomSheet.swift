import LFLocalizable
import LFUtilities
import SwiftUI

public struct CommonBottomSheet: View {
  @Environment(\.dismiss) private var dismiss

  var title: String
  var subtitle: String?
  var primaryButtonTitle: String
  var secondaryButtonTitle: String
  var imageView: (() -> AnyView)?
  var primaryAction: (() -> Void)
  var secondaryAction: (() -> Void)?
  
  public init(
    title: String,
    subtitle: String? = nil,
    primaryButtonTitle: String = L10N.Common.Common.Confirm.Button.title,
    secondaryButtonTitle: String = L10N.Common.Common.Close.Button.title,
    imageView: (() -> AnyView)? = nil,
    primaryAction: @escaping () -> Void,
    secondaryAction: (() -> Void)? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.primaryButtonTitle = primaryButtonTitle
    self.secondaryButtonTitle = secondaryButtonTitle
    self.imageView = imageView
    self.primaryAction = primaryAction
    self.secondaryAction = secondaryAction
  }
  
  public init<ImageView: View>(
    title: String,
    subtitle: String? = nil,
    primaryButtonTitle: String = L10N.Common.Common.Confirm.Button.title,
    secondaryButtonTitle: String = L10N.Common.Common.Close.Button.title,
    imageView: (() -> ImageView)? = nil,
    primaryAction: @escaping () -> Void,
    secondaryAction: (() -> Void)? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.primaryButtonTitle = primaryButtonTitle
    self.secondaryButtonTitle = secondaryButtonTitle
    self.imageView = imageView.map { closure in { AnyView(closure()) } }
    self.primaryAction = primaryAction
    self.secondaryAction = secondaryAction
  }
  
  public var body: some View {
    VStack(spacing: 32) {
      headerView
      if let imageView {
        imageView()
      }
      contentView
      buttonsGroup
        .padding(.bottom, 16)
    }
    .padding(.horizontal, 24)
    .background(Colors.grey900.swiftUIColor)
  }
}

private extension CommonBottomSheet {
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
  
  var buttonsGroup: some View {
    VStack(spacing: 12) {
      confirmButton
      closeButton
    }
    .frame(maxWidth: .infinity)
  }
  
  var confirmButton: some View {
    FullWidthButton(
      type: .primary,
      backgroundColor: Colors.buttonSurfacePrimary.swiftUIColor,
      title: primaryButtonTitle,
      action: primaryAction
    )
  }
  
  var closeButton: some View {
    FullWidthButton(
      type: .secondary,
      backgroundColor: .clear,
      borderColor: Colors.greyDefault.swiftUIColor,
      title: secondaryButtonTitle,
      action: {
        secondaryAction?() ?? dismiss()
      }
    )
  }
}
