import Foundation
import SwiftUI

struct DBRequestsView: View {
  @State var searchText: String = ""
  @State var itemSelected: DBRequestModel?

  var body: some View {
    VStack {
      DBSearchBar(text: $searchText)
        .padding(.top, 16)

      List {
        ForEach(filterRequests(text: searchText)) { request in
          DBRequestsCellView(request: request)
            .listRowInsets(EdgeInsets())
            .onTapGesture {
              itemSelected = request
            }
        }
        .listRowSeparator(.automatic, edges: .bottom)
      }
      .listStyle(.plain)
    }
    .navigationDestination(binding: $itemSelected, destination: { itemSelected in
      DBRequestsDetailView(request: itemSelected)
    })
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("Requests")
          .font(Font.system(size: 18))
          .foregroundColor(Color.white)
      }
    }
  }

  func filterRequests(text: String?) -> [DBRequestModel] {
    guard text != nil, text != "" else {
      return DBStorage.shared.getRequests()
    }

    return DBStorage.shared.getRequests().filter { request -> Bool in
      request.url.range(of: text!, options: .caseInsensitive) != nil ? true : false
    }
  }
}

struct RequestsView_Previews: PreviewProvider {
  static var previews: some View {
    DBRequestsView()
  }
}
