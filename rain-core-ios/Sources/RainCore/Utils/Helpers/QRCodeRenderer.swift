import CoreGraphics
import Foundation
import QRCode

/// Renders address QR codes as PNG data. Shared by
/// ``RainClient/generateAddressQRCode(address:dimension:backgroundColor:foregroundColor:)`` and
/// ``RainClient/generateWalletAddressQRCode(dimension:backgroundColor:foregroundColor:)``.
enum QRCodeRenderer {
  /// Default colours, applied when a caller passes `nil`: dark modules on a light background,
  /// the orientation scanners expect.
  static let defaultBackgroundColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
  static let defaultForegroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)

  static func png(
    text: String,
    dimension: Int,
    backgroundColor: CGColor?,
    foregroundColor: CGColor?
  ) throws -> Data {
    guard let image = try? QRCode.build
      .text(text)
      .foregroundColor(foregroundColor ?? defaultForegroundColor)
      .backgroundColor(backgroundColor ?? defaultBackgroundColor)
      .background.cornerRadius(0)
      .onPixels.shape(QRCode.PixelShape.RoundedPath(cornerRadiusFraction: 0))
      .eye.shape(QRCode.EyeShape.RoundedRect())
      .pupil.shape(QRCode.PupilShape.Square())
      .generate.image(dimension: dimension, representation: .png())
    else {
      throw RainSDKError.internalLogicError(details: "QR code image generation failed")
    }
    return image
  }
}
