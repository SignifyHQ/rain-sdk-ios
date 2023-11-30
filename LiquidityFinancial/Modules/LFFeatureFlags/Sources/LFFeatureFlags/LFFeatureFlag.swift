import SwiftUI
import Combine

@propertyWrapper
public struct LFFeatureFlag<F: LFFeatureFlagType>: DynamicProperty {
  @StateObject private var registration: Registration
  private let featureFlag: F
  
  public var wrappedValue: F.Value {
    registration.value
  }
  
  public var projectedValue: F {
    featureFlag
  }
  
  public init(_ featureFlag: F) {
    self.featureFlag = featureFlag
    self._registration = StateObject(wrappedValue: Registration(featureFlag))
  }
  
  private class Registration: ObservableObject {
    
    @Published var value: F.Value
    
    private var cancellable: AnyCancellable?
    
    init(_ featureFlag: F) {
      value = featureFlag.value
      DispatchQueue.main.async {
        self.cancellable = featureFlag.register().sink(receiveValue: { [weak self] newValue in
          self?.value = newValue
        })
      }
    }
  }
}
