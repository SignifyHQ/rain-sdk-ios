import SwiftUI
import Factory
import LFAccountOnboarding
import LFStyleGuide
import AvalancheAccountOnboarding

struct AppView: View {
  
  @State var onSignupPhone: Bool = false
  
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
          SigningUpPhoneViews(viewModel: Container.shared.signingUpPhoneViewModel.callAsFunction())
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
