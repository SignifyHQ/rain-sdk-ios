import Foundation
import SwiftUI
import Combine

public struct ToggleFeatureFlag: LFFeatureFlagType {
  
  public init(title: String, defaultValue: Bool, group: String? = nil, userDefaults: UserDefaults = .featureFlags) {
    self.title = title
    self.defaultValue = defaultValue
    self.group = group
    self.userDefaults = userDefaults
  }
  
  public let title: String
  public let defaultValue: Bool
  public let group: String?
  
  private let userDefaults: UserDefaults
  
  public var value: Bool {
    get {
      guard
        let value = userDefaults.object(forKey: id) as? NSNumber
      else {
        return defaultValue
      }
      return value.boolValue
    }
    nonmutating set {
      userDefaults.set(newValue, forKey: id)
    }
  }
  
  public var valuePublisher: AnyPublisher<Bool, Never> {
    NotificationCenter.default
      .publisher(for: UserDefaults.didChangeNotification)
      .map { _ in self.value }
      .removeDuplicates()
      .eraseToAnyPublisher()
  }
  
  public var view: some View {
    Toggle(isOn: valueBinding) {
      Text(title)
    }
  }
  
  public var isEnabled: Bool {
    value
  }
}

extension LFFeatureFlagType {
  public static func toggle(
    title: String, defaultValue: Bool, group: String? = nil, userDefaults: UserDefaults = .featureFlags
  ) -> Self where Self == ToggleFeatureFlag {
    ToggleFeatureFlag(title: title, defaultValue: defaultValue, group: group, userDefaults: userDefaults)
  }
}

extension LFFeatureFlag {
  public init(
    wrappedValue: F.Value, title: String, group: String? = nil, userDefaults: UserDefaults = .featureFlags
  ) where F == ToggleFeatureFlag {
    self.init(ToggleFeatureFlag(title: title, defaultValue: wrappedValue, group: group, userDefaults: userDefaults))
  }
}
