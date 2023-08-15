import Foundation
import UIKit

protocol ShareItem {
  var name: String { get }
  var image: String { get }
  var isValid: Bool { get }
  func share(card: UIImage?)
}

enum ShareItemAction {
  case startLoading(item: String)
  case succeeded
  case failed(item: String)
}
