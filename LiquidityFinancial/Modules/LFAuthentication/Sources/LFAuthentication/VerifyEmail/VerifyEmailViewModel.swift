import AccountData
import AccountDomain
import Combine
import Factory
import Foundation
import LFStyleGuide
import LFUtilities

@MainActor
public final class VerifyEmailViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isLoading: Bool = false
  @Published var shouldPresentConfirmation: Bool = false
  @Published var toastMessage: String?
  @Published public var isOTPCodeEntered: Bool = false
  
  @Published public var generatedOTP: String = .empty
  
  public var otpViewItems: [PinTextFieldViewItem] = .init()
  
  lazy var verifyEmailRequestUseCase: VerifyEmailRequestUseCaseProtocol = {
    VerifyEmailRequestUseCase(repository: accountRepository)
  }()
  
  lazy var verifyEmailUseCase: VerifyEmailUseCaseProtocol = {
    VerifyEmailUseCase(repository: accountRepository)
  }()
  
  init() {
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
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        try await verifyEmailUseCase.execute(code: generatedOTP)
        // TODO(Volodymyr): update missing steps here
        
        shouldPresentConfirmation = true
      } catch {
        toastMessage = error.userFriendlyMessage
        log.error(error.localizedDescription)
      }
    }
  }
  
  func requestOTP() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        try await verifyEmailRequestUseCase.execute()
      } catch {
        toastMessage = error.userFriendlyMessage
        log.error(error.localizedDescription)
      }
    }
  }
}

// MARK: - View Helpers
public extension VerifyEmailViewModel {
  func observeOTPInput() {
    $generatedOTP
      .map { otp in
        otp.count == 6
      }
      .assign(to: &$isOTPCodeEntered)
  }
  
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

// MARK: - Private Functions
private extension VerifyEmailViewModel {
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
}
