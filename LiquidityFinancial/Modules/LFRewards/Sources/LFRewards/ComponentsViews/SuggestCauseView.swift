import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

  // MARK: - SuggestCauseButton

struct SuggestCauseButton: View {
  var body: some View {
    FullSizeButton(title: LFLocalizable.SuggestCause.title, isDisable: false, type: .secondary) {
      showInput = true
    }
    .fullScreenCover(isPresented: $showInput) {
      SuggestCauseView()
    }
  }
  
  @State private var showInput = false
}

  // MARK: - SuggestCauseView

struct SuggestCauseView: View {
  var body: some View {
    content
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            CircleButton(style: .xmark)
          }
        }
      }
      .popup(isPresented: $showSuccess, dismissMethods: []) {
        successPopup
      }
      .embedInNavigation()
  }
  
  @Environment(\.dismiss) private var dismiss
  @State private var input = ""
  @State private var isLoading = false
  @State private var showSuccess = false
  @FocusState private var keyboardFocus: Bool
  
  private var content: some View {
    VStack(alignment: .leading, spacing: 15) {
      Text(LFLocalizable.SuggestCause.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(ModuleColors.label.swiftUIColor)
        .padding(.bottom, 5)
      
      Text(LFLocalizable.SuggestCause.tellMore)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
      
      textField
      
      Spacer()
      
      submit
    }
    .padding([.horizontal, .top], 30)
    .background(ModuleColors.background.swiftUIColor)
  }
  
  private var textField: some View {
    VStack(alignment: .leading, spacing: 0) {
      Group {
        if #available(iOS 16.0, *) {
          TextField(LFLocalizable.SuggestCause.placeholder, text: $input, axis: .vertical)
        } else {
          TextField(LFLocalizable.SuggestCause.placeholder, text: $input)
        }
      }
      .primaryFieldStyle()
      .limitInputLength(value: $input, length: 1_000)
      .task {
        keyboardFocus = true
      }
      .focused($keyboardFocus)
      .padding(.horizontal, 10)
      
      Spacer()
        .frame(height: 15)
      
      Divider()
        .background(ModuleColors.separator.swiftUIColor)
      
      Spacer()
        .frame(height: 4)
      
      Text(LFLocalizable.SuggestCause.maxCharacters)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.5))
        .padding(.leading, 10)
    }
  }
  
  private var submit: some View {
    FullSizeButton(title: LFLocalizable.SuggestCause.submit, isDisable: isSubmitEnabled, isLoading: $isLoading) {
      submitAction()
    }
  }
  
  private var isSubmitEnabled: Bool {
    input.count > 5
  }
  
  private func submitAction() {
    isLoading = true
      // Simulate request until API is ready
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      showSuccess = true
      isLoading = false
    }
  }
  
  private var successPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.SuggestCause.Alert.title,
      message: LFLocalizable.SuggestCause.Alert.message,
      primary: .init(text: LFLocalizable.Button.Ok.title, action: dismissPopup),
      secondary: nil
    )
  }
  
  private func dismissPopup() {
    showSuccess = false
    dismiss()
  }
}

#if DEBUG

  // MARK: - SuggestCauseButton_Previews

struct SuggestCauseButton_Previews: PreviewProvider {
  static var previews: some View {
    SuggestCauseButton()
      .padding()
  }
}
#endif
