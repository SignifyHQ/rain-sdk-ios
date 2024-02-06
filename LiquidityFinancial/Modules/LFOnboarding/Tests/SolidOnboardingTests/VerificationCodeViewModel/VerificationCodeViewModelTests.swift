import OnboardingComponents
import Combine
import DomainTestHelpers
import Factory
import LFUtilities
import Nimble
import TestHelpers
import XCTest
import LFFeatureFlags
import FeatureFlagDomain
import EnvironmentService
import OnboardingData
import LFStyleGuide
import NetworkUtilities
import OnboardingDomain
import LFLocalizable
import LFAuthentication

@testable import SolidOnboarding

@MainActor
// Test cases for the PhoneNumberViewModel
final class VerificationCodeViewModelTests: XCTestCase {
  
  var coordinator: OnboardingDestinationObservable!
  var viewModel: VerificationCodeViewModel!
  var mockEnvironmentService: MockEnvironmentService!
  var mockOnboardingRepository: MockOnboardingRepositoryProtocol!
  var mockAccountDataManager: MockAccountDataStorageProtocol!
  var mockFeatureFlagManager: MockFeatureFlagManager!
  var mockSolidOnboardingFlowCoordinator: MockSolidOnboardingFlowCoordinator!
  
  // Defining mock repository test input, success response and errors
  let mockValidPhoneNumberFormat = "(205) 858-5000"
  let mockInvalidPhoneNumberFormat = "(205) 555-0000"
  let mockInvalidPhoneNumberReformat = "+12055550000"
  let mockGetOTPSuccessResponse = TestAPIOtp(requiredAuth: ["mock_required_auth1", "mock_required_auth2"])
  let mockLoginSuccessResponse = TestAccessTokens(accessToken: "mock_accesstoken", tokenType: "mock_tokenType", refreshToken: "mock_refreshToken", expiresIn: 8080)
  let mockServerError = LFErrorObject(message: "mock_error_message", code: "mock_error_code")
  let mockUserInactiveError = LFErrorObject(message: "mock_error_message", code: Constants.ErrorCode.userInactive.value)
  let mockCredentialsInvalidError = LFErrorObject(message: "mock_error_message", code: Constants.ErrorCode.credentialsInvalid.value)
  let mockGenericError = TestError.fail("mock_generic_error")
  let mockValidOtpCode = "999999"
  let mockInValidOtpCode = "1111"
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.solidOnboardingFlowCoordinator) var solidOnboardingFlowCoordinator
  
  private var cancellables: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    // Setting environment variable XCODE_RUNNING_TESTS in order to be able to use the configurations when running the tests
    setenv("XCODE_RUNNING_TESTS", "1", 1)
    LFUtilities.initial(target: "CauseCard")
    LFStyleGuide.initial(target: "CauseCard")
    NetworkUtilities.initial(target: "CauseCard")
    
    // Initialize Mocks
    mockEnvironmentService = MockEnvironmentService()
    mockFeatureFlagManager = MockFeatureFlagManager()
    mockOnboardingRepository = MockOnboardingRepositoryProtocol()
    mockAccountDataManager = MockAccountDataStorageProtocol()
    mockSolidOnboardingFlowCoordinator = MockSolidOnboardingFlowCoordinator()
    
    // Register mocks in the container
    Container.shared.onboardingRepository.register {
      self.mockOnboardingRepository
    }
    Container.shared.featureFlagManager.register {
      self.mockFeatureFlagManager
    }
    Container.shared.environmentService.register {
      self.mockEnvironmentService
    }
    Container.shared.accountDataManager.register {
      self.mockAccountDataManager
    }
    Container.shared.solidOnboardingFlowCoordinator.register {
      self.mockSolidOnboardingFlowCoordinator
    }
    // Initialize mock coordinator and the viewModel before each test. Inject coordinator into the viewModel
    coordinator = OnboardingDestinationObservable()
    viewModel = VerificationCodeViewModel(phoneNumber: mockValidPhoneNumberFormat, requireAuth: [RequiredAuth.otp])
    cancellables = []
  }
  
  override func tearDown() {
    // Clean and reset up any resources that don't need to persist.
    Container.shared.onboardingRepository.reset()
    Container.shared.featureFlagManager.reset()
    Container.shared.environmentService.reset()
    Container.shared.accountDataManager.reset()
    Container.shared.solidOnboardingFlowCoordinator.reset()
    viewModel = nil
    coordinator = nil
    cancellables = nil
    super.tearDown()
  }
  
  // Configuring mock repository behaviour
  private func configureMockRepositoryVerifyLogin(errorCode: Constants.ErrorCode? = nil, shouldMFA: Bool = false, shouldThrowGenericError: Bool = false) {
    func response(entity: LoginParametersEntity) throws -> AccessTokensEntity {
      // If the repository should through a generic error (e.g. when network issue occurs) throw 'mockGenericError'
      guard !shouldThrowGenericError else {
        throw self.mockGenericError
      }
      // If the phone number provided is invalid (not supported, blocked, etc.) the repository should throw 'mockServerError'
      guard entity.phoneNumber != self.mockInvalidPhoneNumberReformat else {
        throw self.configureMockServerError(errorCode: errorCode)
      }
      // If the otp provided is invalid the repository should throw 'mockServerError'
      guard entity.code != self.mockInValidOtpCode else {
        throw self.configureMockServerError(errorCode: errorCode)
      }
      // Otherwise, the repository should return 'mockSuccessResponse'
      return self.mockLoginSuccessResponse
    }
    
    if shouldMFA {
      mockOnboardingRepository.newLoginParametersClosure = { entity async throws in
        return try response(entity: entity)
      }
    } else {
      mockOnboardingRepository.loginParametersClosure = { entity async throws in
        return try response(entity: entity)
      }
    }
  }
  
  private func configureMockRepositoryVerifyOTP(shouldMFA: Bool = false, shouldThrowGenericError: Bool = false) {
    
    func response(entity: OTPParametersEntity) throws -> OtpEntity {
      // If the repository should through a generic error (e.g. when network issue occurs) throw 'mockGenericError'
      guard !shouldThrowGenericError else {
        throw self.mockGenericError
      }
      // If the phone number provided is invalid (not supported, blocked, etc.) the repository should throw 'mockServerError'
      guard entity.phoneNumber != self.mockInvalidPhoneNumberReformat else {
        throw self.mockServerError
      }
      
      // Otherwise, the repository should return 'mockSuccessResponse'
      return self.mockGetOTPSuccessResponse
    }
    
    if shouldMFA {
      mockOnboardingRepository.newRequestOTPParametersClosure = { entity async throws in
        return try response(entity: entity)
      }
    } else {
      mockOnboardingRepository.requestOTPParametersClosure = { entity async throws in
        return try response(entity: entity)
      }
    }
  }
  
  private func configureMockFeatureFlag(featureKey: FeatureFlagKey, enabled: Bool) {
    var model = MockFeatureFlagModel()
    model.key = featureKey.rawValue
    model.enabled = enabled
    mockFeatureFlagManager.fetchEnabledFeatureFlagsReturnValue = [model]
  }
  
  private func configureMockServerError(errorCode: Constants.ErrorCode?) -> Error {
    guard let code = errorCode else {
      return mockServerError
    }
    switch code {
    case Constants.ErrorCode.userInactive:
      return mockUserInactiveError
    case Constants.ErrorCode.credentialsInvalid:
      return mockCredentialsInvalidError
    default:
      return mockServerError
    }
  }
  
  func test_performGetOTP_withOutMFA_success() async {
    // Given
    let mockOTPParameters = OTPParameters(phoneNumber: viewModel.formatPhoneNumber)
    configureMockFeatureFlag(featureKey: .mfa, enabled: false)
    configureMockRepositoryVerifyOTP()
    // When
    viewModel.performGetOTP()
    // Then
    await expect(self.mockOnboardingRepository.requestOTPParametersCalled).toEventually(beTrue())
    await expect(self.mockOnboardingRepository.requestOTPParametersReceivedParameters?.phoneNumber).toEventually(equal(mockOTPParameters.phoneNumber))
    await expect(self.viewModel.toastMessage).toEventually(beNil())
  }
  
  func test_performGetOTP_withOutMFA_failed() async {
    // Given
    let mockOTPParameters = OTPParameters(phoneNumber: viewModel.formatPhoneNumber)
    configureMockFeatureFlag(featureKey: .mfa, enabled: false)
    configureMockRepositoryVerifyOTP(shouldThrowGenericError: true)
    // When
    viewModel.performGetOTP()
    // Then
    expect(self.viewModel.toastMessage).to(beNil())
    await expect(self.mockOnboardingRepository.requestOTPParametersCalled).toEventually(beTrue())
    await expect(self.mockOnboardingRepository.requestOTPParametersReceivedParameters?.phoneNumber).toEventually(equal(mockOTPParameters.phoneNumber))
    await expect(self.viewModel.toastMessage).toEventually(equal(mockGenericError.localizedDescription))
  }
  
  func test_performGetOTP_withMFA_success() async {
    // Given
    let mockOTPParameters = OTPParameters(phoneNumber: viewModel.formatPhoneNumber)
    configureMockFeatureFlag(featureKey: .mfa, enabled: true)
    configureMockRepositoryVerifyOTP(shouldMFA: true)
    // When
    viewModel.performGetOTP()
    // Then
    await expect(self.mockOnboardingRepository.newRequestOTPParametersCalled).toEventually(beTrue())
    await expect(self.mockOnboardingRepository.newRequestOTPParametersReceivedParameters?.phoneNumber).toEventually(equal(mockOTPParameters.phoneNumber))
    await expect(self.viewModel.toastMessage).toEventually(beNil())
  }
  
  func test_performGetOTP_withMFA_failed() async {
    // Given
    let mockOTPParameters = OTPParameters(phoneNumber: viewModel.formatPhoneNumber)
    configureMockFeatureFlag(featureKey: .mfa, enabled: true)
    configureMockRepositoryVerifyOTP(shouldMFA: true, shouldThrowGenericError: true)
    // When
    viewModel.performGetOTP()
    // Then
    expect(self.viewModel.toastMessage).to(beNil())
    await expect(self.mockOnboardingRepository.newRequestOTPParametersCalled).toEventually(beTrue())
    await expect(self.mockOnboardingRepository.newRequestOTPParametersReceivedParameters?.phoneNumber).toEventually(equal(mockOTPParameters.phoneNumber))
    await expect(self.viewModel.toastMessage).toEventually(equal(mockGenericError.localizedDescription))
  }
}

// Test function PerformVerifyOTPCode()
extension VerificationCodeViewModelTests {
  func setupGiven(optCode: String, withMFA: Bool) {
    viewModel.otpCode = optCode
    mockAccountDataManager.underlyingPhoneNumber = viewModel.formatPhoneNumber
    configureMockFeatureFlag(featureKey: .mfa, enabled: withMFA)
    configureMockRepositoryVerifyLogin(shouldMFA: withMFA, shouldThrowGenericError: false)
  }
  
  func test_valid_OTP_withMFA() async {
    // Given
    setupGiven(optCode: mockValidOtpCode, withMFA: true)
    // When
    viewModel.performVerifyOTPCode()
    // Then
    await expect(self.mockOnboardingRepository.newLoginParametersCalled).toEventually(beTrue())
    await expect(self.mockOnboardingRepository.newLoginParametersReceivedParameters?.code).toEventually(equal(viewModel.otpCode))
    await expect(self.accountDataManager.phoneNumber).toEventually(equal(viewModel.formatPhoneNumber))
    await expect(self.mockSolidOnboardingFlowCoordinator.handlerOnboardingStepCalled).toEventually(beTrue())
  }
  
  func test_valid_OTP_withOutMFA() async {
    // Given
    setupGiven(optCode: mockValidOtpCode, withMFA: false)
    // When
    viewModel.performVerifyOTPCode()
    // Then
    await expect(self.mockOnboardingRepository.loginParametersCalled).toEventually(beTrue())
  }
  
  func test_inValid_OTP_withMFA() async {
    // Given
    setupGiven(optCode: mockInValidOtpCode, withMFA: true)
    // When
    viewModel.performVerifyOTPCode()
    // Then
    await expect(self.mockOnboardingRepository.newLoginParametersCalled).toEventually(beTrue())
    await expect(self.mockOnboardingRepository.newLoginParametersReceivedParameters?.code).toEventually(equal(viewModel.otpCode))
    await expect(self.viewModel.toastMessage).toEventually(equal(mockServerError.userFriendlyMessage))
  }
  
  func test_inValid_OTP_withOutMFA() async {
    // Given
    setupGiven(optCode: mockInValidOtpCode, withMFA: false)
    // When
    viewModel.performVerifyOTPCode()
    // Then
    await expect(self.mockOnboardingRepository.loginParametersCalled).toEventually(beTrue())
  }
  
  func test_inValid_OTP_handleError_userInactive() async {
    // Given
    viewModel.otpCode = mockInValidOtpCode
    configureMockFeatureFlag(featureKey: .mfa, enabled: true)
    configureMockRepositoryVerifyLogin(errorCode: .userInactive,shouldMFA: true, shouldThrowGenericError: false)
    // When
    viewModel.performVerifyOTPCode()
    // Then
    await expect(self.mockOnboardingRepository.newLoginParametersCalled).toEventually(beTrue())
    await expect(self.mockSolidOnboardingFlowCoordinator.setRouteCalled).toEventually(beTrue())
  }
  
  func test_inValid_OTP_handleError_credentialsInvalid() async {
    // Given
    viewModel.otpCode = mockInValidOtpCode
    configureMockFeatureFlag(featureKey: .mfa, enabled: true)
    configureMockRepositoryVerifyLogin(errorCode: .credentialsInvalid, shouldMFA: true, shouldThrowGenericError: false)
    // When
    viewModel.performVerifyOTPCode()
    // Then
    await expect(self.mockOnboardingRepository.newLoginParametersCalled).toEventually(beTrue())
    await expect(self.viewModel.toastMessage).toEventually(equal(L10N.Common.VerificationCode.OtpInvalid.message))
  }
  
  func test_valid_OTP_And_fetchOnboarding_failed() async {
    // Given
    setupGiven(optCode: mockValidOtpCode, withMFA: true)
    mockSolidOnboardingFlowCoordinator.handlerOnboardingStepThrowError = TestError.fail("fetch current onboarding state is failed")
    // When
    viewModel.performVerifyOTPCode()
    // Then
    await expect(self.mockOnboardingRepository.newLoginParametersCalled).toEventually(beTrue())
    await expect(self.mockSolidOnboardingFlowCoordinator.forcedLogoutCalled).toEventually(beTrue())
  }
}

// Test function resendOTP() and onChangedOTPCode()
extension VerificationCodeViewModelTests {
  func test_resendOTP_shouldCall_serformGetOTP() async {
    // Given
    configureMockFeatureFlag(featureKey: .mfa, enabled: false)
    configureMockRepositoryVerifyOTP()
    // When
    viewModel.resendOTP()
    // Then
    await expect(self.mockOnboardingRepository.requestOTPParametersCalled).toEventually(beTrue())
    await expect(self.viewModel.toastMessage).toEventually(beNil())
  }
  
  func test_onChangedOTPCode_shouldCall_handleAfterGetOTP() async {
    // Given
    viewModel.otpCode = mockValidOtpCode
    configureMockFeatureFlag(featureKey: .mfa, enabled: false)
    configureMockRepositoryVerifyOTP(shouldMFA: false)
    configureMockRepositoryVerifyLogin(shouldMFA: false)
    // When
    viewModel.onChangedOTPCode()
    // Then
    await expect(self.mockOnboardingRepository.loginParametersCalled).toEventually(beTrue())
    await expect(self.viewModel.toastMessage).toEventually(beNil())
  }
}

// Test function handleNewDeviceVerification()
extension VerificationCodeViewModelTests {
  func test_handleNewDeviceVerification_case_mfa() async {
    // Given
    viewModel.otpCode = mockValidOtpCode
    viewModel.requireAuth = [RequiredAuth.otp, RequiredAuth.mfa]
    viewModel.isShowLoading = false
    // When
    viewModel.onChangedOTPCode()
    // Then
    await expect(self.viewModel.navigation).toNotEventually(beNil())
  }
  
  func test_handleNewDeviceVerification_case_password() async {
    // Given
    viewModel.otpCode = mockValidOtpCode
    viewModel.requireAuth = [RequiredAuth.otp, RequiredAuth.password]
    viewModel.isShowLoading = false
    // When
    viewModel.onChangedOTPCode()
    // Then
    await expect(self.viewModel.navigation).toNotEventually(beNil())
  }
  
  func test_handleNewDeviceVerification_case_ssn() async {
    // Given
    viewModel.otpCode = mockValidOtpCode
    viewModel.requireAuth = [RequiredAuth.otp, RequiredAuth.ssn]
    viewModel.isShowLoading = false
    // When
    viewModel.onChangedOTPCode()
    // Then
    await expect(self.viewModel.navigation).toNotEventually(beNil())
  }
}

