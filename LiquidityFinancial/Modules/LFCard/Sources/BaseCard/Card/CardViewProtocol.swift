import Foundation
import SwiftUI

public protocol CardViewProtocol: View {
  var isShowCardNumber: Bool { get }
  var cardMetaData: CardMetaData? { get }
  var isLoading: Bool { get }
  
  init(
    cardModel: CardModel,
    cardMetaData: Binding<CardMetaData?>,
    isShowCardNumber: Binding<Bool>,
    isLoading: Binding<Bool>
  )
}
