import UIKit

public extension UIImage {
  
  func resizedWidth(toWidth width: CGFloat) -> UIImage? {
    let canvasSize = CGSize(width: round(width), height: CGFloat(ceil(width / size.width * size.height)))
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    let context = UIGraphicsGetCurrentContext()
    context?.interpolationQuality = .none
    // Set the quality level to use when rescaling
    draw(in: CGRect(origin: .zero, size: canvasSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
