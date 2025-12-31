import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

// MARK: - LearnMoreView

public struct LearnMoreView: View {
  @Environment(\.dismiss) private var dismiss

  public init() {}

  public var body: some View {
    VStack(spacing: 32) {
      header
      content
      closeButton
        .padding(.bottom, 16)
    }
    .padding(.horizontal, 24)
    .background(Colors.grey900.swiftUIColor)
  }
}

private extension LearnMoreView {
  var header: some View {
    Text(L10N.Common.LearnMore.title)
      .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.main.value))
      .foregroundColor(Colors.textPrimary.swiftUIColor)
      .multilineTextAlignment(.center)
      .padding(.horizontal, 24)
      .padding(.top, 24)
  }
  
  var content: some View {
    VStack(
      alignment: .leading,
      spacing: 32
    ) {
      Text(L10N.Common.LearnMore.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .fixedSize(horizontal: false, vertical: true)
      
      VStack(
        alignment: .leading,
        spacing: 16
      ) {
        Text(L10N.Common.LearnMore.howToMakeSure)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
        
        VStack(alignment: .leading, spacing: 8) {
          bulletPoint(text: L10N.Common.LearnMore.bullet1)
          bulletPoint(text: L10N.Common.LearnMore.bullet2)
          bulletPoint(text: L10N.Common.LearnMore.bullet3)
        }
      }
    }
  }
  
  func bulletPoint(text: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Circle()
        .fill(Colors.textPrimary.swiftUIColor)
        .frame(width: 6, height: 6)
        .padding(.top, 6)
      
      Text(text)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var closeButton: some View {
    FullWidthButton(
      type: .primary,
      backgroundColor: Colors.buttonSurfacePrimary.swiftUIColor,
      title: L10N.Common.LearnMore.closeButton,
      action: {
        dismiss()
      }
    )
  }
}
