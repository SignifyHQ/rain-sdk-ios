import SwiftUI

struct DebugAnalyticsView: View {
  @State var searchText: String = ""
  @State var itemSelected: DBAnalyticModel?

  var body: some View {
    VStack {
      DBSearchBar(text: $searchText)
        .padding(.top, 16)

      List {
        ForEach(filterAnalytic(text: searchText)) { analytic in
          ZStack(alignment: .leading) {
            Rectangle()
              .fill(Color.black)
              .frame(width: 5)
              .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))

            VStack(alignment: .leading, spacing: 6) {
              HStack(alignment: .center) {
                let event = "\(analytic.name)"
                Text("event: ")
                  .font(Font.system(size: 16, design: .monospaced))
                  .foregroundColor(.green)
                  + Text(event)
                  .font(Font.system(size: 14, design: .monospaced))
              }

              HStack(alignment: .center) {
                let params = "params: \(analytic.value)"
                Text("params: ")
                  .font(Font.system(size: 16, design: .monospaced))
                  .foregroundColor(.orange)
                  + Text(params)
                  .font(Font.system(size: 14, design: .monospaced))
              }
            }
            .padding(.leading, 12)
            .fixedSize(horizontal: false, vertical: true)
          }
        }
        .listRowSeparator(.automatic, edges: .bottom)
      }
      .listStyle(.plain)
      .padding(0)
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("Analytics")
          .font(Font.system(size: 18))
          .foregroundColor(Color.white)
      }
    }
  }

  func filterAnalytic(text: String?) -> [DBAnalyticModel] {
    guard text != nil, text != "" else {
      return DBStorage.shared.getAnalytics()
    }

    return DBStorage.shared.getAnalytics().filter { request -> Bool in
      request.name.range(of: text!, options: .caseInsensitive) != nil ? true : false
    }
  }
}

struct DebugAnylyticsView_Previews: PreviewProvider {
  static var previews: some View {
    DebugAnalyticsView()
  }
}
