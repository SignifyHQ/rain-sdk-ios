import SwiftUI
import LFUtilities
import LFAccessibility

// MARK: - LiquidityAlert
public struct LiquidityLoadingAlert: View {
  let title: String
  let message: String?
  let duration: Int
  let messageAlignment: TextAlignment
  let dismissAction: (() -> Void)?
  
  public init(
    title: String,
    message: String? = nil,
    duration: Int,
    messageAlignment: TextAlignment = .center,
    dismissAction: @escaping () -> Void
  ) {
    self.title = title
    self.message = message
    self.duration = duration
    self.messageAlignment = messageAlignment
    self.dismissAction = dismissAction
  }
  
  public var body: some View {
    PopupAlert {
      VStack(spacing: 16) {
        CircleLoadingTimerView(duration: duration) {
          dismissAction?()
        }
          .padding(.top, 16)
        contextView
      }
    }
  }
}

// MARK: View Components
private extension LiquidityLoadingAlert {
  var contextView: some View {
    VStack(spacing: 20) {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
        .accessibilityIdentifier(LFAccessibility.Popup.title)
      if let message {
        Text(message)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .multilineTextAlignment(messageAlignment)
          .lineSpacing(1.33)
      }
    }
  }
}
