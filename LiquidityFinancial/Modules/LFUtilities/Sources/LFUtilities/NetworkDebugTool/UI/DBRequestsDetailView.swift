import SwiftUI

struct DBRequestsDetailView: View {
  enum Action {
    case requestBody, responseBody
  }
  
  let request: DBRequestModel

  @State var action: Action?

  var body: some View {
    NavigationView {
      List {
        Section("Overview") {
          Text(attString: DBRequestModelBeautifier.overview(request: request))
            .textSelection(.enabled)
        }

        Section("Request Header") {
          Text(attString: DBRequestModelBeautifier.header(request.headers))
            .textSelection(.enabled)
        }

        Section("Request Body") {
          Text("View body")
            .foregroundColor(.green)
            .onTapGesture {
              action = .requestBody
            }
        }

        Section("Response Header") {
          Text(attString: DBRequestModelBeautifier.header(request.responseHeaders))
            .textSelection(.enabled)
        }

        Section("Response Body") {
          Text("View body")
            .foregroundColor(.green)
            .onTapGesture {
              action = .responseBody
            }
        }
      }
    }
    .navigationDestination(binding: $action, destination: { action in
      switch action {
      case .requestBody: DBBodyDetailView(data: request.httpBody)
      case .responseBody: DBBodyDetailView(data: request.dataResponse)
      }
    })
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("Request Details")
          .font(Font.system(size: 18))
          .foregroundColor(Color.white)
      }
    }
  }
}

struct RequestsDetailView_Previews: PreviewProvider {
  static var previews: some View {
    DBRequestsDetailView(request: DBRequestModel(request: NSURLRequest(url: URL(string: "https://test-api.liquidityapps.com/v1/account/")!), session: nil))
  }
}
