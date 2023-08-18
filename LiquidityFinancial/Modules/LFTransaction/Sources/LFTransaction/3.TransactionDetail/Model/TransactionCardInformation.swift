import SwiftUI
import LFStyleGuide

public struct TransactionCardInformation {
  let title: String
  let amount: String
  let message: String
  let activityItem: String
  let image: ImageAsset
  let backgroundColor: Color
  
  public init(
    title: String,
    amount: String,
    message: String,
    activityItem: String,
    image: ImageAsset,
    backgroundColor: Color = Colors.primary.swiftUIColor
  ) {
    self.title = title
    self.amount = amount
    self.message = message
    self.activityItem = activityItem
    self.backgroundColor = backgroundColor
    self.image = image
  }
}
