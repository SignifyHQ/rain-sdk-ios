import SwiftUI
import LFStyleGuide
import LFUtilities

struct StatusView: View {
  let transactionStatus: TransactionStatus?
  let donationStatus: DonationStatus?
  
  init(transactionStatus: TransactionStatus? = nil, donationStatus: DonationStatus? = nil) {
    self.transactionStatus = transactionStatus
    self.donationStatus = donationStatus
  }
  
  var body: some View {
    HStack(spacing: 8) {
      if let transactionStatus = transactionStatus, let image = transactionStatusImage {
        image
        Text(transactionStatus.localizedDescription())
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
      } else if let donationStatus = donationStatus, let image = donationStatusImage {
        image
        Text(donationStatus.localizedDescription())
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
      }
    }
    .foregroundColor(Colors.label.swiftUIColor)
  }
}

// MARK: - View Helpers
private extension StatusView {
  var transactionStatusImage: Image? {
    switch transactionStatus {
    case .pending:
      return GenImages.Images.statusPending.swiftUIImage
    case .completed:
      return GenImages.Images.statusCompleted.swiftUIImage
    default:
      return nil
    }
  }
  
  var donationStatusImage: Image? {
    switch donationStatus {
    case .pending:
      return GenImages.Images.statusPending.swiftUIImage
    case .completed:
      return GenImages.Images.statusCompleted.swiftUIImage
    default:
      return nil
    }
  }
}
