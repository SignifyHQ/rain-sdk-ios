//
//  ChangePasswordView.swift
//  
//
//  Created by Volodymyr Davydenko on 12.12.2023.
//

import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct ChangePasswordView: View {
  @Environment(\.dismiss) var dismiss
  
  @StateObject private var viewModel = ChangePasswordViewModel()
  @FocusState var keyboardFocus: Focus?
  
  public init() {}
  
  public var body: some View {
    VStack {
      ScrollView {
        ZStack {
          VStack(alignment: .leading) {
            titleView
            enterPassword
            reenterPassword
            
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
    .defaultToolBar(icon: .support, openSupportScreen: {
      viewModel.openSupportScreen()
    })
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onChange(of: viewModel.shouldDismiss, perform: { _ in
      dismiss()
    })
    .navigationBarBackButtonHidden(viewModel.isLoading)
    .track(name: String(describing: type(of: self)))
  }
}

extension ChangePasswordView {
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
    Text(LFLocalizable.Authentication.ChangePassword.title)
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
        viewModel.didTapContinueButton()
        keyboardFocus = nil
      }
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
  }
  
  var enterPassword: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.Authentication.ChangePassword.Current.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.Authentication.ChangePassword.Current.placeholder,
        value: $viewModel.oldPasswordString,
        focus: .oldPassword,
        nextFocus: .newPassword
      )
      .tint(Colors.label.swiftUIColor)
      .disabled(viewModel.isLoading)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          keyboardFocus = .oldPassword
        }
      }
    }
  }
  
  var reenterPassword: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.Authentication.ChangePassword.New.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 16)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.Authentication.ChangePassword.New.placeholder,
        value: $viewModel.newPasswordString,
        focus: .newPassword
      )
      .tint(Colors.label.swiftUIColor)
      .disabled(viewModel.isLoading)
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
  
  enum Focus: Int, Hashable {
    case oldPassword
    case newPassword
  }
}
