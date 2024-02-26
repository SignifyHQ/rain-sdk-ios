import Foundation
import Combine
import Factory
import SolidData
import SolidDomain
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFFeatureFlags
import GeneralFeature
import VGSShowSDK
import Services
import SwiftUI
import BiometricsManager

@MainActor
final class VGSCardViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.biometricsManager) var biometricsManager
  @LazyInjected(\.featureFlagManager) var featureFlagManager

  lazy var createVGSShowTokenUseCase: SolidCreateVGSShowTokenUseCaseProtocol = {
    SolidCreateVGSShowTokenUseCase(repository: solidCardRepository)
  }()
  
  @Published var isCardAvailable = false
  @Published var isShowCardNumber = false
  @Published var isShowExpDateAndCVVCode = false
  @Published var copyMessage: String?
  @Published var toastMessage: String?
  @Published var animationTask: DispatchWorkItem?
  
  @Published var biometricType: BiometricType = .none
  @Published var popup: Popup?

  let vgsShow = VGSShow(id: LFServices.vgsConfig.id, environment: LFServices.vgsConfig.env)
  private let pasteboard = UIPasteboard.general
  
  private var subscribers: Set<AnyCancellable> = []
  
  init(card: CardModel) {
    checkBiometricsCapability()
    getVGSShowTokenAPI(card: card)
  }
}

// MARK: - API Handler
private extension VGSCardViewModel {
  func getVGSShowTokenAPI(card: CardModel) {
    Task {
      guard card.cardStatus != .closed else {
        isCardAvailable = true
        return
      }
      isCardAvailable = false
      
      do {
        let response = try await createVGSShowTokenUseCase.execute(cardID: card.id)
        revealCard(showToken: response.showToken, cardID: response.solidCardId)
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Handler
extension VGSCardViewModel {
  func hideSensitiveData() {
    isShowCardNumber = false
    isShowExpDateAndCVVCode = false
  }
  
  func copyToClipboard(type: VGSLabelType, card: CardModel) {
    animationTask?.cancel()
    animationTask = DispatchWorkItem { [weak self] in
      self?.copyMessage = nil
    }
    
    switch type {
    case .cardNumber:
      pasteboard.string = getVGSLabelText(with: type.rawValue)
      copyMessage = L10N.Common.Card.CardNumberCopied.title
    case .expDate:
      if isShowExpDateAndCVVCode {
        pasteboard.string = "\(card.expirationDate)"
        copyMessage = L10N.Common.Card.ExpiryDateCopied.title
      }
    case .cvvCode:
      pasteboard.string = getVGSLabelText(with: type.rawValue)
      copyMessage = L10N.Common.Card.CvvCodeCopied.title
    }
    
    guard let animationTaskUnwrap = animationTask else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: animationTaskUnwrap)
  }
  
  func onClickAsteriskSymbol(type: VGSLabelType, card: CardModel) {
    let isEnableAuthenticateWithBiometrics = UserDefaults.isBiometricUsageEnabled && featureFlagManager.isFeatureFlagEnabled(.passwordLogin)
    guard isEnableAuthenticateWithBiometrics else {
      showSensitiveCardData(type: type)
      copyToClipboard(type: type, card: card)
      return
    }
    
    authenticateWithBiometrics(type: type, card: card)
  }
  
  func showSensitiveCardData(type: VGSLabelType) {
    switch type {
    case .cardNumber:
      isShowCardNumber = true
    case .expDate, .cvvCode:
      isShowExpDateAndCVVCode = true
    }
  }
  
  func openDeviceSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  func hidePopup() {
    popup = nil
  }
}

// MARK: - Private Functions
private extension VGSCardViewModel {
  func revealCard(showToken: String, cardID: String) {
    let path = "/v1/card/\(cardID)/show"
    vgsShow.customHeaders = ["sd-show-token": showToken]
    
    vgsShow.request(path: path, method: .get) { [weak self] requestResult in
      guard let self else { return }
      
      switch requestResult {
      case let .success(code):
        self.isCardAvailable = true
        log.info("VGSShow success, code: \(code)")
      case let .failure(code, _):
        log.error("VGSShow failed with code: \(code)")
      }
    }
  }
  
  func getVGSLabelText(with index: Int) -> String {
    guard index < vgsShow.subscribedLabels.count else {
      return .empty
    }
    let text = vgsShow.subscribedLabels[index] as VGSLabel
    text.copyTextToClipboard()
    
    return pasteboard.string ?? .empty
  }
  
  func checkBiometricsCapability() {
    biometricsManager.checkBiometricsCapability(purpose: .enable)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          log.debug("Biometrics capability check completed.")
        case .failure(let error):
          log.error("Biometrics capability error: \(error)")
        }
      }, receiveValue: { [weak self] result in
        guard let self else { return }
        self.biometricType = result.type
      })
      .store(in: &subscribers)
  }
  
  func authenticateWithBiometrics(type: VGSLabelType, card: CardModel) {
    biometricsManager.performBiometricsAuthentication(purpose: .enable)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        switch completion {
        case .finished:
          log.debug("Biometrics authenticate completed.")
        case .failure(let error):
          self?.handleBiometricAuthenticationError(error: error)
        }
      }, receiveValue: { [weak self] _ in
        guard let self else { return }
        self.showSensitiveCardData(type: type)
        self.copyToClipboard(type: type, card: card)
      })
      .store(in: &subscribers)
  }
  
  func handleBiometricAuthenticationError(error: BiometricError) {
    log.error("Biometrics error: \(error.localizedDescription)")
    switch error {
    case .biometryNotAvailable:
      popup = .biometryNotAvailable
    case .biometryNotEnrolled:
      popup = .biometryNotEnrolled(
        title: L10N.Common.Authentication.BiometricsNotEnrolled.title(biometricType.title),
        message: L10N.Common.Authentication.BiometricsNotEnrolled.message(biometricType.title)
      )
    case .biometryLockout:
      self.popup = .biometryLockout(
        title: L10N.Common.Authentication.BiometricsLockoutError.title(biometricType.title),
        message: L10N.Common.Authentication.BiometricsLockoutError.message(biometricType.title)
      )
    default:
      break
    }
  }
}

// MARK: - Types
extension VGSCardViewModel {
  enum VGSLabelType: Int {
    case cardNumber
    case cvvCode
    case expDate
  }
  
  enum Popup {
    case biometryLockout(title: String, message: String)
    case biometryNotEnrolled(title: String, message: String)
    case biometryNotAvailable
  }
}
