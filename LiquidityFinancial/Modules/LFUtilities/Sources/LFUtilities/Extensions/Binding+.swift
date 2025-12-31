import SwiftUI

extension Binding where Value == Bool {
  public static func fromEnum<T: Equatable>(
    _ enumBinding: Binding<T>,
    equals value: T
  ) -> Binding<Bool> {
    Binding(
      get: { enumBinding.wrappedValue == value },
      set: { newValue in
        if !newValue {
        }
      }
    )
  }
}

extension Binding where Value == Bool {
  public static func stringEquals(
    _ stringBinding: Binding<String?>,
    _ target: String?
  ) -> Binding<Bool> {
    Binding<Bool>(
      get: { stringBinding.wrappedValue == target },
      set: { newValue in
        if !newValue {
          stringBinding.wrappedValue = nil
        }
      }
    )
  }
}
