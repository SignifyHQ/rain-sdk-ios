import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct InitialView: View {
  
  var title: String {
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    return appName
  }
  
  var body: some View {
    VStack(spacing: 8) {

      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: 126, height: 126)
      
      Text(title + "Card")
        .font(Fonts.bold.swiftUIFont(size: 24))
        .foregroundColor(Colors.label.swiftUIColor)
        .frame(height: 34)

      ProgressView().progressViewStyle(.circular)
        .tint(Colors.Buttons.highlightButton.swiftUIColor)

    }
    .frame(maxWidth: .infinity)
    .frame(maxHeight: .infinity)
    //.track(name: String(describing: type(of: self)))
    .background(Colors.background.swiftUIColor)
  }
  
}
