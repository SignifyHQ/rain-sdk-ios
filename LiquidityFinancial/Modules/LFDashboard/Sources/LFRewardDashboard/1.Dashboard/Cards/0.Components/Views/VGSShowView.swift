import Foundation
import SwiftUI
import UIKit
import Services
import VGSShowSDK

/// Wrapper for UIKit view with VGSShow views.
struct VGSShowView: UIViewRepresentable {
  @Binding var isShowCardNumber: Bool
  @Binding var isShowExpDateAndCVVCode: Bool
  
  let vgsShow: VGSShow
  let cardModel: CardModel
  let labelColor: Color
  let copyExpiryDateAction: (() -> Void)
  let copyCVVCodeAction: (() -> Void)

  func makeUIView(context _: UIViewRepresentableContext<VGSShowView>) -> VGSShowUIView {
    let vgsShowUIView = VGSShowUIView(
      frame: .zero,
      labelColor: labelColor.uiColor,
      copyExpiryDateAction: copyExpiryDateAction,
      copyCVVCodeAction: copyCVVCodeAction
    )
    vgsShowUIView.bindToShowVGS(vgsShow)
    return vgsShowUIView
  }

  func updateUIView(_ uiView: VGSShowUIView, context _: Context) {
    uiView.bindToShowData(
      cardData: cardModel,
      isShowCardNumber: isShowCardNumber,
      isShowExpDateAndCVVCode: isShowExpDateAndCVVCode
    )
  }
}
