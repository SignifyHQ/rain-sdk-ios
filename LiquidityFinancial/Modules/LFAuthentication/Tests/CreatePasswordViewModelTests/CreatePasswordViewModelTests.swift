import Nimble
import XCTest
@testable import LFAuthentication

// Test cases for CreatePasswordViewModelTests
final class CreatePasswordViewModelTests: XCTestCase {
  
  var viewModel: CreatePasswordViewModel!
  
  override func setUp() {
    super.setUp()
    
    viewModel = CreatePasswordViewModel()
  }
  
  override func tearDown() {
    // Clean and reset up any resources that don't need to persist.
    viewModel = nil
    super.tearDown()
  }
  
  // Testing password lenght validation with invalid lenght
  func test_isLenghtCorrect_withShortString_shouldFail() {
    // Given the password string which is shorter than 8 characters
    viewModel.passwordString = "Short"
    // When observing the password input
    // Then the isLengthCorrect var should be equal to false
    expect(self.viewModel.isLengthCorrect).to(beFalse())
  }
  
  // Testing password lenght validation with valid lenght
  func test_isLenghtCorrect_withLongString_shouldSucceed() {
    // Given the password string which is longer than 8 characters
    viewModel.passwordString = "ValidPasswordLength"
    // When observing the password input
    // Then the isLengthCorrect var should be equal to true
    expect(self.viewModel.isLengthCorrect).to(beTrue())
  }
  
  // Testing password special character validation with invalid input
  func test_containsSpecialCharacters_withoutSpecialChars_shouldFail() {
    // Given the password string which does not contain any special characters
    viewModel.passwordString = "PasswordWithoutSpecialChars"
    // When observing the password input
    // Then the containsSpecialCharacters var should be equal to false
    expect(self.viewModel.containsSpecialCharacters).to(beFalse())
  }
  
  // Testing password special character validation with correct input
  func test_containsSpecialCharacters_withSpecialChars_shouldSucceed() {
    // Given the password string that contains special characters
    viewModel.passwordString = "@PasswordWithSpecialChars@"
    // When observing the password input
    // Then the containsSpecialCharacters var should be equal to false
    expect(self.viewModel.containsSpecialCharacters).to(beTrue())
  }
  
  // Testing password lower and upper case validation with invalid input
  func test_containsLowerAndUpperCase_withOnlyLowerCase_shouldFail() {
    // Given the password string which is lower case only
    viewModel.passwordString = "lowercasepassword"
    // When observing the password input
    // Then the containsLowerAndUpperCase var should be equal to false
    expect(self.viewModel.containsLowerAndUpperCase).to(beFalse())
  }
  
  // Testing password lower and upper case validation with invalid input
  func test_containsLowerAndUpperCase_withOnlyUpperCase_shouldFail() {
    // Given the password string which is upper case only
    viewModel.passwordString = "UPPERCASEPASSWORD"
    // When observing the password input
    // Then the containsLowerAndUpperCase var should be equal to false
    expect(self.viewModel.containsLowerAndUpperCase).to(beFalse())
  }
  
  // Testing password lower and upper case validation with valid input
  func test_containsLowerAndUpperCase_withBothLowerAndUpperCase_shouldSucceed() {
    // Given the password string which is both lower and upper case
    viewModel.passwordString = "lowerAndUpperCasePassword"
    // When observing the password input
    // Then the containsLowerAndUpperCase var should be equal to true
    expect(self.viewModel.containsLowerAndUpperCase).to(beTrue())
  }
  
  // Testing password validation when passwords match but conditions are not met
  func test_isContinueEnabled_withMatchingButInvalidInput_shouldFail() {
    // Given the password string which does not contain a special character
    viewModel.passwordString = "CorrectPassword"
    // And the confirm password string which matches the password string
    viewModel.confirmPasswordString = "CorrectPassword"
    // When observing the password input and validation
    // Then the isContinueEnabled var should be equal to false (Continue button not active)
    expect(self.viewModel.isContinueEnabled).to(beFalse())
  }
  
  // Testing password validation when conditions are met but passwords don't match
  func test_isContinueEnabled_withValidButNotMatchingInput_shouldFail() {
    // Given the password string which meets all the conditions
    viewModel.passwordString = "CorrectPassword$"
    // And the confirm password string which also meets all the conditions but doesn't match the password string
    viewModel.confirmPasswordString = "CorrectPassword#"
    // When observing the password input and validation
    // Then the isContinueEnabled var should be equal to false (Continue button not active)
    expect(self.viewModel.isContinueEnabled).to(beFalse())
  }
  
  // Testing password validation when all contitions are met
  func test_isContinueEnabled_withValidInput_shouldSucceed() {
    // Given the password string which meets all conditions
    viewModel.passwordString = "CorrectPassword$"
    // And the confirm password string which is equal to the password string
    viewModel.confirmPasswordString = "CorrectPassword$"
    // When observing the password input and validation
    // Then the isContinueEnabled var should be equal to true (Continue button is active)
    expect(self.viewModel.isContinueEnabled).to(beTrue())
  }
}
