import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

// MARK: - PassportView

struct EnterPassportView: View {
  @StateObject private var viewModel = EnterPassportViewModel()

  @Environment(\.presentationMode) var presentation
  
  func callUpdateUserAPI() {
    viewModel.showIndicator = true
  }

  var body: some View {
    VStack {
      // TODO: Will add AddressView later
      // NavigationLink(destination: AddressView(), tag: 1, selection: $selection) {}
      
      ScrollView {
        VStack(alignment: .leading) {
          Text(LFLocalizable.passportHeading)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
            .padding(.vertical, 12)

          passportTextfield

          bulletList
        }.padding(.horizontal, 32)
      }

      VStack {
        FullSizeButton(
          title: LFLocalizable.Button.Continue.title,
          isDisable: !viewModel.isActionAllowed,
          isLoading: $viewModel.showIndicator
        ) {
          callUpdateUserAPI()
        }
      }
      .ignoresSafeArea(.keyboard, edges: .bottom)
      .padding(.bottom, 24)
      .padding(.horizontal, 32)
    }
    .background(
      Colors.background.swiftUIColor
        .onTapGesture {
          viewModel.hidePassportTypes()
        }
    )
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          //intercomService.openIntercom()
        } label: {
          GenImages.CommonImages.icChat.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
    }
    .onAppear {
      viewModel.updateUserDetails()
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
  }
}

private extension EnterPassportView {
  func infoBullet(image: Image, description: String) -> some View {
    HStack {
      image.foregroundColor(Colors.label.swiftUIColor)
      Text(description)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
  }
  
  @ViewBuilder var passportTextfield: some View {
    VStack(alignment: .leading, spacing: 12) {
      TextFieldWrapper(errorValue: $viewModel.errorMessage) {
        TextField("", text: $viewModel.passport)
          .primaryFieldStyle()
          .focused(viewModel.$keyboardFocus)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
              viewModel.keyboardFocus = true
            }
          }
      }
    }
    .overlay(passportTypes, alignment: .bottomLeading)
  }
  
  @ViewBuilder var bulletList: some View {
    VStack(alignment: .leading) {
      infoBullet(
        image: GenImages.CommonImages.icLock.swiftUIImage,
        description: LFLocalizable.passportEncryptInfo
      )
      infoBullet(
        image: GenImages.CommonImages.icTicketCircle.swiftUIImage,
        description: LFLocalizable.passportNoCreditCheckInfo
      )
      infoBullet(
        image: GenImages.CommonImages.icHome.swiftUIImage,
        description: String(format: LFLocalizable.passportRequiredToCreateInfo(LFUtility.appName))
      )
    }
    .padding(.top, 20)
  }

  @ViewBuilder var passportTypes: some View {
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

  func passportTypeItem(item: EnterPassportViewModel.PassportType) -> some View {
    Button {
      viewModel.onSelectedPassportType(type: item)
    } label: {
      HStack {
        Text(viewModel.getPassportTypeTitle(type: item))
          .font(Fonts.Inter.medium.swiftUIFont(size: 14))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        Image(systemName: "checkmark")
          .font(Fonts.Inter.regular.swiftUIFont(size: 16))
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
          .font(Fonts.Inter.medium.swiftUIFont(size: 14))
        Spacer()
        Image(systemName: viewModel.showPassportTypes ? "chevron.up" : "chevron.down")
          .font(Fonts.Inter.regular.swiftUIFont(size: 16))
      }
      .foregroundColor(Colors.label.swiftUIColor)
      .frame(width: 190, height: 40)
    }
    .padding(.horizontal, 12)
    .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(8))
  }
}
