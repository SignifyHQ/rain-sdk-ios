import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct TestHomeView: View {
  public init() {}
  
  public var body: some View {
    ZStack {
      VStack(
        alignment: .center,
        spacing: 4
      ) {
        Spacer()
        
        Text("Home Screen")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
        
        Text("Please relaunch the app to start over :D")
          .foregroundStyle(Colors.titleSecondary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
        
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Colors.backgroundPrimary.swiftUIColor)
    }
    .navigationBarBackButtonHidden()
    .track(name: String(describing: type(of: self)))
  }
}
