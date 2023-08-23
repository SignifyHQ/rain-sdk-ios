import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct EmptyListView: View {
  let text: String
  
  var body: some View {
    VStack(spacing: 8) {
      ModuleImages.icEmptyList.swiftUIImage
        .resizable()
        .frame(28)
        .foregroundColor(Colors.label.swiftUIColor)
      Text(text)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }
}

struct EmptyListView_Previews: PreviewProvider {
  static var previews: some View {
    EmptyListView(text: "No rewards yet")
  }
}
