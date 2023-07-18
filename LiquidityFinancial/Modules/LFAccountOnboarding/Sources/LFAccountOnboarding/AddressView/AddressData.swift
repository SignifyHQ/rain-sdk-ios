import Foundation

struct AddressData: Identifiable {
  var id = UUID()
  var addressline1: String = ""
  var addressline2: String = ""
  var city: String = ""
  var state: String = ""
  var zipcode: String = ""
  var isComplete: Bool = false
}
