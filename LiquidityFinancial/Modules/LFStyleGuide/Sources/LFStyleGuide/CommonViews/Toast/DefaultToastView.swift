import LFUtilities
import SwiftUI

public struct DefaultToastView: View {
  let type: ToastType
  
  let toastTitle: String
  let toastBody: String?
  
  public init(
    for type: ToastType,
    toastTitle: String,
    toastBody: String? = nil
  ) {
    self.type = type
    self.toastTitle = toastTitle
    self.toastBody = toastBody
  }
  
  public var body: some View {
    HStack(
      alignment: .top,
      spacing: 8
    ) {
      type.icon
      
      VStack(
        alignment: .leading,
        spacing: 4
      ) {
        Text(toastTitle)
          .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(type.tintColor)
          .multilineTextAlignment(.leading)
        
        if let toastBody = toastBody {
          Text(toastBody)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(type.tintColor)
            .multilineTextAlignment(.leading)
        }
      }
      
      Spacer()
    }
    .padding(12)
    .background(type.backgroundColor)
    .cornerRadius(8)
    .padding(.horizontal, 24)
  }
}
