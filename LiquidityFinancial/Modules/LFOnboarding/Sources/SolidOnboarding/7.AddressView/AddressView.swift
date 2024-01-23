import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services
import Factory

struct AddressView: View {
  @Injected(\.analyticsService)
  var analyticsService
  
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
            .padding(.horizontal, 30)

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
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      },
      edgeInsets: EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
    )
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onAppear(perform: {
      analyticsService.track(event: AnalyticsEvent(name: .viewedAddress))
    })
    .navigationBarBackButtonHidden(viewModel.isLoading)
    .track(name: String(describing: type(of: self)))
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
            Fonts.regular.swiftUIFont(
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
      L10N.Common.addressTitle
    )
    .foregroundColor(Colors.label.swiftUIColor)
    .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
    .padding(.vertical, 16)
  }
  
  var addressLine1: some View {
    VStack(alignment: .leading) {
      Text(L10N.Common.addressLine1Title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.leading, 4)
      
      textField(
        placeholder: L10N.Common.enterAddress,
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
      Text(L10N.Common.addressLine2Title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 16)
        .padding(.leading, 4)
      
      textField(
        placeholder: L10N.Common.enterAddress,
        value: $viewModel.addressLine2,
        focus: .address2,
        nextFocus: .city
      )
    }
  }
  
  var city: some View {
    VStack(alignment: .leading) {
      Text(L10N.Common.city)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 16)
        .padding(.leading, 4)
      
      textField(
        placeholder: L10N.Common.enterCity,
        value: $viewModel.city,
        focus: .city,
        nextFocus: .state
      )
    }
  }
  
  var state: some View {
    VStack(alignment: .leading) {
      Text(L10N.Common.state)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .multilineTextAlignment(.leading)
        .padding(.leading, 4)
      
      textField(
        placeholder: L10N.Common.enterState,
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
      Text(L10N.Common.zipcode)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .multilineTextAlignment(.leading)
        .padding(.leading, 4)
      
      textField(
        placeholder: L10N.Common.enterZipcode,
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
        title: L10N.Common.Button.Continue.title,
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

#if DEBUG
struct AddressView_Previews: PreviewProvider {
  static var previews: some View {
    AddressView()
      .previewLayout(PreviewLayout.sizeThatFits)
      .previewDisplayName("Default preview")
  }
}
#endif
