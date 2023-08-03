import SwiftUI

public struct DBAdminMenuView: View {
  enum Action {
    case network, analytics
  }
  
  let environment: String
  
  public init(environment: String) {
    self.environment = environment
  }
  
  @State private var action: Action?
  @State private var isChangeEnviroment: Bool = false
  
  public var body: some View {
    NavigationView {
      VStack {
        Text("Current Environment: \(environment)")
          .frame(maxWidth: .infinity)
          .frame(height: 40)
          .background(Color.gray)
          .foregroundColor(.white)
          .font(Font.system(size: 18, design: .monospaced))
          .padding(.top, 8)
        
        List {
          Section("Network") {
            HStack {
              Image(systemName: "bolt.fill")
                .font(Font.system(size: 25, design: .rounded))
                .foregroundColor(Color.orange)
              
              Text("Network Analyzer")
                .frame(maxWidth: .infinity)
                .font(Font.system(size: 20, design: .monospaced))
                .onTapGesture {
                  action = .network
                }
            }
          }
          
//          Section("Analytics") {
//            HStack {
//              Image(systemName: "escape")
//                .font(Font.system(size: 25, design: .rounded))
//                .foregroundColor(Color.orange)
//
//              Text("Analytics Debugger")
//                .frame(maxWidth: .infinity)
//                .font(Font.system(size: 20, design: .monospaced))
//                .onTapGesture {
//                  action = .Analytics
//                }
//            }
//          }
//
//          Section("Environment") {
//            HStack {
//              Image(systemName: "house")
//                .font(Font.system(size: 25, design: .rounded))
//                .foregroundColor(Color.orange)
//
//              Text("Change Environment")
//                .frame(maxWidth: .infinity)
//                .font(Font.system(size: 20, design: .monospaced))
//                .onTapGesture {
//                  isChangeEnviroment.toggle()
//                }
//            }
//          }
          
        }
      }
    }
    .navigationDestination(binding: $action) { action in
      switch action {
      case .network:
        DBRequestsView()
      case .analytics:
        DebugAnalyticsView()
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("ADMIN MENU")
          .font(Font.system(size: 17))
          .foregroundColor(Color.white)
      }
    }
      //    .confirmationDialog("Choices Enviroment and App will auto Force-Logout", isPresented: $isChangeEnviroment, titleVisibility: .visible) {
      //      Button("Change to Dev") {
      //        environmentManager.networkEnvironment = .productionTest
      //      }
      //      Button("Change to Pro") {
      //        environmentManager.networkEnvironment = .productionLive
      //      }
      //    }
  }
}

struct AdminMenuView_Previews: PreviewProvider {
  static var previews: some View {
    DBAdminMenuView(environment: "Debug Menu")
  }
}
