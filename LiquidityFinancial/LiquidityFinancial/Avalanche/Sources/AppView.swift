import SwiftUI
import Factory
import LFAccountOnboarding
import LFStyleGuide
import LFUtilities
import AvalancheAccountOnboarding

struct AppView: View {
  
  @State var onSignupPhone: Bool = false
  let environmentManager = EnvironmentManager()
  
  var appName: String? {
    try? LFConfiguration.value(for: "APP_NAME")
  }
  
  var body: some View {
    NavigationView {
      ZStack {
        VStack {
          Images.icLogo.swiftUIImage
            .resizable()
            .frame(width: 100, height: 100)
          Text("Hello, world! \(appName ?? "Unknow")")
          Button("Sign up Phone") {
            onSignupPhone.toggle()
          }
          .buttonStyle(GrowingButton())
        }
        .foregroundColor(Color.white)
        .padding()
        
        NavigationLink("", isActive: $onSignupPhone) {
          /*
          //PhoneNumberView(viewModel: Container.shared.phoneNumberViewModel.callAsFunction())
            //.environmentObject(environmentManager)*/
          WelcomeView(viewModel: WelcomeViewModel())
        }
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
