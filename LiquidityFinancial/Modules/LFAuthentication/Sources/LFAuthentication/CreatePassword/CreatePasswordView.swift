import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct CreatePasswordView: View {
  @Environment(\.dismiss) var dismiss
  
  enum Focus: Int, Hashable {
    case enterPass
    case reEnterPass
  }
  
  @StateObject
  private var viewModel: CreatePasswordViewModel
  
  @FocusState
  var keyboardFocus: Focus?
  
  public init(
    purpose: CreatePasswordPurpose,
    onActionContinue: @escaping () -> Void
  ) {
    _viewModel = .init(wrappedValue: CreatePasswordViewModel(purpose: purpose, onActionContinue: onActionContinue))
    UITableView.appearance().backgroundColor = UIColor(Colors.background.swiftUIColor)
    UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
  }
  
  public var body: some View {
    VStack {
      ScrollView {
        ZStack {
          VStack(alignment: .leading) {
            titleView
            enterPassword
            
            if viewModel.isDontMatchErrorShown {
              passwordMatchError
            }
            
            bottomView
            Spacer()
          }
          .padding(.horizontal, 32)
        }
      }
      continueButtonView
    }
    .navigationTitle("")
    .background(Colors.background.swiftUIColor)
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      }
    )
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .popup(
      isPresented: $viewModel.shouldShowConfirmationPopup,
      dismissMethods: []
    ) {
      successConfirmationPopup
    }
    .navigationBarBackButtonHidden(viewModel.isLoading)
    .track(name: String(describing: type(of: self)))
  }
}

extension CreatePasswordView {
  var passwordMatchError: some View {
    Text(LFLocalizable.Authentication.CreatePassword.warning)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(Colors.error.swiftUIColor)
  }
  
  var bottomView: some View {
    VStack(spacing: 8) {
      HStack {
        if viewModel.isLengthCorrect {
          GenImages.CommonImages.icPasswordCheck.swiftUIImage
        } else {
          circleView
        }
        
        Text(LFLocalizable.Authentication.CreatePassword.desc1)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(viewModel.isLengthCorrect ? 1 : 0.75)
        
        Spacer()
      }
      
      HStack(spacing: 8) {
        if viewModel.containsSpecialCharacters {
          GenImages.CommonImages.icPasswordCheck.swiftUIImage
        } else {
          circleView
        }
        
        Text(LFLocalizable.Authentication.CreatePassword.desc2)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(viewModel.containsSpecialCharacters ? 1 : 0.75)
        
        Spacer()
      }
      
      HStack(spacing: 8) {
        if viewModel.containsLowerAndUpperCase {
          GenImages.CommonImages.icPasswordCheck.swiftUIImage
        } else {
          circleView
        }
        
        Text(LFLocalizable.Authentication.CreatePassword.desc3)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(viewModel.containsLowerAndUpperCase ? 1 : 0.75)
        
        Spacer()
      }
    }
    .padding(.vertical, 18)
  }
  
  var titleView: some View {
    Text(LFLocalizable.Authentication.CreatePassword.title.uppercased())
      .frame(maxWidth: .infinity)
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .padding(.top, 0)
      .padding(.bottom, 32)
  }
  
  var continueButtonView: some View {
    VStack(spacing: 0) {
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: !viewModel.isContinueEnabled,
        isLoading: $viewModel.isLoading,
        type: .primary
      ) {
        viewModel.actionContinue()
        keyboardFocus = nil
      }
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
  }
  
  var enterPassword: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.Authentication.CreatePassword.subTitle1)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.Authentication.CreatePassword.subTitle2,
        value: $viewModel.passwordString,
        focus: .enterPass,
        nextFocus: .reEnterPass
      )
      .tint(Colors.label.swiftUIColor)
      .disabled(viewModel.isLoading)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          keyboardFocus = .enterPass
        }
      }
    }
  }
  
  var circleView: some View {
    Circle()
      .fill(Color(red: 0.94, green: 0.76, blue: 0.23))
      .foregroundColor(.clear)
      .frame(width: 6, height: 6)
  }
  
  @ViewBuilder
  func textField(
    placeholder: String,
    value: Binding<String>,
    limit: Int = 100,
    restriction: TextRestriction = .password,
    keyboardType: UIKeyboardType = .alphabet,
    focus: Focus,
    nextFocus: Focus? = nil
  ) -> some View {
    TextFieldWrapper {
      SecureField("", text: value)
        .keyboardType(keyboardType)
        .restrictInput(value: value, restriction: restriction)
        .modifier(PlaceholderStyle(showPlaceHolder: value.wrappedValue.isEmpty, placeholder: placeholder))
        .primaryFieldStyle()
        .autocapitalization(.none)
        .autocorrectionDisabled()
        .limitInputLength(value: value, length: limit)
        .submitLabel(nextFocus == nil ? .done : .next)
        .focused($keyboardFocus, equals: focus)
        .onSubmit {
          keyboardFocus = nextFocus
        }
    }
  }
}

extension CreatePasswordView {
  private var successConfirmationPopup: some View {
    LiquidityAlert(
      title: viewModel.successMessage(),
      primary: .init(
        text: LFLocalizable.Button.Continue.title,
        action: {
          switch viewModel.purpose {
          case .changePassword:
            dismiss()
            viewModel.onActionContinue()
          case .createExistingUser:
            dismiss()
          case .createNewUser, .resetPassword:
            viewModel.onActionContinue()
          }
        }
      )
    )
  }
}
