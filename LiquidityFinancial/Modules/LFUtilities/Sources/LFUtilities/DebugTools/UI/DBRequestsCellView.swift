import SwiftUI

struct DBRequestsCellView: View {
  let request: DBRequestModel

  private var method: String {
    request.method.uppercased()
  }

  private var code: String {
    "\(request.code)"
  }

  private var codeColor: Color {
    var color: UIColor = DBColors.HTTPCode.Generic
    switch request.code {
    case 200 ..< 300:
      color = DBColors.HTTPCode.Success
    case 300 ..< 400:
      color = DBColors.HTTPCode.Redirect
    case 400 ..< 500:
      color = DBColors.HTTPCode.ClientError
    case 500 ..< 600:
      color = DBColors.HTTPCode.ServerError
    default:
      color = DBColors.HTTPCode.Generic
    }
    return Color(uiColor: color)
  }

  private var url: String {
    request.url
  }

  private var duration: String {
    request.duration?.formattedMilliseconds() ?? ""
  }

  var body: some View {
    ZStack(alignment: .leading) {
      Rectangle()
        .fill(codeColor)
        .frame(width: 5)
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))

      HStack(alignment: .center, spacing: 10) {
        VStack(alignment: .leading, spacing: 5) {
          Text(method)
            .font(Font.system(size: 20, design: .monospaced))

          Text(code)
            .font(Font.system(size: 21, design: .monospaced))
            .frame(width: 50)
            .foregroundColor(codeColor)
            .overlay(
              RoundedRectangle(cornerRadius: 6)
                .stroke(codeColor, lineWidth: 1)
            )
            .hidden(request.code == 0)

          Text(duration)
            .font(Font.system(size: 18, design: .monospaced))
        }
        .frame(width: 60)

        Text(url)
          .font(Font.system(size: 15, design: .monospaced))
        Spacer()
      }
      .padding(6)
    }
    .fixedSize(horizontal: false, vertical: true)
  }
}

struct RequestsCellView_Previews: PreviewProvider {
  static var previews: some View {
    DBRequestsCellView(request: DBRequestModel(request: NSURLRequest(url: URL(string: "https://test-api.liquidityapps.com/v1/account/")!), session: nil))
  }
}
