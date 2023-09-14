import Foundation
import SwiftUI

public struct DebugNotificationView : View {
  
  public var body: some View {
    VStack {
      List {
        ForEach(parseNotificationModel()) { model in
          ZStack(alignment: .leading) {
            Rectangle()
              .fill(Color.black)
              .frame(width: 5)
              .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            
            VStack(alignment: .leading, spacing: 6) {
              HStack(alignment: .center) {
                Text("event date: ")
                  .font(Font.system(size: 16, design: .monospaced))
                  .foregroundColor(.green)
                + Text(model.date.description)
                  .font(Font.system(size: 14, design: .monospaced))
              }
              
              HStack(alignment: .center) {
                Text("body: ")
                  .font(Font.system(size: 16, design: .monospaced))
                  .foregroundColor(.orange)
                + Text(model.desc)
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
  
  func parseNotificationModel() -> [NotificationModel] {
    let models = NotificationsReceived.shared.notifications.compactMap({ NotificationModel(date: $0.date, desc: $0.dict.description) })
    return models
  }
  
  struct NotificationModel: Identifiable {
    var id: String = UUID().uuidString
    var date: Date
    var desc: String
  }
}

struct DebugNotificationView_Previews: PreviewProvider {
  static var previews: some View {
    DebugNotificationView()
  }
}
