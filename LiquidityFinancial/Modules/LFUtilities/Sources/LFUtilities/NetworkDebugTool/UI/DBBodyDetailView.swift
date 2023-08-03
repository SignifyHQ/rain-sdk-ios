import SwiftUI

struct DBBodyDetailView: View {
  var data: Data?

  @State var searchText: String = ""
  @State var response: String = ""
  @State var isLoading: Bool = false

  var body: some View {
    NavigationView {
      Group {
        if isLoading {
          ProgressView()
        } else {
          VStack {
            DBSearchBar(text: $searchText)
              .padding(.top, 16)

            DBHighlightEditorView(text: $response, highlightText: searchText)
              .textSelection(.enabled)
          }
        }
      }
    }
    .onAppear {
      isLoading = true
      DBRequestModelBeautifier.body(data) { stringData in
        DispatchQueue.main.sync {
          response = stringData
          isLoading = false
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("Request Body Details")
          .font(Font.system(size: 18))
          .foregroundColor(Color.white)
      }
    }
  }
}

struct BodyDetailView_Previews: PreviewProvider {
  static var previews: some View {
    DBBodyDetailView(data: nil)
  }
}
