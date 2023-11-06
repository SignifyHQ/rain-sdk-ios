import Foundation
import SwiftUI
import UIKit
import Services
import VGSShowSDK
import BaseCard

/// Wrapper for UIKit view with VGSShow views.
struct VGSShowView: UIViewRepresentable {
  let vgsShow: VGSShow
  @Binding var cardModel: CardModel
  @Binding var showCardNumber: Bool
  let labelColor: Color

  func makeUIView(context _: UIViewRepresentableContext<VGSShowView>) -> VGSShowUIView {
    let vgsShowUIView = VGSShowUIView(frame: .zero, labelColor: labelColor.uiColor)
    vgsShowUIView.bindToShowVGS(vgsShow)
    return vgsShowUIView
  }

  func updateUIView(_ uiView: VGSShowUIView, context _: Context) {
    uiView.bindToShowData(cardData: cardModel, showCardNumber: showCardNumber)
  }
}
