import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct InitialView: View {
  
  public init() {}
  
  var title: String {
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    return appName
  }
  
  public var body: some View {
    VStack(spacing: 32) {
      Spacer()
      ProgressView().progressViewStyle(.circular)
        .tint(Colors.Buttons.highlightButton.swiftUIColor)
      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: 120, height: 120)
      
      Text(title + "Card")
        .font(Fonts.Inter.bold.swiftUIFont(size: 24))
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    //.track(name: String(describing: type(of: self)))
    .background(Colors.background.swiftUIColor)
  }
  
}
