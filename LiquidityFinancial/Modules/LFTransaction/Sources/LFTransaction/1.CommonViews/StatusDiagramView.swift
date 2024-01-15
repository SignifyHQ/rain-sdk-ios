import SwiftUI
import LFStyleGuide
import LFUtilities

struct StatusDiagramView: View {
  let transaction: TransactionModel
  let startTitle: String
  let completedTitle: String
  
  var body: some View {
    VStack(spacing: 12) {
      HStack(spacing: 4) {
        circleCheckmark(isEnable: true)
        Rectangle()
          .fill(Colors.label.swiftUIColor.opacity(0.25))
          .frame(width: 156, height: 2)
        circleCheckmark(isEnable: isCompleted)
      }
      HStack {
        statusText(title: startTitle, description: startDate, isEnable: true)
        Spacer()
        statusText(title: completedTitle, description: endDate, isEnable: isCompleted)
      }
    }
    .padding(.horizontal, 12)
  }
}

// MARK: - View Components
private extension StatusDiagramView {
  func circleCheckmark(isEnable: Bool) -> some View {
    Circle()
      .stroke(
        isEnable ? Colors.circleOutline.swiftUIColor : Colors.label.swiftUIColor.opacity(0.25),
        lineWidth: 1)
      .frame(20)
      .overlay {
        GenImages.CommonImages.icCheckmark.swiftUIImage
          .foregroundColor(Colors.checkmark.swiftUIColor)
          .opacity(isEnable ? 1 : 0)
      }
  }
  
  func statusText(title: String, description: String, isEnable: Bool) -> some View {
    VStack(spacing: 2) {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(isEnable ? 1 : 0.5))
      Text(description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(isEnable ? 0.75 : 0.5))
    }
  }
}

// MARK: View Helpers
private extension StatusDiagramView {
  var isCompleted: Bool {
    transaction.status == .completed
  }
  
  var startDate: String {
    transaction.createdAt.parsingDateStringToNewFormat(toDateFormat: .monthDayAbbrev) ?? "-"
  }
  
  var endDate: String {
    guard let completedDate = transaction.completedAt?.parsingDateStringToNewFormat(toDateFormat: .monthDayAbbrev) else {
      return transaction.estimateCompletedDate ?? "-"
    }
    return completedDate
  }
}
