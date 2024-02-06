import Foundation
import SwiftUI
import UIKit
import Services
import LFStyleGuide
import LFUtilities
import VGSShowSDK

class VGSShowUIView: UIView {
  private let labelColor: UIColor
  private let copyAction: (() -> Void)

  init(frame: CGRect, labelColor: UIColor, copyAction: @escaping () -> Void) {
    self.labelColor = labelColor
    self.copyAction = copyAction
    super.init(frame: frame)
    
    addSubview(mainStackView)
    cardNumberVGSLabel.borderColor = .clear
    cvvVGSLabel.borderColor = .clear
    
    mainStackView.addArrangedSubview(topSpacer)
    mainStackView.addArrangedSubview(cardNumberVGSLabel)
    mainStackView.addArrangedSubview(bottomView)
    mainStackView.pinToSuperviewEdges()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var mainStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical

    stackView.distribution = .fill
    return stackView
  }()
  
  private lazy var bottomView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(expirationDateVGSLabel)
    view.addSubview(cvvVGSLabel)
    
    NSLayoutConstraint.activate([
      expirationDateVGSLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      expirationDateVGSLabel.topAnchor.constraint(equalTo: view.topAnchor),
      expirationDateVGSLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      expirationDateVGSLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2)
    ])
    
    NSLayoutConstraint.activate([
      cvvVGSLabel.leadingAnchor.constraint(equalTo: expirationDateVGSLabel.trailingAnchor, constant: 64),
      cvvVGSLabel.topAnchor.constraint(equalTo: view.topAnchor),
      cvvVGSLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      cvvVGSLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1)
    ])

    return view
  }()

  private lazy var topSpacer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
    
    return view
  }()
  
  private lazy var cardNumberVGSLabel: VGSLabel = {
    let label = VGSLabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    label.font = Fonts.medium.font(size: Constants.FontSize.medium.value)
    label.textColor = labelColor
    label.textAlignment = .center
    
    label.delegate = self
    label.contentPath = Constants.Default.cardNumberContentPath.rawValue
    label.setSecureText(end: 13)
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    
    transformCardNumberFormat(from: label)
    
    return label
  }()
  
  private lazy var cvvVGSLabel: VGSLabel = {
    let label = VGSLabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    label.font = Fonts.medium.font(size: Constants.FontSize.medium.value)
    label.textColor = labelColor.withAlphaComponent(0.75)
    label.textAlignment = .center
    
    // Add a tap gesture recognizer to the label
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(copiedToClipboard))
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(tapGesture)
    
    label.delegate = self
    label.contentPath = Constants.Default.cvvContentPath.rawValue
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
    return label
  }()
  
  private lazy var expirationDateVGSLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    label.text = Constants.Default.expirationDateAsteriskPlaceholder.rawValue
    label.font = Fonts.medium.font(size: Constants.FontSize.medium.value)
    label.textColor = labelColor.withAlphaComponent(0.75)
    label.textAlignment = .left
    
    // Add a tap gesture recognizer to the label
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(copiedToClipboard))
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(tapGesture)
    
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
    return label
  }()
}

// MARK: - Functions
extension VGSShowUIView {
  func bindToShowVGS(_ vgsShow: VGSShow) {
    vgsShow.unsubscribeAllViews()

    vgsShow.subscribe(cardNumberVGSLabel)
    vgsShow.subscribe(cvvVGSLabel)
  }

  func bindToShowData(cardData: CardModel, isShowCardNumber: Bool, isShowExpDateAndCVVCode: Bool) {
    topSpacer.isHidden = isShowCardNumber
    cardNumberVGSLabel.isHidden = !isShowCardNumber
    cardNumberVGSLabel.isSecureText = !isShowCardNumber
    
    cvvVGSLabel.isHidden = !isShowExpDateAndCVVCode
    cvvVGSLabel.isSecureText = !isShowExpDateAndCVVCode
    
    expirationDateVGSLabel.text = isShowExpDateAndCVVCode
    ? cardData.expirationDate
    : .empty
    
    mainStackView.reloadInputViews()
  }
  
  /// Create regex object, split card number to XXXX XXXX XXXX XXXX format.
  func transformCardNumberFormat(from label: VGSLabel) {
    do {
      let regex = try NSRegularExpression(
        pattern: Constants.Default.cardNumberPattern.rawValue,
        options: []
      )
      let template = createCardNumberTemplate(repetitions: 3)
      
      // Add transformation regex to your label.
      label.addTransformationRegex(regex, template: template)
    } catch {
      assertionFailure("Invalid regex, error: \(error)")
    }
  }
  
  func createSpacedText(pattern: String, spacing: String, repetitions: Int) -> String {
    let spacedTextArray = Array(repeating: pattern, count: repetitions)
    let result = spacedTextArray.joined(separator: spacing)
    return result
  }
  
  func createCardNumberTemplate(repetitions: Int) -> String {
    let cardNumberWithSpacingWidth = 242.0
    let remainingWidth = (UIScreen.main.bounds.width - cardNumberWithSpacingWidth)
    let spaceWidth = remainingWidth / CGFloat(repetitions)
    let numberOfSpaceCharacters = Int(spaceWidth / 4)
    let spaceText = String(repeating: " ", count: numberOfSpaceCharacters)
    
    return Constants.Default.cardNumberTemplate.rawValue.replace(string: " ", replacement: spaceText)
  }
  
  @objc func copiedToClipboard() {
    copyAction()
  }
}

// MARK: - VGSLabelDelegate
extension VGSShowUIView: VGSLabelDelegate {
  func labelRevealDataDidFail(_ label: VGSLabel, error: VGSShowError) {
    log.error("Label Reveal Data Did Fail: \(error)")
  }
}
