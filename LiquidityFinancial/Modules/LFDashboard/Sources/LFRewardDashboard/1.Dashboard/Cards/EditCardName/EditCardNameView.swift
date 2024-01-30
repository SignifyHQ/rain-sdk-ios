import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct EditCardNameView: View {
  @Environment(\.dismiss)
  private var dismiss
  @StateObject
  private var viewModel: EditCardNameViewModel
  @FocusState
  private var isFieldFocused: Bool?
    
  init(viewModel: EditCardNameViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    GeometryReader { proxy in
      VStack {
        topView
        inlineErrorMessageView
        Spacer()
        continueButtonView
      }
      .overlay(alignment: .topTrailing) {
        cardNameDisclosureView(width: proxy.size.width * 0.58)
      }
      .padding(.horizontal, 30)
      .padding(.bottom, 16)
      .background(Colors.background.swiftUIColor)
    }
    .onTapGesture {
      isFieldFocused = nil
      viewModel.hideDisclosure()
    }
    .defaultToolBar(icon: .support, openSupportScreen: {
      viewModel.openSupportScreen()
    })
    .navigationBarBackButtonHidden(viewModel.isUpdatingCardName)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension EditCardNameView {
  var topView: some View {
    VStack(alignment: .leading, spacing: 24) {
      textFieldHeaderView
      cardNameTextFieldView
    }
  }
  
  var textFieldHeaderView: some View {
    HStack(spacing: 8) {
      Text(L10N.Common.Card.CardName.title.uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      GenImages.CommonImages.info.swiftUIImage
        .resizable()
        .frame(20)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
        .onTapGesture {
          viewModel.onClickedInformationIcon()
        }
    }
  }
  
  @ViewBuilder
  func cardNameDisclosureView(width: CGFloat) -> some View {
    if viewModel.isShowDisclosure {
      HStack {
        Text(L10N.Common.Card.EditCardName.disclosure)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .multilineTextAlignment(.leading)
          .padding(12)
        Spacer()
      }
      .frame(width: width)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(12, corners: [.topRight, .bottomLeft, .bottomRight])
      .offset(x: 16, y: 30)
    }
  }
  
  var cardNameTextFieldView: some View {
    TextFieldWrapper {
      TextField("", text: $viewModel.cardName)
        .focused($isFieldFocused, equals: true)
        .keyboardType(.alphabet)
        .tint(Colors.label.swiftUIColor)
        .restrictInput(value: $viewModel.cardName, restriction: .none)
        .modifier(
          PlaceholderStyle(
            showPlaceHolder: $viewModel.cardName.wrappedValue.isEmpty,
            placeholder: L10N.Common.Card.EditCardName.placeholder
          )
        )
        .primaryFieldStyle()
        .autocapitalization(.none)
        .autocorrectionDisabled()
        .limitInputLength(
          value: $viewModel.cardName,
          length: Constants.MaxCharacterLimit.nameLimit.value
        )
        .disabled(viewModel.isUpdatingCardName)
        .onAppear {
          isFieldFocused = true
        }
    }
  }
  
  @ViewBuilder
  var inlineErrorMessageView: some View {
    if let inlineError = viewModel.inlineErrorMessage {
      Text(inlineError)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.error.swiftUIColor)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
  
  var continueButtonView: some View {
    FullSizeButton(
      title: L10N.Common.Button.Continue.title,
      isDisable: viewModel.isDisableButton,
      isLoading: $viewModel.isUpdatingCardName,
      type: .primary
    ) {
      viewModel.updateCardNameAPI {
        dismiss()
      }
    }
  }
}
