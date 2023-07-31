import Foundation
import SwiftUI
import UIKit
import VGSShowSDK
import LFUtilities
import LFStyleGuide

struct VGSShowView: UIViewRepresentable {
  let vgsShow: VGSShow
  @Binding var cardModel: CardModel
  @Binding var showCardNumber: Bool
  
  func makeUIView(context _: UIViewRepresentableContext<VGSShowView>) -> VGSShowUIView {
    let vgsShowUIView = VGSShowUIView(frame: .zero, labelColor: Colors.label.color)
    vgsShowUIView.bindToShowVGS(vgsShow)
    return vgsShowUIView
  }
  
  func updateUIView(_ uiView: VGSShowUIView, context _: Context) {
    uiView.bindToShowData(cardData: cardModel, showCardNumber: showCardNumber)
  }
}

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
    
    if showCardNumber {
      let dtStr = cardData.expiryMonth.count > 2 ? String(cardData.expiryYear.suffix(2)) : cardData.expiryYear
      cardExpirationDateVGSLabel.text = "\(cardData.expiryMonth)/\(dtStr)"
    } else {
      cardExpirationDateVGSLabel.text = Constants.Default.vgsExpirationDate.rawValue
    }
    
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
    label.placeholder = Constants.Default.vgsCardNumber.rawValue
    label.secureTextSymbol = Constants.Default.dotSymbol.rawValue
    label.font = Fonts.bold.font(size: 13)
    label.placeholderStyle.color = labelColor
    label.textColor = labelColor
    label.placeholderStyle.textAlignment = .left
    label.placeholderStyle.font = Fonts.bold.font(size: 13)
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
    label.font = Fonts.bold.font(size: 13)
    label.text = Constants.Default.vgsExpirationDate.rawValue
    label.textColor = labelColor
    label.textAlignment = .center
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return label
  }()
  
  private lazy var cardCVVVGSLabel: VGSLabel = {
    let label = VGSLabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.placeholder = Constants.Default.vgsCVV.rawValue
    label.secureTextSymbol = Constants.Default.dotSymbol.rawValue
    label.font = Fonts.bold.font(size: 13)
    label.placeholderStyle.color = labelColor
    label.placeholderStyle.font = Fonts.bold.font(size: 13)
    label.textColor = labelColor
    label.placeholderStyle.textAlignment = .right
    label.textAlignment = .right
    label.delegate = self
    label.contentPath = "cvv"
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return label
  }()
}

// MARK: VGSLabelDelegate
extension VGSShowUIView: VGSLabelDelegate {
  func labelRevealDataDidFail(_ label: VGSLabel, error: VGSShowError) {}
}
