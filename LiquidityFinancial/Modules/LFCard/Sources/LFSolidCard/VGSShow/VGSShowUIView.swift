import Foundation
import SwiftUI
import UIKit
import Services
import LFStyleGuide
import LFUtilities
import VGSShowSDK
import BaseCard

class VGSShowUIView: UIView {
  private let labelColor: UIColor

  init(frame: CGRect, labelColor: UIColor) {
    self.labelColor = labelColor
    super.init(frame: frame)
    addSubview(stackView)
    cardNumberVGSLabel.borderColor = .clear
    cardCVVVGSLabel.borderColor = .clear
    stackView.addArrangedSubview(cardNumberVGSLabel)
    stackView.addArrangedSubview(cardExpirationDateVGSLabel)
    stackView.addArrangedSubview(cardCVVVGSLabel)
    stackView.setCustomSpacing(32, after: cardExpirationDateVGSLabel)
    stackView.pinToSuperviewEdges()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func bindToShowVGS(_ vgsShow: VGSShow) {
    vgsShow.unsubscribeAllViews()

    vgsShow.subscribe(cardNumberVGSLabel)
    vgsShow.subscribe(cardCVVVGSLabel)
  }

  func bindToShowData(cardData: CardModel, showCardNumber: Bool) {
    cardNumberVGSLabel.isSecureText = !showCardNumber
    cardCVVVGSLabel.isSecureText = !showCardNumber
    
    cardExpirationDateVGSLabel.text = showCardNumber
    ? cardData.expiryTime
    : Constants.Default.expirationDatePlaceholder.rawValue
    
    stackView.reloadInputViews()
  }

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal

    stackView.distribution = .fill
    return stackView
  }()

  private lazy var cardNumberVGSLabel: VGSLabel = {
    let label = VGSLabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.placeholder = Constants.Default.fullCardNumberPlaceholder.rawValue
    label.secureTextSymbol = Constants.Default.dotSymbol.rawValue
    label.font = Fonts.bold.font(size: Constants.FontSize.regular.value)
    label.placeholderStyle.color = labelColor
    label.textColor = labelColor
    label.placeholderStyle.textAlignment = .left
    label.placeholderStyle.font = Fonts.bold.font(size: Constants.FontSize.regular.value)
    label.textAlignment = .left
    label.delegate = self
    label.contentPath = "cardNumber"
    label.setSecureText(end: 13)
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)

    // Create regex object, split card number to XXXX XXXX XXXX XXXX format.
    do {
      let cardNumberPattern = "(\\d{4})(\\d{4})(\\d{4})(\\d{4})"
      let template = "$1 $2 $3 $4"
      let regex = try NSRegularExpression(pattern: cardNumberPattern, options: [])

      // Add transformation regex to your label.
      label.addTransformationRegex(regex, template: template)
    } catch {
      assertionFailure("invalid regex, error: \(error)")
    }

    return label
  }()

  private lazy var cardExpirationDateVGSLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = Fonts.bold.font(size: Constants.FontSize.regular.value)
    label.text = Constants.Default.expirationDatePlaceholder.rawValue
    label.textColor = labelColor
    label.textAlignment = .center
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return label
  }()

  private lazy var cardCVVVGSLabel: VGSLabel = {
    let label = VGSLabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.placeholder = Constants.Default.cvvPlaceholder.rawValue
    label.secureTextSymbol = Constants.Default.dotSymbol.rawValue
    label.font = Fonts.bold.font(size: Constants.FontSize.regular.value)
    label.placeholderStyle.color = labelColor
    label.placeholderStyle.font = Fonts.bold.font(size: Constants.FontSize.regular.value)
    label.textColor = labelColor
    label.placeholderStyle.textAlignment = .right
    label.textAlignment = .right
    label.delegate = self
    label.contentPath = "cvv"
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return label
  }()
}

// MARK: - VGSLabelDelegate
extension VGSShowUIView: VGSLabelDelegate {
  func labelRevealDataDidFail(_ label: VGSLabel, error: VGSShowError) {
    log.error("Label Reveal Data Did Fail: \(error)")
  }
}
