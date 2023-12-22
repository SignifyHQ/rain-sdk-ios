//
//  ResetPasswordView.swift
//  
//
//  Created by Volodymyr Davydenko on 06.12.2023.
//

import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct ResetPasswordView: View {
  @StateObject
  private var viewModel = ResetPasswordViewModel()
  
  @State
  private var viewDidLoad: Bool = false
  
  @Binding
  var isFlowPresented: Bool
  
  public var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .navigationBarBackButtonHidden(viewModel.isLoading)
      .defaultToolBar(
        icon: .support,
        openSupportScreen: {
          viewModel.openSupportScreen()
        }
      )
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .navigationLink(item: $viewModel.navigaion) { navigation in
        switch navigation {
        case .resetPassword(let token):
          CreatePasswordView(purpose: .resetPassword(token: token)) {
            isFlowPresented = false
          }
        }
      }
      .onAppear(
        perform: {
          if !viewDidLoad {
            viewDidLoad = true
            viewModel.requestOTP()
          }
        }
      )
      .adaptToKeyboard()
      .ignoresSafeArea(edges: .bottom)
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension ResetPasswordView {
  var content: some View {
    VStack(alignment: .center, spacing: 50) {
      topView
      middleView
      
      Spacer()
      
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: !viewModel.isOTPCodeEntered,
        isLoading: $viewModel.isLoading
      ) {
        hideKeyboard()
        viewModel.didTapContinueButton()
      }
    }
    .padding([.horizontal, .bottom], 30)
  }
  
  var topView: some View {
    VStack(spacing: 12) {
      Text(LFLocalizable.Authentication.ResetPassword.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      Text(LFLocalizable.Authentication.ResetPassword.subtitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      Text(LFLocalizable.Authentication.ResetPassword.enterCode)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
    }
    .padding(.top, 16)
  }
  
  var middleView: some View {
    VStack {
      otpCodeView
      resendCodeButton
        .padding(.top)
    }
  }
  
  var otpCodeView: some View {
    HStack(spacing: 10) {
      ForEach(viewModel.otpViewItems) { item in
        PinTextField(
          viewItem: item,
          isShown: true,
          onTextChange: { value in
            viewModel.textFieldTextChange(replacementText: value, viewItem: item)
          },
          onBackPressed: { item in
            viewModel.onTextFieldBackPressed(viewItem: item)
          }
        )
        .background(item.text.isEmpty ? Colors.buttons.swiftUIColor : Colors.secondaryBackground.swiftUIColor)
        .cornerRadius(10)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 70)
      }
    }
    .disabled(viewModel.isLoading)
  }
  
  var resendCodeButton: some View {
    Button {
      viewModel.didTapResendCodeButton()
    } label: {
      Text(LFLocalizable.Authentication.ResetPassword.ResendCodeButton.title)
        .foregroundColor(Colors.primary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    }
    .disabled(viewModel.isLoading)
  }
}

