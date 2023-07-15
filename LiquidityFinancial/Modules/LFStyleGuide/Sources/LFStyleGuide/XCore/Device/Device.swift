import Combine
import SwiftUI

// MARK: - Device

/// An object representing the device.
@dynamicMemberLookup
public final class Device: ObservableObject {
  private var cancellable: AnyCancellable?

  private init() {
    #if os(iOS)
    cancellable = screen
      .objectWillChange
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
    #endif
  }

  /// An object that represents the current device.
  public static let current = Device()

  /// Returns the screen object representing the device’s screen.
  public var screen: Screen {
    .main
  }

  public static subscript<T>(dynamicMember keyPath: KeyPath<Device, T>) -> T {
    current[keyPath: keyPath]
  }
}

// MARK: - Environment Support

extension EnvironmentValues {
  private struct DeviceKey: EnvironmentKey {
    static var defaultValue: Device = .current
  }

  /// An object representing the device.
  public var device: Device {
    get { self[DeviceKey.self] }
    set { self[DeviceKey.self] = newValue }
  }
}
