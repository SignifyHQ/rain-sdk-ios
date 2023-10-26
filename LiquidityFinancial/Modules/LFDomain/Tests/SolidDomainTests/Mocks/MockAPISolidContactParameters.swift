import SolidDomain

struct MockAPISolidContactParameters: SolidContactEntity {
  public let name: String?
  public let last4: String
  public let type: String
  public let solidContactId: String
  
  init(name: String?, last4: String, type: String, solidContactId: String) {
    self.name = name
    self.last4 = last4
    self.type = type
    self.solidContactId = solidContactId
  }
  
  static var mockData: MockAPISolidContactParameters {
    MockAPISolidContactParameters(name: "mock_name", last4: "mock_last4", type: "mock_type", solidContactId: "mock_id")
  }
}
