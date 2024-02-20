import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct CreateCardView: View {
  @Environment(\.dismiss)
  private var dismiss
  @StateObject
  private var viewModel: CreateCardViewModel
  @FocusState
  private var isFieldFocused: Bool?
  
  init(viewModel: CreateCardViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    GeometryReader { proxy in
      VStack(alignment: .leading, spacing: 24) {
        headerTitle
        cardNameTextField
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
    .navigationBarBackButtonHidden(viewModel.isCreatingCard)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension CreateCardView {
  var headerTitle: some View {
    Text(L10N.Common.Card.CreateCard.title.uppercased())
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .padding(.top, 16)
  }
  
  var cardNameTextField: some View {
    VStack(alignment: .leading, spacing: 12) {
      textFieldHeaderView
      cardNameTextFieldView
      inlineErrorMessageView
    }
  }
  
  var textFieldHeaderView: some View {
    HStack(spacing: 8) {
      Text(L10N.Common.Card.CreateCard.cardNameTitle)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
      GenImages.CommonImages.info.swiftUIImage
        .resizable()
        .frame(16)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
        .onTapGesture {
          viewModel.onClickedCardNameInformationIcon()
        }
    }
  }
  
  @ViewBuilder
  func cardNameDisclosureView(width: CGFloat) -> some View {
    if viewModel.isShowCardNameDisclosure {
      HStack {
        Text(L10N.Common.Card.CreateCard.cardNameDisclosure)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .multilineTextAlignment(.leading)
          .padding(12)
        Spacer()
      }
      .frame(width: width)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(12, corners: [.topRight, .bottomLeft, .bottomRight])
      .offset(x: 16, y: 86)
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
            placeholder: L10N.Common.Card.CreateCard.cardNamePlaceholder
          )
        )
        .primaryFieldStyle()
        .autocapitalization(.none)
        .autocorrectionDisabled()
        .limitInputLength(
          value: $viewModel.cardName,
          length: Constants.MaxCharacterLimit.nameLimit.value
        )
        .disabled(viewModel.isCreatingCard)
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
      isLoading: $viewModel.isCreatingCard,
      type: .primary
    ) {
      viewModel.createCardAPI()
    }
  }
}
