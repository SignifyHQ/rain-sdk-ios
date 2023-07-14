import Foundation
import SwiftUI
import LFStyleGuide

public struct CardanoAccountOnboardingView: View {
  
  public init() {}
  
  @State var onSignupPhone: Bool = false
  
  public var body: some View {
    NavigationView {
      ZStack {
        VStack {
          LFStyleGuideImages.iconLogo
            .resizable()
            .frame(width: 100, height: 100)
        }
        .foregroundColor(Color("bg_black_app"))
        .padding()
        
        NavigationLink("", isActive: $onSignupPhone) {
          
        }
      }
      .frame(maxWidth: .infinity)
      .frame(maxHeight: .infinity)
      .background(LFStyleGuideColors.backgroundColor)
    }
  }
}

