import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

struct ActivatePhysicalCardInputView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ActivatePhysicalCardInputViewModel
  @FocusState private var isFocused: Bool
  
  let onDissmiss: ((String) -> Void)?
  
  init(
    viewModel: ActivatePhysicalCardInputViewModel,
    onDissmiss: @escaping (String) -> Void
  ) {
    _viewModel = .init(wrappedValue: viewModel)
    self.onDissmiss = onDissmiss
  }
  
  var body: some View {
    content
      .track(name: String(describing: type(of: self)))
      .withLoadingIndicator(
        isShowing: $viewModel.isLoading,
        isOpaque: false
      )
  }
}

extension ActivatePhysicalCardInputView {
  var content: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(L10N.Common.ActivatePhysicalCard.Screen.subtitle)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .fixedSize(horizontal: false, vertical: true)
      
      VStack(spacing: 12) {
        OTPField(
          code: $viewModel.panLast4,
          isSecureInput: true
        )
        .focused($isFocused)
        .onAppear {
          isFocused = true
        }
        
        if let errorMessage = viewModel.errorInlineMessage {
          Text(errorMessage)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.red400.swiftUIColor)
        }
      }
      
      Spacer()
      
      FullWidthButton(
        title: L10N.Common.Common.Continue.Button.title,
        isDisabled: !viewModel.isPanLast4Entered
      ) {
        hideKeyboard()
        viewModel.activatePhysicalCard { cardID in
          onDissmiss?(cardID)
        }
      }
    }
  }
}
