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
  
  @StateObject private var viewModel = ResetPasswordViewModel()
  
  public init() {}
  
  public var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .defaultToolBar(icon: .support) {
        viewModel.openSupportScreen()
      }
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
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
      
      HStack {
        GenImages.CommonImages.dash.swiftUIImage
          .resizable()
          .frame(height: 1)
          .foregroundColor(Colors.label.swiftUIColor)
        
        Spacer()
        
        Text(LFLocalizable.Authentication.ResetPassword.or)
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        
        Spacer()
        
        GenImages.CommonImages.dash.swiftUIImage
          .resizable()
          .frame(height: 1)
          .foregroundColor(Colors.label.swiftUIColor)
      }
      .padding(.vertical)
      
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
  }
  
  var resendCodeButton: some View {
    Button {
      viewModel.didTapResetCodeButton()
    } label: {
      Text(LFLocalizable.Authentication.ResetPassword.ResendCodeButton.title)
        .foregroundColor(Colors.primary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    }
  }
}

