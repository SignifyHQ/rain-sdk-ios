import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct CreatePasswordView: View {
  @Environment(\.dismiss) var dismiss
  
  @StateObject
  private var viewModel: CreatePasswordViewModel
  
  @FocusState
  private var isSecureFieldFocused: Bool?
  @State
  private var isInputSecured: Bool = true
  
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
            topView
            
            if viewModel.isDontMatchErrorShown {
              passwordMatchError
            }
            
            bottomView
            Spacer()
          }
          .padding(.horizontal, 30)
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
  
  private func toggleSecuredInput() {
    isInputSecured.toggle()
    isSecureFieldFocused = isInputSecured
  }
}

extension CreatePasswordView {
  var topView: some View {
    VStack(spacing: 24) {
      Text(viewModel.purpose.screenTitle)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      
      enterPassword
    }
  }
  
  var enterPassword: some View {
    VStack(alignment: .leading) {
      Text(L10N.Common.Authentication.CreatePassword.subTitle1)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
      
      TextFieldWrapper {
        HStack {
          Group {
            SecureField("", text: $viewModel.passwordString)
              .focused($isSecureFieldFocused, equals: true)
              .isHidden(hidden: !isInputSecured)
            
            TextField("", text: $viewModel.passwordString)
              .focused($isSecureFieldFocused, equals: false)
              .isHidden(hidden: isInputSecured)
          }
          .keyboardType(.alphabet)
          .tint(Colors.label.swiftUIColor)
          .restrictInput(value: $viewModel.passwordString, restriction: .none)
          .modifier(
            PlaceholderStyle(
              showPlaceHolder: $viewModel.passwordString.wrappedValue.isEmpty,
              placeholder: L10N.Common.Authentication.CreatePassword.subTitle2
            )
          )
          .primaryFieldStyle()
          .autocapitalization(.none)
          .autocorrectionDisabled()
          .limitInputLength(
            value: $viewModel.passwordString,
            length: Constants.MaxCharacterLimit.password.value
          )
          
          Spacer()
          
          Button {
            toggleSecuredInput()
          } label: {
            showHideImage
              .swiftUIImage
              .foregroundColor(Colors.label.swiftUIColor)
          }
        }
      }
      .disabled(viewModel.isLoading)
      .onAppear {
        isSecureFieldFocused = isInputSecured
      }
    }
  }
  
  private var showHideImage: ImageAsset {
    isInputSecured ? GenImages.CommonImages.icPasswordShow : GenImages.CommonImages.icPasswordHide
  }
  
  var passwordMatchError: some View {
    Text(L10N.Common.Authentication.CreatePassword.warning)
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
        
        Text(L10N.Common.Authentication.CreatePassword.desc1)
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
        
        Text(L10N.Common.Authentication.CreatePassword.desc2)
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
        
        Text(L10N.Common.Authentication.CreatePassword.desc3)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(viewModel.containsLowerAndUpperCase ? 1 : 0.75)
        
        Spacer()
      }
    }
    .padding(.vertical, 18)
  }
  
  var continueButtonView: some View {
    VStack(spacing: 0) {
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: !viewModel.isContinueEnabled,
        isLoading: $viewModel.isLoading,
        type: .primary
      ) {
        viewModel.actionContinue()
        //keyboardFocus = nil
      }
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
  }
  
  var circleView: some View {
    Circle()
      .fill(Color(red: 0.94, green: 0.76, blue: 0.23))
      .foregroundColor(.clear)
      .frame(width: 6, height: 6)
  }
}

extension CreatePasswordView {
  private var successConfirmationPopup: some View {
    LiquidityAlert(
      title: viewModel.successMessage(),
      primary: .init(
        text: L10N.Common.Button.Ok.title,
        action: {
          viewModel.dismissPopup()
          
          switch viewModel.purpose {
          case .createExistingUser:
            dismiss()
          case .createNewUser, .resetPassword, .changePassword:
            viewModel.onActionContinue()
          }
        }
      )
    )
  }
}
