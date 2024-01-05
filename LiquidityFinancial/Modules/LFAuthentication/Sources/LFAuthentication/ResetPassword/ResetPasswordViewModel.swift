import AccountData
import AccountDomain
import Combine
import Factory
import Foundation
import LFStyleGuide
import LFUtilities

@MainActor
public final class ResetPasswordViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var navigation: Navigation?
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published public var isOTPCodeEntered: Bool = false
  @Published public var generatedOTP: String = .empty
  
  let purpose: ResetPasswordPurpose

  public var otpViewItems: [PinTextFieldViewItem] = .init()
  
  lazy var resetPasswordRequestUseCase: ResetPasswordRequestUseCaseProtocol = {
    ResetPasswordRequestUseCase(repository: accountRepository)
  }()
  
  lazy var resetPasswordVerifyUseCase: ResetPasswordVerifyUseCaseProtocol = {
    ResetPasswordVerifyUseCase(repository: accountRepository)
  }()
  
  init(purpose: ResetPasswordPurpose) {
    self.purpose = purpose
    createTextFields()
    observeOTPInput()
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func didTapResendCodeButton() {
    requestOTP()
  }
  
  func didTapContinueButton() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        let phoneNumber = getPhoneNumber()
        let response = try await resetPasswordVerifyUseCase.execute(phoneNumber: phoneNumber, code: generatedOTP)
        navigation = .resetPassword(
          purpose: .resetPassword(token: response.token, phoneNumber: phoneNumber)
        )
      } catch {
        handleError(error: error)
      }
    }
  }
  
  func requestOTP() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        let phoneNumber = getPhoneNumber()
        try await resetPasswordRequestUseCase.execute(phoneNumber: phoneNumber)
      } catch {
        handleError(error: error)
      }
    }
  }
}

// MARK: - View Helpers
public extension ResetPasswordViewModel {
  func textFieldTextChange(replacementText: String, viewItem: PinTextFieldViewItem) {
    guard replacementText.count <= 1
    else {
      otpViewItems
        .forEach { item in
          if let index = replacementText.index(
            replacementText.startIndex,
            offsetBy: item.tag,
            limitedBy: replacementText.endIndex
          ) {
            let characterAtIndex = replacementText[index]
            item.text = String(characterAtIndex)
          }
        }
      
      sendOTP()
      return
    }
    
    if replacementText.isEmpty,
       viewItem.text.isEmpty {
      if let previousViewItem = previousViewItemFrom(tag: viewItem.tag) {
        previousViewItem.text = .empty
        viewItem.isInFocus = false
        previousViewItem.isInFocus = true
      }
    } else {
      if let nextViewItem = nextViewItemFrom(tag: viewItem.tag) {
        viewItem.isInFocus = false
        nextViewItem.isInFocus = true
      }
    }
    viewItem.text = replacementText
    
    sendOTP()
  }
  
  func onTextFieldBackPressed(viewItem: PinTextFieldViewItem) {
    if let previousViewItem = previousViewItemFrom(tag: viewItem.tag) {
      previousViewItem.text = .empty
      viewItem.isInFocus = false
      previousViewItem.isInFocus = true
    }
    
    sendOTP()
  }
}

// MARK: - Enums

extension ResetPasswordViewModel {
  enum Navigation {
    case resetPassword(purpose: CreatePasswordPurpose)
  }
}

public enum ResetPasswordPurpose: Equatable {
  case resetPassword
  case login(phoneNumber: String)
  
  public static func == (lhs: ResetPasswordPurpose, rhs: ResetPasswordPurpose) -> Bool {
    switch (lhs, rhs) {
    case (.resetPassword, .resetPassword):
      return true
    case let (.login(lhsphoneNumber), .login(rhsphoneNumber)):
      return lhsphoneNumber == rhsphoneNumber
    default:
      return false
    }
  }
}

// MARK: - Private Functions
private extension ResetPasswordViewModel {
  func observeOTPInput() {
    $generatedOTP
      .map { otp in
        otp.count == 6
      }
      .assign(to: &$isOTPCodeEntered)
  }
  
  func createTextFields() {
    for index in 0 ..< 6 {
      let viewItem = PinTextFieldViewItem(
        text: "",
        placeHolderText: "",
        isInFocus: false,
        tag: index
      )
      
      otpViewItems.append(viewItem)
    }
  }
  
  func nextViewItemFrom(tag: Int) -> PinTextFieldViewItem? {
    let nextTextItemTag = tag + 1
    if nextTextItemTag < otpViewItems.count {
      return otpViewItems.first(where: { $0.tag == nextTextItemTag })
    }
    return nil
  }
  
  func previousViewItemFrom(tag: Int) -> PinTextFieldViewItem? {
    let previousTextItemTag = tag - 1
    if previousTextItemTag >= 0 {
      return otpViewItems.first(where: { $0.tag == previousTextItemTag })
    }
    return nil
  }
  
  func generateOtp() -> String? {
    otpViewItems.reduce(into: "") { partialResult, textFieldViewItem in
      partialResult.append(textFieldViewItem.text)
    }
  }

  func sendOTP() {
    if let otp = generateOtp() {
      generatedOTP = otp
    }
  }
  
  func handleError(error: Error) {
    toastMessage = error.userFriendlyMessage
    log.error(error.userFriendlyMessage)
  }
  
  func getPhoneNumber() -> String {
    switch purpose {
    case .resetPassword:
      return accountDataManager.phoneNumber
    case let .login(phoneNumber):
      return phoneNumber
    }
  }
}
