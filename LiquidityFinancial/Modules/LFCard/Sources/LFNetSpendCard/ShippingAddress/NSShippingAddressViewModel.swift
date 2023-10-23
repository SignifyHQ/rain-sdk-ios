import Combine
import SwiftUI
import BaseCard

@MainActor
final class NSShippingAddressViewModel: ShippingAddressViewModelProtocol {
  @Published var mainAddress: String = .empty
  @Published var subAddress: String = .empty
  @Published var city: String = .empty
  @Published var state: String = .empty
  @Published var zipCode: String = .empty
  
  @Binding var shippingAddress: ShippingAddress?
  
  var isDisableButton: Bool {
    mainAddress.isEmpty || city.isEmpty || state.isEmpty || zipCode.isEmpty
  }
  
  init(shippingAddress: Binding<ShippingAddress?>) {
    _shippingAddress = shippingAddress
    mainAddress = shippingAddress.wrappedValue?.line1 ?? String.empty
    subAddress = shippingAddress.wrappedValue?.line2 ?? String.empty
    city = shippingAddress.wrappedValue?.city ?? String.empty
    state = shippingAddress.wrappedValue?.state ?? String.empty
    zipCode = shippingAddress.wrappedValue?.postalCode ?? String.empty
  }
}

// MARK: - View Helpers
extension NSShippingAddressViewModel {
  func saveAddress() {
    shippingAddress = ShippingAddress(
      line1: mainAddress,
      line2: subAddress.isEmpty ? shippingAddress?.line2 : subAddress,
      city: city,
      state: state,
      postalCode: zipCode,
      country: shippingAddress?.country
    )
  }
}
