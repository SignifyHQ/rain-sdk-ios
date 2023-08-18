import SwiftUI
import LFStyleGuide
import LFUtilities

struct StatusView: View {
  let status: TransactionStatus
  
  var body: some View {
    HStack(spacing: 8) {
      if let image = statusImage {
        image.swiftUIImage
      }
      Text(status.localizedDescription())
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
    }
    .foregroundColor(Colors.label.swiftUIColor)
  }
}

// MARK: - View Helpers
private extension StatusView {
  var statusImage: ImageAsset? {
    switch status {
    case .pending:
      return GenImages.Images.statusPending
    case .completed:
      return GenImages.Images.statusCompleted
    default:
      return nil
    }
  }
}
