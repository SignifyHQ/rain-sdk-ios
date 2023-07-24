import Combine

public final class PinTextFieldViewItem: ObservableObject, Identifiable {
  @Published public var isInFocus: Bool
  @Published public var text: String = ""
  public let placeHolderText: String
  public let tag: Int
  
  public init(
    text: String,
    placeHolderText: String,
    isInFocus: Bool = false,
    tag: Int
  ) {
    self.text = text
    self.placeHolderText = placeHolderText
    self.isInFocus = isInFocus
    self.tag = tag
  }
}
