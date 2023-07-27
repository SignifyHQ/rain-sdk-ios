import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct TransactionRowView: View {
  let item: TransactionModel
  let type: Kind
  var minimumScaleFactor = 0.7
  let action: () -> Void

  var body: some View {
    Button {
      action()
    } label: {
      HStack(spacing: 10) {
        leading
        center
        Spacer()
        trailing
      }
      .padding(.leading, 16)
      .padding(.trailing, 20)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(12)
    }
    .disabled(type == .fundraiserDonation)
  }
}

// MARK: Elements
private extension TransactionRowView {
  var leading: some View {
    Group {
      switch leftImageSource {
      case let .local(assetName):
        Image(assetName, bundle: .main)
      case let .remote(url, placeholder):
        CachedAsyncImage(url: url) { image in
          image
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
        } placeholder: {
          Image(placeholder, bundle: .main)
        }
      }
    }
    .frame(width: 46, height: 46)
    .padding(.vertical, 16)
  }

  var center: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title ?? "")
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(minimumScaleFactor)
        .allowsTightening(true)
        .lineLimit(2)

      Text(subtitle)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
        .lineLimit(1)
    }
  }

  var trailing: some View {
    VStack(alignment: .trailing, spacing: 4) {
      Text(item.formattedAmmount ?? "")
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(amountColor)
        .minimumScaleFactor(minimumScaleFactor)
        .allowsTightening(true)
        .lineLimit(1)

      Text(trailingSubtitle ?? "")
        .font(Fonts.Inter.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
    }
  }

  var trailingSubtitle: String? {
    switch type {
    case .cash:
      return item.formattedBalance
    case .userDonation:
      return item.donationsBalance?.formattedAmount(
        prefix: Constants.CurrencyUnit.usd.symbol,
        minFractionDigits: Constants.CurrencyUnit.usd.maxFractionDigits
      )
    case .crypto, .fundraiserDonation, .cashback:
      return nil
    }
  }
}

// MARK: - Data
extension TransactionRowView {
  private var leftImageSource: ImageSource {
    switch type {
    case .cash, .crypto, .cashback:
      return .local(item.platformTxnType.assetName)
    case .userDonation:
      return .remote(url: item.donationCharityFundraiser?.sticker.url, placeholder: GenImages.Images.Transactions.txDonation.name)
    case .fundraiserDonation:
      return .remote(url: .init(string: item.profileImageUrl ?? ""), placeholder: GenImages.Images.Transactions.txDonation.name)
    }
  }

  private var title: String? {
    switch type {
    case .cash, .crypto, .userDonation, .cashback:
      return item.title
    case .fundraiserDonation:
      if let name = item.personName {
        return LFLocalizable.TransactionRow.FundraiserDonation.user(name)
      } else {
        return LFLocalizable.TransactionRow.FundraiserDonation.generic
      }
    }
  }

  private var subtitle: String {
    item.status == .pending ? LFLocalizable.TransactionRow.pending : item.transactionDateInLocalZone()
  }

  private var amountColor: Color {
    if item.txnType == .cashback {
      return cashbackColor
    } else {
      switch type {
      case .cash, .crypto:
        return colorForType
      case .cashback:
        return cashbackColor
      case .fundraiserDonation, .userDonation:
        // TODO: Will return donationRewardColor after can get reserveDonation
        return Colors.label.swiftUIColor
      }
    }
  }

  private var isFromCrypto: Bool {
    switch type {
    case .cash, .fundraiserDonation, .userDonation, .cashback:
      return false
    case .crypto:
      return true
    }
  }

  private var cashbackColor: Color {
    if item.rewards?.status == .pending {
      return Colors.pending.swiftUIColor
    } else {
      return item.isPositiveAmount ? Colors.green.swiftUIColor : Colors.error.swiftUIColor
    }
  }

  private var donationRewardColor: Color {
    if item.rewards?.status == .pending {
      return Colors.pending.swiftUIColor
    } else if item.donationType == .oneTime {
      return Colors.green.swiftUIColor
    } else {
      return item.isPositiveAmount ? Colors.green.swiftUIColor : Colors.error.swiftUIColor
    }
  }

  private var colorForType: Color {
    guard let txnType = item.txnType else {
      return Colors.primary.swiftUIColor
    }
    if item.status == .pending {
      return Colors.pending.swiftUIColor
    }
    switch txnType {
    case .credit, .reward, .cashback:
      return Colors.green.swiftUIColor
    case .debit, .unknown:
      return Colors.error.swiftUIColor
    case .donation:
      return item.isPositiveAmount ? Colors.green.swiftUIColor : Colors.error.swiftUIColor
    }
  }
}

extension TransactionRowView {
  enum Kind {
    case cash
    case crypto
    case cashback
    case userDonation
    case fundraiserDonation
  }

  enum ImageSource {
    case local(String)
    case remote(url: URL?, placeholder: String)
  }
}
