import Combine

final class PinTextFieldViewItem: ObservableObject, Identifiable {
  @Published var isInFocus: Bool
  @Published var text: String = ""
  let placeHolderText: String
  let tag: Int
  
  init(
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
