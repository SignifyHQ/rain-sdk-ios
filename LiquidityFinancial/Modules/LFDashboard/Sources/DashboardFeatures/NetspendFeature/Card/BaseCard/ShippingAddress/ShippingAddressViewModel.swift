import Combine
import SwiftUI

@MainActor
public protocol ShippingAddressViewModelProtocol: ObservableObject {
  // Published Properties
  var mainAddress: String { get set }
  var subAddress: String { get set }
  var city: String { get set }
  var state: String { get set }
  var zipCode: String { get set }
  
  // Binding Properties
  var shippingAddress: ShippingAddress? { get set }
  
  // Properties
  var isDisableButton: Bool { get }
  
  init(shippingAddress: Binding<ShippingAddress?>)
  
  // View Helpers
  func saveAddress()
}
