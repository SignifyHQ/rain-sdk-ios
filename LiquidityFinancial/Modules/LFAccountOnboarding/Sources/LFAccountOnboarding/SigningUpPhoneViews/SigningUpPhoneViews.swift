import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct SigningUpPhoneViews: View {
//  @Injected(.)
//  let viewModel: SigningUpPhoneViewModel
//
//  public init(viewModel: SigningUpPhoneViewModel) {
//    self.viewModel = viewModel
//  }
  public init() {}
  
  @State var phoneText: String = ""
  @State var otpText: String = ""
  
  public var body: some View {
    VStack(spacing: 16) {
      Text(LFLocalizable.Screen.Title.text)
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
struct SigningUpPhoneViews_Previews: PreviewProvider {

  static var previews: some View {
    Preview {
      SigningUpPhoneViews()
    }
  }
}
#endif
