import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide

public struct SigningUpPhoneViews: View {
  
  let viewModel: SigningUpPhoneViewModel
  
  public init(viewModel: SigningUpPhoneViewModel) {
    self.viewModel = viewModel
  }
  
  @State var phoneText: String = ""
  @State var otpText: String = ""
  
  public var body: some View {
    VStack(spacing: 16) {
      Text("Signing up Phone: \(phoneText)")
      TextField("Input Phone", text: $phoneText) { _ in
        
      }
      .border(.blue)
      Button("Get OTP") {
        
      }
      TextField("Input OTP", text: $otpText) { _ in
        
      }.border(.blue)
      Button("Submit OTP") {
        
      }
    }.padding()
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
