import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct TransferStatusView: View {
  let data: Data

  var body: some View {
    VStack(spacing: 12) {
      drawing

      HStack {
        VStack(spacing: 2) {
          Text(startedText)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor)
          Text(data.startedDate ?? "-")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
        }
        .frame(maxWidth: .infinity)

        VStack(spacing: 2) {
          Text(completedText)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(data.isPending ? 0.25 : 1.0))
          Text(data.completedDate ?? "-")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(data.isPending ? 0.25 : 0.6))
        }
        .frame(maxWidth: .infinity)
      }
    }
  }

  private var drawing: some View {
    func circle(color: Color) -> some View {
      ZStack {
        Circle()
          .stroke(color, lineWidth: 2)
          .frame(width: 20, height: 20)
        Image(systemName: "checkmark")
          .resizable()
          .frame(width: 7, height: 8)
          .foregroundColor(color)
      }
    }
    let color = data.isPending ? Colors.label.swiftUIColor.opacity(0.1) : Colors.primary.swiftUIColor
    return HStack(spacing: 4) {
      circle(color: Colors.primary.swiftUIColor)
      Rectangle()
        .frame(width: 160, height: 2)
        .foregroundColor(color)
      circle(color: color)
    }
  }

  private var startedText: String {
    switch data.type {
    case .deposit:
      return LFLocalizable.TransferView.Status.Deposit.started
    case .withdraw:
      return LFLocalizable.TransferView.Status.Withdraw.started
    case .reward:
      return LFLocalizable.TransferView.Status.Reward.started
    }
  }

  private var completedText: String {
    switch data.type {
    case .deposit:
      return LFLocalizable.TransferView.Status.Deposit.completed
    case .withdraw:
      return LFLocalizable.TransferView.Status.Withdraw.completed
    case .reward:
      return LFLocalizable.TransferView.Status.Reward.completed
    }
  }

  struct Data {
    let isPending: Bool
    let type: Kind
    let startedDate: String?
    let completedDate: String?

    enum Kind {
      case deposit
      case withdraw
      case reward
    }

    static func build(from transfer: Transfer) -> Self {
      let isPending = transfer.status?.isPending ?? true
      return .init(
        isPending: isPending,
        type: transfer.txnType == .credit ? .deposit : .withdraw,
        startedDate: transfer.createdAt?.displayDate,
        completedDate: isPending ? transfer.estimatedTxnDate?.displayDate : transfer.transferredAt?.displayDate
      )
    }

    static func build(from transaction: TransactionModel) -> Self? {
      switch transaction.txnType {
      case .cashback:
        guard let rewards = transaction.rewards else { return nil }
        return .init(
          isPending: rewards.status == .pending,
          type: .reward,
          startedDate: rewards.earnedAt?.displayDate,
          completedDate: rewards.completedAt?.displayDate
        )
      default:
        let isPending = transaction.status?.isPending ?? true
        return .init(
          isPending: isPending,
          type: transaction.txnType == .credit ? .deposit : .withdraw,
          startedDate: transaction.createdAt?.displayDate,
          completedDate: isPending ? transaction.estimatedTxnDate?.displayDate : transaction.txnDate?.displayDate
        )
      }
    }
  }
}
