import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import Factory
import LFServices
import SwiftUI

@MainActor
final class ShippingAddressViewModel: ObservableObject {
  @Binding var shippingAddress: ShippingAddress?
  
  @Published var mainAddress: String = ""
  @Published var subAddress: String = ""
  @Published var city: String = ""
  @Published var state: String = ""
  @Published var zipCode: String = ""
  
  var isDisableButton: Bool {
    mainAddress.isEmpty || city.isEmpty || state.isEmpty || zipCode.isEmpty
  }
  
  init(shippingAddress: Binding<ShippingAddress?>) {
    self._shippingAddress = shippingAddress
    
    mainAddress = shippingAddress.wrappedValue?.line1 ?? ""
    subAddress = shippingAddress.wrappedValue?.line2 ?? ""
    city = shippingAddress.wrappedValue?.city ?? ""
    state = shippingAddress.wrappedValue?.state ?? ""
    zipCode = shippingAddress.wrappedValue?.postalCode ?? ""
  }
}

// MARK: - API Handle
extension ShippingAddressViewModel {
  
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
