import SwiftUI
import LFUtilities

// MARK: - ToastView
public struct ToastView: View {
  let toastMessage: String
  
  public init(toastMessage: String) {
    self.toastMessage = toastMessage
  }
  
  public var body: some View {
    VStack {
      Text(toastMessage)
        .lineLimit(4)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(16)
        .multilineTextAlignment(.center)
    }
    .frame(minWidth: 200, minHeight: 60)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
    .floatingShadow()
  }
}
