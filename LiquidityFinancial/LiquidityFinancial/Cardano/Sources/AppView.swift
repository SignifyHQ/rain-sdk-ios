import SwiftUI
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
          Image("ic_avalanche_logo")
            .resizable()
            .frame(width: 100, height: 100)
          Text("Hello, world! \(appName ?? "Unknow")")
          Button("Sign up Phone") {
            onSignupPhone.toggle()
          }.buttonStyle(GrowingButton())
        }
        .foregroundColor(Color("bg_black_app"))
        .padding()
        
        NavigationLink("", isActive: $onSignupPhone) {
          CardanoAccountOnboardingView()
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}
