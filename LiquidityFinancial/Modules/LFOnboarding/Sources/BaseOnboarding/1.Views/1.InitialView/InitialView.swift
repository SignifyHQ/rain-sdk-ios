import SwiftUI
import LFStyleGuide

public struct InitialView: View {
  
  public init() {}
  
  public var body: some View {
    ZStack {
      Colors.backgroundPrimary.swiftUIColor

      GenImages.Images.imgLogoSplash.swiftUIImage
    }
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity
    )
    .ignoresSafeArea()
    .track(
      name: String(describing: type(of: self))
    )
  }
}
