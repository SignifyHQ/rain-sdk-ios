import Foundation

class ServiceConditionModel: Identifiable {
  let id: String
  var selected: Bool = false
  let message: String
  let attributeInformation: [String: String]
  
  init(id: String, message: String, attributeInformation: [String: String], selected: Bool = false) {
    self.id = id
    self.selected = selected
    self.message = message
    self.attributeInformation = attributeInformation
  }
  
  func update(selected: Bool) {
    self.selected = selected
  }
}
