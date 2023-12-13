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
    VStack {
      Text("Feature Flags")
        .font(.title2)
        .padding(.top)
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
  }
}

struct FeatureFlagsView_Previews: PreviewProvider {
  
  static var previews: some View {
    LFFeatureFlagsHubView()
  }
}
