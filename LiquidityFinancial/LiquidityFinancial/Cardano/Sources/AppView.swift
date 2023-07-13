import SwiftUI

struct AppView: View {
  
  var appName: String? {
    try? LFConfiguration.value(for: "APP_NAME")
  }
  
  var body: some View {
    VStack {
      Image("ic_cardano_logo")
        .resizable()
        .frame(width: 100, height: 100)
      Text("Hello, world! \(appName ?? "Unknow")")
    }
    .foregroundColor(Color("bg_black_app"))
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}
