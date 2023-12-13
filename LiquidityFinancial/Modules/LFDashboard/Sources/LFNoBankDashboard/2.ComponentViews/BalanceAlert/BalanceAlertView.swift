import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct BalanceAlertView: View {
  let type: Kind
  let cashBalance: Double?
  let cryptoBalance: Double?
  let hasContacts: Bool
  let action: () -> Void
  
  init(
    type: Kind,
    hasContacts: Bool,
    cashBalance: Double? = nil,
    cryptoBalance: Double? = nil,
    action: @escaping () -> Void
  ) {
    self.type = type
    self.cashBalance = cashBalance
    self.cryptoBalance = cryptoBalance
    self.hasContacts = hasContacts
    self.action = action
  }
  
  var status: Status {
    switch type {
    case .cash:
      guard let balance = cashBalance else {
        return .hidden
      }
      if balance < 0 {
        return .negative
      }
      return hasContacts && balance < Constants.lowBalanceThreshold ? .low : .hidden
    case .crypto:
      guard let balance = cryptoBalance, balance < 0 else {
        return .hidden
      }
      return .negative
    }
  }
  
  var body: some View {
    Group {
      switch status {
      case .hidden:
        EmptyView()
      case .low:
        low
      case .negative:
        negative
      }
    }
  }
}

// MARK: - View Components
private extension BalanceAlertView {
  var low: some View {
    Button {
      action()
    } label: {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(LFLocalizable.BalanceAlert.Low.title)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
          
          Text(
            LFLocalizable.BalanceAlert.Low.message(
              Constants.lowBalanceThreshold.formattedUSDAmount()
            )
          )
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        }
        .foregroundColor(textColor)
        
        Spacer()
        
        Text(LFLocalizable.BalanceAlert.cta)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.contrast.swiftUIColor)
          .padding(.horizontal, 22)
          .padding(.vertical, 13)
          .background(depositButtonBackgroundColor)
          .cornerRadius(8)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Colors.contrast.swiftUIColor, lineWidth: 1)
          )
      }
      .padding(8)
      .padding(.leading, 8)
      .background(
        LinearGradient(
          gradient: Gradient(colors: gradientColor),
          startPoint: .bottomLeading,
          endPoint: .topTrailing
        )
      )
      .cornerRadius(9)
      .overlay(
        RoundedRectangle(cornerRadius: 9)
          .stroke(Colors.tertiary.swiftUIColor, lineWidth: 1)
          .opacity(LFStyleGuide.target == .CauseCard ? 0 : 1)
      )
    }
  }
  
  var negative: some View {
    Button {
      action()
    } label: {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(LFLocalizable.BalanceAlert.Negative.title)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
          if type == .cash {
            Text(LFLocalizable.BalanceAlert.Negative.Message.cash)
              .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          } else {
            Text(LFLocalizable.BalanceAlert.Negative.Message.crypto)
              .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          }
        }
        .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        Text(LFLocalizable.BalanceAlert.cta)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.background.swiftUIColor)
          .padding(.horizontal, 22)
          .padding(.vertical, 13)
          .background(Colors.primary.swiftUIColor)
          .cornerRadius(8)
      }
      .padding(8)
      .padding(.leading, 8)
      .background(Colors.secondaryBackground.swiftUIColor)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Colors.error.swiftUIColor, lineWidth: 1)
      )
    }
  }
}

// MARK: - View Helpers
private extension BalanceAlertView {
  var gradientColor: [Color] {
    switch LFStyleGuide.target {
    case .CauseCard:
      return [
        Colors.Gradients.Button.gradientButton0.swiftUIColor,
        Colors.Gradients.Button.gradientButton1.swiftUIColor
      ]
    default:
      return [Colors.secondaryBackground.swiftUIColor]
    }
  }
  
  var depositButtonBackgroundColor: Color {
    switch LFStyleGuide.target {
    case .CauseCard:
      return Color.clear
    default:
      return Colors.primary.swiftUIColor
    }
  }
  
  var textColor: Color {
    switch LFStyleGuide.target {
    case .CauseCard:
      return Colors.contrast.swiftUIColor
    default:
      return Colors.label.swiftUIColor
    }
  }
}

// MARK: - Types
extension BalanceAlertView {
  enum Kind: String {
    case cash
    case crypto
  }
  
  enum Status {
    case low
    case negative
    case hidden
  }
}
