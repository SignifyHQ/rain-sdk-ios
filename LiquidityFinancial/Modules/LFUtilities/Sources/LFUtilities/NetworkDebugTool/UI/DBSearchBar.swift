import SwiftUI

struct DBSearchBar: View {
  @Binding var text: String

  @State private var isEditing = false

  var body: some View {
    HStack {
      TextField("Search ...", text: $text)
        .padding(7)
        .padding(.horizontal, 25)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .overlay(
          HStack {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.gray)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 8)

            if isEditing {
              Button(action: {
                text = ""

              }) {
                Image(systemName: "multiply.circle.fill")
                  .foregroundColor(.gray)
                  .padding(.trailing, 8)
              }
            }
          }
        )
        .padding(.horizontal, 10)
        .onTapGesture {
          isEditing = true
        }

      if isEditing {
        Button(action: {
          isEditing = false
          text = ""

          // Dismiss the keyboard
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }) {
          Text("Cancel")
        }
        .padding(.trailing, 10)
        .transition(.move(edge: .trailing))
        .animation(.default, value: 0.35)
      }
    }
  }
}

struct DBSearchBar_Previews: PreviewProvider {
  static var previews: some View {
    DBSearchBar(text: .constant(""))
  }
}
