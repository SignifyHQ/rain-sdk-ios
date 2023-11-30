import SwiftUI

public struct LFFeatureFlagsHubView: View {
    
  public init() {}
  
  @ObservedObject
  private var controller: LFFeatureFlagsController = .shared
  
  private var groupedFlags: [(String?, [FeatureFlagViewFactory])] {
    var groups: [String?] = []
    var map: [String?: [FeatureFlagViewFactory]] = [:]
    for factory in controller.viewFactories {
      if map.keys.contains(factory.group) == false {
        groups.append(factory.group)
      }
      map[factory.group, default: []].append(factory)
    }
    return groups.compactMap { ($0, map[$0] ?? []) }
  }
  
  public var body: some View {
    NavigationView {
      VStack {
        Form {
          ForEach(groupedFlags, id: \.0) { groupName, factories in
            Section(header: Text(groupName ?? "")) {
              ForEach(factories, id: \.id) { factory in
                factory.makeView()
              }
            }
          }
        }
      }
      .navigationTitle("Feature Flags")
      .font(.title2)
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      let appearance = UINavigationBarAppearance()
      let textColor = UIColor(Color.black)
      
      appearance.backgroundColor = UIColor(Color.white)
      appearance.largeTitleTextAttributes = [
        .font: UIFont.systemFont(ofSize: 32, weight: .bold),
        .foregroundColor: textColor
      ]
      appearance.titleTextAttributes = [
        .font: UIFont.systemFont(ofSize: 24, weight: .bold),
        .foregroundColor: textColor
      ]
      
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
  }
}

struct FeatureFlagsView_Previews: PreviewProvider {
  
  static var previews: some View {
    LFFeatureFlagsHubView()
  }
}
