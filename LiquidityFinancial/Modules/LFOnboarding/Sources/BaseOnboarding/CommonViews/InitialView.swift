import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services

public struct InitialView: View {
  
  public init() {}
  
  var title: String {
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    return appName
  }
  
  public var body: some View {
    VStack(spacing: 8) {

      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: 126, height: 126)
      
      Text(LFLocalizable.Initial.Label.title(title))
        .font(Fonts.bold.swiftUIFont(size: 24))
        .foregroundColor(Colors.label.swiftUIColor)
        .frame(height: 34)

      ProgressView().progressViewStyle(.circular)
        .tint(Colors.primary.swiftUIColor)

    }
    .frame(maxWidth: .infinity)
    .frame(maxHeight: .infinity)
    .background(Colors.background.swiftUIColor)
    .track(name: String(describing: type(of: self)))
  }
  
}
