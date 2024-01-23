import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct SkipFundraiserView: View {
  let destination: () -> Void
  
  var body: some View {
    content
  }
  
  @State private var showPersonalInfo = false
  
  private var content: some View {
    Button {
      destination()
    } label: {
      Text(L10N.Common.Button.Skip.title)
        .font(Fonts.bold.swiftUIFont(size: 12))
        .foregroundColor(ModuleColors.label.swiftUIColor)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(ModuleColors.buttons.swiftUIColor)
        .cornerRadius(32)
    }
  }
}

extension SkipFundraiserView {
  enum Destination {
    case personalInfo(() -> Void)
  }
}
