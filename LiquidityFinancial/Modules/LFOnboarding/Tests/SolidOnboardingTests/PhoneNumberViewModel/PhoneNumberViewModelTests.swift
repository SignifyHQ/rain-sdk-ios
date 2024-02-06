import OnboardingComponents
import Combine
import DomainTestHelpers
import Factory
import LFUtilities
import Nimble
import TestHelpers
import XCTest
import LFStyleGuide
import NetworkUtilities
import LFFeatureFlags

@testable import SolidOnboarding

@MainActor
// Test cases for the PhoneNumberViewModel
final class PhoneNumberViewModelTests: XCTestCase {
  
  var coordinator: OnboardingDestinationObservable!
  var viewModel: PhoneNumberViewModel!
  var mockOnboardingRepository: MockOnboardingRepositoryProtocol!
  var featureFlagManager: MockFeatureFlagManager!
  
  // Defining mock repository test input, success response and errors
  let mockValidPhoneNumberFormat = "(205) 858-5000"
  let mockInvalidPhoneNumberFormat = "(205) 555-0000"
  let mockInvalidPhoneNumberReformat = "+12055550000"
  let mockSuccessResponse = TestAPIOtp(requiredAuth: ["mock_required_auth1", "mock_required_auth2"])
  let mockServerError = LFErrorObject(message: "mock_error_message", code: "mock_error_code")
  let mockGenericError = TestError.fail("mock_generic_error")
  
  private var cancellables: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    // Setting environment variable XCODE_RUNNING_TESTS in order to be able to use the configurations when running the tests
    setenv("XCODE_RUNNING_TESTS", "1", 1)
    
    LFUtilities.initial(target: "CauseCard")
    LFStyleGuide.initial(target: "CauseCard")
    NetworkUtilities.initial(target: "CauseCard")
    
    // Initialize mock coordinator and the viewModel before each test. Inject coordinator into the viewModel
    coordinator = OnboardingDestinationObservable()
    viewModel = PhoneNumberViewModel()
    // Initialize mocks
    mockOnboardingRepository = MockOnboardingRepositoryProtocol()
    featureFlagManager = MockFeatureFlagManager()
    // Register mocks in the container
    Container.shared.onboardingRepository.register {
      self.mockOnboardingRepository
    }
    Container.shared.featureFlagManager.register {
      self.featureFlagManager
    }
    cancellables = []
  }
  
  override func tearDown() {
    // Clean and reset up any resources that don't need to persist.
    Container.shared.onboardingRepository.reset()
    Container.shared.featureFlagManager.reset()
    mockOnboardingRepository = nil
    viewModel = nil
    coordinator = nil
    featureFlagManager = nil
    cancellables = nil
    
    super.tearDown()
  }
  
  // Configuring mock featureFlag behaviour
  private func configureMockFeatureFlag(featureKey: FeatureFlagKey, enabled: Bool) {
    var model = MockFeatureFlagModel()
    model.key = featureKey.rawValue
    model.enabled = enabled
    featureFlagManager.fetchEnabledFeatureFlagsReturnValue = [model]
  }
  
  // Configuring mock repository behaviour
  private func configureMockRepositoryBehaviour(shouldThrowGenericError: Bool = false) {
    mockOnboardingRepository.requestOTPParametersClosure = { entity async throws in
      // If the repository should through a generic error (e.g. when network issue occurs) throw 'mockGenericError'
      guard !shouldThrowGenericError else {
        throw self.mockGenericError
      }
      // If the phone number provided is invalid (not supported, blocked, etc.) the repository should throw 'mockServerError'
      guard entity.phoneNumber != self.mockInvalidPhoneNumberReformat else {
        throw self.mockServerError
      }
      // Otherwise, the repository should return 'mockSuccessResponse'
      return self.mockSuccessResponse
    }
  }
  
  // Test performGetOTP with valid input (happy case)
  func test_performGetOTP_whenPhoneNumberIsValid_shouldPresentOTPScreen() async {
    // Given the expected API behaviour
    configureMockRepositoryBehaviour()
    configureMockFeatureFlag(featureKey: .mfa, enabled: false)
    // And a valid phone number input
    viewModel.phoneNumber = mockValidPhoneNumberFormat
    // When calling performGetOTP function in view model
    viewModel.performGetOTP()
    // Then the toast message should initially be nil
    expect(self.viewModel.toastMessage).to(beNil())
    // And the phone number destination view should initially be nil
    expect(self.viewModel.navigation).to(beNil())
    // And eventually the toast message should remain nil
    await expect(self.viewModel.toastMessage).toEventually(beNil())
    // And eventually the phone number destination view should become a kind of 'PhoneNumberNavigation'
    await expect(self.viewModel.navigation).toEventually(beAKindOf(PhoneNumberViewModel.Navigation.self))
  }
  
  // Test performGetOTP with input which should make server throw an error
  func test_performGetOTP_whenPhoneNumberIsInvalid_shouldReturnServerError() async {
    // Given the expected API behaviour
    configureMockFeatureFlag(featureKey: .mfa, enabled: false)
    configureMockRepositoryBehaviour()
    // And a phone number input which should make the mock repository thow a server error
    viewModel.phoneNumber = mockInvalidPhoneNumberFormat
    // When calling performGetOTP function in view model
    viewModel.performGetOTP()
    // Then the toast message should initially be nil
    expect(self.viewModel.toastMessage).to(beNil())
    // And eventually should become equal to 'mockServerError' localized description
    await expect(self.viewModel.toastMessage).toEventually(equal(mockServerError.message))
  }
  
  // Test performGetOTP when a network error occurs
  func test_performGetOTP_whenNetworkErrorOccurs_shouldReturnGenericError() async {
    // Given the expected API behaviour which throws a generic error
    configureMockFeatureFlag(featureKey: .mfa, enabled: false)
    configureMockRepositoryBehaviour(shouldThrowGenericError: true)
    // And a valid phone number input
    viewModel.phoneNumber = mockValidPhoneNumberFormat
    // When calling performGetOTP function in view model
    viewModel.performGetOTP()
    // Then the toast message should initially be nil
    expect(self.viewModel.toastMessage).to(beNil())
    // And eventually should become equal to 'mockGenericError' localized description
    await expect(self.viewModel.toastMessage).toEventually(equal(mockGenericError.localizedDescription))
  }
  
  // Test reformatPhone functionality in viewModel
  func test_reformatPhone_shouldSucceed() {
    // Given a formatted phone number string
    let formattedPhoneNumber = "(205) 858-5000"
    // And an expected reformatted phone number string (digits only)
    let expectedReformattedPhoneNumber = "2058585000"
    // When assigning formatted phone number to the variable in viewModel
    viewModel.phoneNumber = formattedPhoneNumber
    // And requesting a reformatPhone String
    let reformattedPhoneNumber = viewModel.phoneNumber.reformatPhone
    // Then the reformatPhoneNumber should be equal to the expected value
    expect(reformattedPhoneNumber).to(equal(expectedReformattedPhoneNumber))
  }
  
  // Test phone number validation function with valid input
  func test_onChangedPhoneNumber_whenPassingValidNumber_shouldEnableContinueButton() {
    // Given a valid formatted phone number string
    let validFormattedPhoneNumber = "(205) 858-5000"
    // And isButtonDisabled is equal to 'true' at the beginning of the test
    expect(self.viewModel.isButtonDisabled).to(equal(true))
    // When calling a function in view model which validates the phone number input
    viewModel.onChangedPhoneNumber(newValue: validFormattedPhoneNumber)
    // Then isButtonDisabled should be switched to 'false'
    expect(self.viewModel.isButtonDisabled).to(equal(false))
  }
  
  // Test phone number validation function when phone input isn't complete
  func test_onChangedPhoneNumber_whenNumberInputIsntComplete_shouldKeepContinueButtonDisabled() {
    // Given an incomplete formatted phone number string
    let invalidFormattedPhoneNumber = "(205) 858-50"
    // And isButtonDisabled is equal to 'true' at the beginning of the test
    expect(self.viewModel.isButtonDisabled).to(equal(true))
    // When calling a function on view model which validates the phone number input
    viewModel.onChangedPhoneNumber(newValue: invalidFormattedPhoneNumber)
    // Then isButtonDisabled should remain 'true'
    expect(self.viewModel.isButtonDisabled).to(equal(true))
  }
  
  // Test phone number validation function when phone changes from valid to invalid
  func test_onChangedPhoneNumber_whenNumberInputChangesToInvalid_shouldDisableContinueButton() {
    // Given an invalid formatted phone number string
    let invalidFormattedPhoneNumber = "(205) 858-500"
    // And isButtonDisabled is equal to 'false' at the beginning of the test (previous input was valid)
    viewModel.isButtonDisabled = false
    expect(self.viewModel.isButtonDisabled).to(equal(false))
    // When calling a function on view model which validates the phone number input
    viewModel.onChangedPhoneNumber(newValue: invalidFormattedPhoneNumber)
    // Then isButtonDisabled should be switched to 'true'
    expect(self.viewModel.isButtonDisabled).to(equal(true))
  }
  
  // Test getURL function with valid input
  func test_getURL_whenInputIsValid_shouldReturnCorrectURL() {
    // Given link titles which are defined in view model
    let terms = viewModel.terms
    let esignConsent = viewModel.esignConsent
    let privacyPolicy = viewModel.privacyPolicy
    // When calling getURL function in view model to get corresponding URLs
    let termsURL = viewModel.getURL(tappedString: terms)
    let esignConsentURL = viewModel.getURL(tappedString: esignConsent)
    let privacyPolicyURL = viewModel.getURL(tappedString: privacyPolicy)
    // Then the URLs should be equal to those created directly using localized strings
    expect(termsURL).to(equal(URL(string: LFUtilities.termsURL)))
    expect(esignConsentURL).to(equal(URL(string: LFUtilities.consentURL)))
    expect(privacyPolicyURL).to(equal(URL(string: LFUtilities.privacyURL)))
  }
  
  // Test getURL function with invalid input
  func test_getURL_whenInputIsInvalid_shouldReturnNil() {
    // Given invalid link title
    let invalidTitle = "mock_invalid_link_title"
    // When calling getURL function in view model to get the corresponding URL
    let url = viewModel.getURL(tappedString: invalidTitle)
    // Then the URL should be nil
    expect(url).to(beNil())
  }
  
  // Test showing and hiding loader when calling getOTP function
  func test_isLoading_whengetOTPIsCalled_shouldBeTrueOnceAndFalseEventually() async {
    var timesLoaderWasShown: Int = 0
    
    self.viewModel
      .$isLoading
      .filter { isLoading in
        isLoading
      }
      .sink { isLoading in
        timesLoaderWasShown += 1
      }
      .store(in: &cancellables)
    // Given the expected API behaviour
    configureMockFeatureFlag(featureKey: .mfa, enabled: false)
    configureMockRepositoryBehaviour()
    // And any phone number input
    viewModel.phoneNumber = mockValidPhoneNumberFormat
    // And isLoading should initially be 'false' (loader not shown)
    expect(self.viewModel.isLoading).to(equal(false))
    // When calling performGetOTP function in view model
    viewModel.performGetOTP()
    // Then eventually isLoading should be 'false' (loader hidden)
    await expect(self.viewModel.isLoading).toEventually(equal(false))
    // And the loader should be shown exatly once
    expect(timesLoaderWasShown).to(equal(1))
  }
}
