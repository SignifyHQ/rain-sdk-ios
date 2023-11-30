import Combine
import Foundation
import SwiftUI

public protocol LFFeatureFlagType {
  associatedtype Value: Equatable
  associatedtype View: SwiftUI.View
  
  var id: String { get }
  var title: String { get }
  var group: String? { get }
  var value: Value { get nonmutating set }
  var valuePublisher: AnyPublisher<Value, Never> { get }
  
  var view: View { get }
}

extension LFFeatureFlagType {
  
  public func register() -> AnyPublisher<Value, Never> {
    LFFeatureFlagsController.shared.register(self)
  }
  
  public var valueBinding: Binding<Value> {
    Binding {
      self.value
    } set: {
      self.value = $0
    }
  }
  
  public var id: String {
    let slugifiedTitle = title
      .components(separatedBy:
                    CharacterSet.alphanumerics.inverted
      )
      .joined(separator: "-")
    return "FeatureFlag_\(slugifiedTitle)"
  }
  
}

private var preferredUserDefaults: UserDefaults = .featureFlagsSuite

extension UserDefaults {
  public static var featureFlags: UserDefaults {
    get { preferredUserDefaults }
    set { preferredUserDefaults = newValue }
  }
  
  public static var featureFlagsSuite: UserDefaults {
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
      return .standard
    }
    return UserDefaults(suiteName: "\(bundleIdentifier).FeatureFlagsController") ?? .standard
  }
}
