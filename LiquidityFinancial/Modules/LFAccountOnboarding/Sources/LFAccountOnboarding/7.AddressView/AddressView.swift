import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct AddressView: View {
  @StateObject private var viewModel = AddressViewModel()

  init() {
    UITableView.appearance().backgroundColor = UIColor(Colors.background.swiftUIColor)
    UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
  }

  enum Focus: Int, Hashable {
    case address1
    case address2
    case city
    case state
    case zip
  }

  @Environment(\.dismiss) var dismiss
  @Environment(\.openURL) var openURL
  @FocusState var keyboardFocus: Focus?

  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView {
          ZStack {
            VStack(alignment: .leading) {
              title
              addressLine1
              addressLine2
              city

              HStack {
                state
                Spacer(minLength: 25)
                zipCode
              }
              .padding(.top, 16)
            }
            .onChange(of: keyboardFocus) {
              proxy.scrollTo($0)
            }
            .padding(.horizontal, 32)

            if viewModel.displaySuggestions {
              if #available(iOS 16.0, *) {
                listView().scrollContentBackground(.hidden)
              } else {
                listView()
              }
            }
          }
        }
      }
      bottom
    }
    .navigationTitle("")
    .background(Colors.background.swiftUIColor)
    .onTapGesture {
      viewModel.stopSuggestions()
    }
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
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onAppear {
      //analyticsService.track(event: Event(name: .viewedAddress))
    }
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .question(let questionsEntity):
        QuestionsView(viewModel: QuestionsViewModel(questionList: questionsEntity))
      case .document:
        UploadDocumentView()
      case .pendingIDV:
        KYCStatusView(viewModel: KYCStatusViewModel(state: .pendingIDV))
      case .declined:
        KYCStatusView(viewModel: KYCStatusViewModel(state: .declined))
      case .inReview:
        KYCStatusView(viewModel: KYCStatusViewModel(state: .inReview(viewModel.userNameDisplay)))
      case .home:
        EmptyView()
      }
    }
    .navigationBarBackButtonHidden(viewModel.isLoading)
  }
}

private extension AddressView {
  func listView() -> some View {
    List(viewModel.addressList, id: \.id) { item in
      HStack(alignment: .top) {
        GenImages.CommonImages.map.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        Text("\(item.addressline1) \(item.state) \(item.city) \(item.zipcode)")
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.75)
          .font(
            Fonts.Inter.regular.swiftUIFont(
              size: Constants.FontSize.small.value
            )
          )
          .padding([.top], -2)
          .padding([.leading], 5)
      }
      .padding([.leading], 2)
      .padding([.top, .bottom, .trailing], 10)
      .onTapGesture {
        viewModel.select(suggestion: item)
      }
      .listRowBackground(Colors.secondaryBackground.swiftUIColor)
      .listRowSeparatorTint(Colors.label.swiftUIColor.opacity(0.16))
      .listRowInsets(.none)
    }
    .cornerRadius(8, style: .continuous)
    .listStyle(.plain)
    .frame(maxHeight: 240, alignment: .top)
    .padding([.leading, .trailing], 20)
    .padding(.top, 95)
    .onAppear {
      UITableView.appearance().contentInset.top = -35
      UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
    }
    .floatingShadow()
  }
  
  var title: some View {
    Text(
      LFLocalizable.addressTitle(LFUtility.appName.uppercased())
    )
    .foregroundColor(Colors.label.swiftUIColor)
    .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
    .padding(.vertical, 16)
  }
  
  var addressLine1: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.addressLine1Title)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.enterAddress,
        value: $viewModel.addressLine1,
        focus: .address1,
        nextFocus: .address2
      )
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          keyboardFocus = .address1
        }
      }
    }
  }
  
  var addressLine2: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.addressLine2Title)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 16)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.enterAddress,
        value: $viewModel.addressLine2,
        focus: .address2,
        nextFocus: .city
      )
    }
  }
  
  var city: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.city)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 16)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.enterCity,
        value: $viewModel.city,
        focus: .city,
        nextFocus: .state
      )
    }
  }
  
  var state: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.state)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .multilineTextAlignment(.leading)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.enterState,
        value: $viewModel.state,
        limit: 2,
        restriction: .alphabets,
        focus: .state,
        nextFocus: .zip
      )
    }
  }
  
  var zipCode: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.zipcode)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .multilineTextAlignment(.leading)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.enterZipcode,
        value: $viewModel.zipCode,
        limit: 11,
        keyboardType: .numberPad,
        focus: .zip
      )
    }
  }
  
  var bottom: some View {
    VStack(spacing: 0) {
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: !viewModel.isActionAllowed,
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
  
  @ViewBuilder
  func textField(
    placeholder: String,
    value: Binding<String>,
    limit: Int = 200,
    restriction: TextRestriction = .none,
    keyboardType: UIKeyboardType = .alphabet,
    focus: Focus,
    nextFocus: Focus? = nil
  ) -> some View {
    TextFieldWrapper {
      TextField("", text: value)
        .keyboardType(keyboardType)
        .restrictInput(value: value, restriction: restriction)
        .modifier(PlaceholderStyle(showPlaceHolder: value.wrappedValue.isEmpty, placeholder: placeholder))
        .primaryFieldStyle()
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
