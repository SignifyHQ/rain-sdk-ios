import SwiftUI
import LFUtilities
import LFStyleGuide
import LFAccountOnboarding
import CardanoAccountOnboarding

struct AppView: View {
  
  @State var onSignupPhone: Bool = false
  
  var appName: String? {
    try? LFConfiguration.value(for: "APP_NAME")
  }
  
  var body: some View {
    NavigationView {
      ZStack {
        VStack {
          GenImages.Images.icLogo.swiftUIImage
            .resizable()
            .frame(width: 100, height: 100)
          Text("Hello, world! \(appName ?? "Unknow")")
          Button("Sign up Phone") {
            onSignupPhone.toggle()
          }
          .buttonStyle(GrowingButton())
          .background(Colors.buttons.swiftUIColor)
        }
        .foregroundColor(Color.white)
        .padding()
        
      }
      .frame(maxWidth: .infinity)
      .frame(maxHeight: .infinity)
      .background(Colors.background.swiftUIColor)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}
