import Foundation
import SolidDomain

struct MockAPISolidPersonParameters: SolidPersonParametersEntity {
  public let firstName, middleName, lastName, email, phone: String?
  public let dateOfBirth, idNumber, idType: String?
  init(firstName: String?, middleName: String?, lastName: String?, email: String?, phone: String?, dateOfBirth: String?, idNumber: String?, idType: String?) {
    self.firstName = firstName
    self.middleName = middleName
    self.lastName = lastName
    self.email = email
    self.phone = phone
    self.dateOfBirth = dateOfBirth
    self.idNumber = idNumber
    self.idType = idType
  }
  
  static var mockData: MockAPISolidPersonParameters {
    MockAPISolidPersonParameters(
      firstName: "mock_firstName",
      middleName: "mock_middleName",
      lastName: "mock_lastName",
      email: "mock_email",
      phone: "mock_phone",
      dateOfBirth: "mock_dateOfBirth",
      idNumber: "mock_idNumber",
      idType: "mock_idType"
    )
  }
  
  static var mockEmptyData: MockAPISolidPersonParameters {
    MockAPISolidPersonParameters(
      firstName: "",
      middleName: "",
      lastName: "",
      email: "",
      phone: "",
      dateOfBirth: "",
      idNumber: "",
      idType: ""
    )
  }
}
