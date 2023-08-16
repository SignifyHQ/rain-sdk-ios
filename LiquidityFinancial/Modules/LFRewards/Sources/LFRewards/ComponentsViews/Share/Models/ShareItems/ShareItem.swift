import UIKit
import SwiftUI

protocol ShareItem {
  var name: String { get }
  var image: Image { get }
  var isValid: Bool { get }
  func share(card: UIImage?)
}

enum ShareItemAction {
  case startLoading(item: String)
  case succeeded
  case failed(item: String)
}
