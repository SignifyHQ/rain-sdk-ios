import Foundation

struct UserMock {
  var firstName: String
  var lastName: String
  var dob: String
  var email: String
  var line1: String
  var city: String
  var zipCode: String
  var state: String
  var country: String
  var ssn: String
}

class UserMockManager {
  static let mockUserApproved = UserMock(firstName: "BONNIE", lastName: "CLARK", dob: "04/03/1960", email: "me@mail.com", line1: "2370 W MAIN ST", city: "JEFFERSON CITY", zipCode: "65109", state: "MO", country: "US", ssn: "870012897")
  static let mockUserQuestion = UserMock(firstName: "JUANA", lastName: "ANGELA", dob: "10/01/1978", email: "me@mail.com", line1: "50189 W Montcalm St", city: "Greenville", zipCode: "48838", state: "MI", country: "US", ssn: "887117324")
  static let mockUserDocument = UserMock(firstName: "BONNIE", lastName: "CLARK", dob: "04/03/1960", email: "me@mail.com", line1: "2370 W MAIN ST", city: "JEFFERSON CITY", zipCode: "65109", state: "MO", country: "US", ssn: "887117324")
  
  //3 -> mockUserApproved
  //4 -> mockUserQuestion
  //5 -> mockUserDocument
  //Other -> mockUserApproved
  var condition: Int = 0
  
  static func mockUser(countTap: Int) -> UserMock {
    switch countTap {
    case 3: return mockUserApproved
    case 4: return mockUserQuestion
    case 5: return mockUserDocument
    default: return mockUserApproved
    }
  }
}
