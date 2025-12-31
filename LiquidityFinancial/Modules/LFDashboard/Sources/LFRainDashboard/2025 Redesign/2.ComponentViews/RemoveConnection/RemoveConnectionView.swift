import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI
import MeshData

struct RemoveConnectionView: View {
  @Environment(\.dismiss) private var dismiss
  
  let method: MeshPaymentMethod
  let action: (() -> Void)
  
  var body: some View {
    VStack(spacing: 32) {
      headerView
      contentView
      buttonGroup
        .padding(.bottom, 16)
    }
    .padding(.horizontal, 24)
    .background(Colors.grey900.swiftUIColor)
  }
}

private extension RemoveConnectionView {
  var headerView: some View {
    Text(L10N.Common.RemoveConnection.Popup.title(method.brokerName))
      .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.main.value))
      .foregroundColor(Colors.textPrimary.swiftUIColor)
      .multilineTextAlignment(.center)
      .padding(.top, 24)
  }
  
  var contentView: some View {
    VStack(
      alignment: .leading,
      spacing: 32
    ) {
      // USE BASE 64 AFTER FIX IS APPLIED
      /*
      Image.fromBase64(method.brokerBase64Logo)?
        .resizable()
        .frame(width: 48, height: 48)
      */
      
      Text(L10N.Common.RemoveConnection.Popup.description(method.brokerName))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var buttonGroup: some View {
    VStack(spacing: 12) {
      removeButton
      closeButton
    }
    .frame(maxWidth: .infinity)
  }
  
  var removeButton: some View {
    FullWidthButton(
      type: .primary,
      backgroundColor: Colors.buttonSurfacePrimary.swiftUIColor,
      title: L10N.Common.Common.Remove.Button.title,
      action: action
    )
  }
  
  var closeButton: some View {
    FullWidthButton(
      type: .secondary,
      backgroundColor: .clear,
      borderColor: Colors.greyDefault.swiftUIColor,
      title: L10N.Common.LearnMore.closeButton,
      action: {
        dismiss()
      }
    )
  }
}
