import Foundation
import Combine
import SwiftUI

final class LFFeatureFlagsController: ObservableObject {
  static let shared = LFFeatureFlagsController()
  
  private init() {}
  
  func register<F: LFFeatureFlagType>(
    _ flag: F
  ) -> AnyPublisher<F.Value, Never> {
    
    if let publisher = publisher(for: flag) {
      return publisher
    }
    
    let publisher = flag
      .valuePublisher
      .handleEvents(
        receiveOutput: { _ in
          self.objectWillChange.send()
        },
        receiveCancel: {
          self.removePublisher(for: flag)
        }
      )
      .share()
      .prepend(flag.value)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    
    addPublisher(publisher, for: flag)
    
    return publisher
  }
  
  // MARK: - Publishers
  
  @Published
  private(set) var viewFactories: [FeatureFlagViewFactory] = []
  
  func addViewFactory<F: LFFeatureFlagType>(_ flags: [F]) {
    flags.forEach { flag in
      if viewFactories.contains(where: { $0.id == flag.id }) == false {
        viewFactories.append(FeatureFlagViewFactory(flag))
      }
    }
  }
  
  func removeViewFactory<F: LFFeatureFlagType>(_ flags: [F]) {
    viewFactories.removeAll(
      where: {
        flags
          .map { flag in flag.id }
          .contains($0.id)
      }
    )
  }
  
  private var publishers: [String: Any] = [:]
  
  private func publisher<F: LFFeatureFlagType>(
    for flag: F
  ) -> AnyPublisher<F.Value, Never>? {
    publishers[flag.id] as? AnyPublisher<F.Value, Never>
  }
  
  private func addPublisher<F: LFFeatureFlagType>(
    _ publisher: AnyPublisher<F.Value, Never>,
    for flag: F
  ) {
    if viewFactories.contains(where: { $0.id == flag.id }) == false {
      viewFactories.append(FeatureFlagViewFactory(flag))
    }
    publishers[flag.id] = publisher
  }
  
  private func removePublisher<F: LFFeatureFlagType>(
    for flag: F
  ) {
    viewFactories.removeAll(where: { $0.id == flag.id })
    publishers.removeValue(forKey: flag.id)
  }
}
