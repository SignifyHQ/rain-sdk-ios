import SwiftUI
import LFUtilities
import LFLocalizable

public struct DefaultSearchBar: View {
  @Binding var searchText: String
  
  public init(searchText: Binding<String>) {
    _searchText = searchText
  }

  public var body: some View {
    VStack(spacing: 8) {
      HStack(spacing: 12) {
        DefaultTextField(
          placeholder: L10N.Common.Common.Search.placeholder,
          isDividerShown: false,
          value: $searchText,
          tint: Colors.textPrimary.swiftUIColor,
          textColor: Colors.textPrimary.swiftUIColor,
          placeholderColor: Colors.textSecondary.swiftUIColor.opacity(0.5)
        )

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

      Divider()
        .frame(height: 1)
        .background(Colors.linesDividers.swiftUIColor)
    }
  }
}
