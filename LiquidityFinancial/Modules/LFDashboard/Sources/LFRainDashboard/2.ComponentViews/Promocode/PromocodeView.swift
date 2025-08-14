import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

struct PromocodeView: View {
  @ObservedObject var viewModel: PromocodeViewModel
  @Environment(\.dismiss) var dismiss
  
  @Binding var isSheetPresented: Bool
  @FocusState var isKeyboardFocuses: Bool
  
  var body: some View {
    VStack {
      header
        .padding(.bottom, 25)
      
      content
      
      Spacer()
      
      buttons
    }
    .toolbar(.hidden)
    .padding(.top, 25)
    .padding(.horizontal, 25)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Colors.bottomSheetBackground.swiftUIColor)
  }
  
  private var header: some View {
    ZStack {
      HStack {
        Spacer()
        
        Text(viewModel.isSuccessState ? "Welcome to Wyoming!" : "Enter your promo code")
          .font(Fonts.regular.swiftUIFont(size: 18))
          .foregroundColor(Colors.label.swiftUIColor)
          .frame(maxWidth: .infinity, alignment: .center)
        
        Spacer()
      }
      
      HStack {
        Button(
          action: {
            dismiss()
          }
        ) {
          Image(systemName: "arrow.left")
            .font(.title2)
            .foregroundColor(.primary)
        }
        
        Spacer()
      }
    }
  }
  
  private var content: some View {
    ZStack {
      if viewModel.isSuccessState {
        VStack {
          GenImages.CommonImages.icFrntBig.swiftUIImage
            .resizable()
            .frame(width: 75, height: 75)
            .padding(.bottom, 20)
          
          Text("You’ve just received\n10 Frontier Stable Tokens (FRNT) as part of\nthe Wyoming event experience.")
            .font(Fonts.regular.swiftUIFont(size: 16))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: true, vertical: true)
            .foregroundColor(Colors.label.swiftUIColor)
            .opacity(0.75)
        }
        .transition(.opacity)
        .id("successState")
      } else {
        promocodeView
          .transition(.opacity)
          .id("promoState")
      }
    }
    .animation(.easeInOut(duration: 0.3), value: viewModel.isSuccessState)
  }
  
  var promocodeView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Promo Code")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
      
      promocodeTextField
    }
  }
  
  private var promocodeTextField: some View {
    TextFieldWrapper {
      TextField(
        "Enter your promo code",
        text: $viewModel.promocode
      )
      .primaryFieldStyle()
      .disableAutocorrection(true)
      .keyboardType(.alphabet)
      .focused($isKeyboardFocuses)
    }
  }
  
  private var buttons: some View {
    ZStack {
      VStack(
      ) {
        FullSizeButton(
          title: viewModel.isSuccessState ? "Go to My Account" : "Continue",
          isDisable: !viewModel.isContinueButtonEnabled,
          isLoading: $viewModel.isLoading,
          type: .primary
        ) {
          if viewModel.isSuccessState {
            print("Go to account")
            
            return
          }
          
          isKeyboardFocuses = false
          viewModel.applyPromocode()
        }
        .transition(.opacity)
        .id("topButton")
        
        if viewModel.isSuccessState {
          FullSizeButton(
            title: "Got it",
            isDisable: false,
            type: .alternative
          ) {
            isSheetPresented = false
          }
          .transition(.opacity)
          .id("bottomButtom")
        }
      }
      .padding(.bottom, 12)
    }
    .animation(.easeInOut(duration: 0.3), value: viewModel.isSuccessState)
  }
}
