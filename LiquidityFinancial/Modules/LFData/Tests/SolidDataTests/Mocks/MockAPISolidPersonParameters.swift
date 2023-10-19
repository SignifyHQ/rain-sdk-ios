import Foundation
import SolidData

enum MockAPISolidPersonParameters {
  static var mockData: APISolidPersonParameters {
    APISolidPersonParameters(
      solidCreatePersonRequest: SolidCreatePersonRequest(
        firstName: "mock_firstName",
        middleName: "mock_middleName",
        lastName: "mock_lastName",
        email: "mock_email",
        phone: "mock_phone",
        dateOfBirth: "mock_dateOfBirth",
        idNumber: "mock_idNumber",
        idType: "mock_idType",
        address: nil
      )
    )
  }

  static var mockEmptyData: APISolidPersonParameters {
    APISolidPersonParameters(
      solidCreatePersonRequest: SolidCreatePersonRequest(
        firstName: "",
        middleName: "",
        lastName: "",
        email: "",
        phone: "",
        dateOfBirth: "",
        idNumber: "",
        idType: "",
        address: nil
      )
    )
  }
}
