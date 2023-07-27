import SwiftUI
import LFUtilities
import LFLocalizable

public struct SearchBar: View {
  @Binding var searchText: String
  
  public init(searchText: Binding<String>) {
    _searchText = searchText
  }

  public var body: some View {
    VStack(spacing: 15) {
      HStack(spacing: 12) {
        TextField("", text: $searchText)
          .modifier(PlaceholderStyle(showPlaceHolder: searchText.isEmpty, placeholder: LFLocalizable.Textfield.Search.placeholder))
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .autocapitalization(.none)
          .keyboardType(.alphabet)
          .disableAutocorrection(true)

        Spacer()

        if searchText.isEmpty {
          Image(systemName: "magnifyingglass")
            .foregroundColor(Colors.label.swiftUIColor)
        } else {
          Button {
            searchText = ""
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(Colors.label.swiftUIColor)
          }
        }
      }
      .padding(.horizontal, 5)

      Divider()
        .frame(height: 1)
        .background(Colors.label.swiftUIColor.opacity(0.25))
    }
  }
}
