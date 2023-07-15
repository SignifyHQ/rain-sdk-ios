import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct SigningUpPhoneViews: View {

  let viewModel: SigningUpPhoneViewModel

  public init(viewModel: SigningUpPhoneViewModel) {
    self.viewModel = viewModel
  }
  
  @State var phoneText: String = ""
  @State var otpText: String = ""
  
  public var body: some View {
    VStack(spacing: 16) {
      Text(LFLocalizable.Screen.Title.text)
      Text("Signing up Phone: \(phoneText)")
      TextField("Input Phone", text: $phoneText)
        .border(.blue)
      Button("Get OTP") {
        viewModel.performGetOTP(phone: phoneText)
      }
      TextField("Input OTP", text: $otpText)
        .border(.blue)
      Button("Submit OTP") {
        viewModel.performLogin(phone: phoneText, code: otpText)
      }
    }
    .padding()
  }
  
}

#if DEBUG
//struct SigningUpPhoneViews_Previews: PreviewProvider {
//
//  static var previews: some View {
//    Preview {
//      SigningUpPhoneViews()
//    }
//  }
//}
#endif
