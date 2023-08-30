import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

// MARK: - PassportView
struct EnterPassportView: View {
  
  @StateObject private var viewModel = EnterPassportViewModel()
  @FocusState var keyboardFocus: Bool

  public var body: some View {
    VStack {
      ScrollView {
        VStack(alignment: .leading) {
          
          Text(LFLocalizable.passportHeading)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
            .padding(.vertical, 12)
          
          passportTextfield
          
          bulletList
        }
      }
      .padding(.horizontal, 32)
      
      Spacer()
      
      continueButton
        .padding(.horizontal, 32)
    }
    .frame(max: .infinity)
    .background(Colors.background.swiftUIColor)
    .onTapGesture {
      viewModel.hidePassportTypes()
    }
    .defaultToolBar(icon: .intercom, openIntercom: {
      viewModel.openIntercom()
    })
    .navigationLink(isActive: $viewModel.isNavigationToAddressView) {
      AddressView()
    }
  }
}

// MARK: ViewBuilder
private extension EnterPassportView {

  var bulletList: some View {
    VStack(alignment: .leading) {
      infoBullet(
        image: GenImages.CommonImages.icLock.swiftUIImage,
        description: LFLocalizable.passportEncryptInfo
      )
      infoBullet(
        image: GenImages.CommonImages.icTicketCircle.swiftUIImage,
        description: LFLocalizable.passportNoCreditCheckInfo
      )
    }
    .padding(.top, 20)
  }
  
  @ViewBuilder
  var passportTypes: some View {
    if viewModel.showPassportTypes {
      VStack(alignment: .leading, spacing: 12) {
        passportTypeItem(item: .us)
        passportTypeItem(item: .international)
      }
      .frame(width: 190)
      .padding(12)
      .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(8))
      .offset(y: 22)
    }
  }
  
  @ViewBuilder
  var passportTextfield: some View {
    VStack(alignment: .leading, spacing: 12) {
      TextFieldWrapper {
        TextField("", text: $viewModel.passport)
          .primaryFieldStyle()
          .focused($keyboardFocus)
          .keyboardType(.default)
          .limitInputLength(
            value: $viewModel.passport,
            length: Constants.MaxCharacterLimit.passportLength.value
          )
          .modifier(
            PlaceholderStyle(
              showPlaceHolder: viewModel.passport.isEmpty,
              placeholder: LFLocalizable.passportPlaceholder
            )
          )
          .onAppear {
            Task {// Delay the task by 1 second:
              try await Task.sleep(seconds: 0.25)
              keyboardFocus = true
            }
          }
      }
    }
    .overlay(passportTypes, alignment: .bottomLeading)
  }
  
}

private extension EnterPassportView {
  func infoBullet(image: Image, description: String) -> some View {
    HStack {
      image.foregroundColor(Colors.label.swiftUIColor)
      Text(description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
  }
  
  func passportTypeItem(item: EnterPassportViewModel.PassportType) -> some View {
    Button {
      viewModel.onSelectedPassportType(type: item)
    } label: {
      HStack {
        Text(viewModel.getPassportTypeTitle(type: item))
          .font(Fonts.medium.swiftUIFont(size: 14))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        Image(systemName: "checkmark")
          .font(Fonts.regular.swiftUIFont(size: 16))
          .foregroundColor(viewModel.selectedPassport == item ? Colors.primary.swiftUIColor : .clear)
      }
    }
  }
  
  var passportTypeDropdown: some View {
    Button {
      viewModel.showPassportTypes.toggle()
    } label: {
      HStack {
        Text(viewModel.getPassportTypeTitle(type: viewModel.selectedPassport))
          .font(Fonts.medium.swiftUIFont(size: 14))
        Spacer()
        Image(systemName: viewModel.showPassportTypes ? "chevron.up" : "chevron.down")
          .font(Fonts.regular.swiftUIFont(size: 16))
      }
      .foregroundColor(Colors.label.swiftUIColor)
      .frame(width: 190, height: 40)
    }
    .padding(.horizontal, 12)
    .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(8))
  }
  
  var continueButton: some View {
    VStack {
      FullSizeButton(title: LFLocalizable.Button.Continue.title,
                     isDisable: !viewModel.isActionAllowed) {
        viewModel.isNavigationToAddressView = true
      }
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .padding(.bottom, 16)
  }
}

#if DEBUG
struct EnterPassportView_Previews: PreviewProvider {
  static var previews: some View {
    EnterPassportView()
  }
}
#endif
