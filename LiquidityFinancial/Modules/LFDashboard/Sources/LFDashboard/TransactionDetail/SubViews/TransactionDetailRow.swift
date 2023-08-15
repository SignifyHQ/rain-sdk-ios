import SwiftUI
import LFStyleGuide

struct TransactionDetailRow: View {
  let type: Kind
  let data: TransactionRowData
  
  init(type: Kind = .detail, data: TransactionRowData) {
    self.type = type
    self.data = data
  }
  
  var body: some View {
    VStack(spacing: type.verticalSpacing) {
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      HStack(spacing: 20) {
        Text(data.title)
          .font(Fonts.regular.swiftUIFont(size: type.fontSize))
          .foregroundColor(Colors.label.swiftUIColor.opacity(type.titleOpacity))
        Spacer()
        
        HStack(spacing: 4) {
          if let markValue = data.markValue {
            Text(markValue.uppercased())
              .minimumScaleFactor(0.8)
              .foregroundColor(Colors.primary.swiftUIColor)
              .allowsTightening(true)
          }
          if let value = data.value {
            Text(data.shouldUppercase ? value.uppercased() : value)
              .foregroundColor(Colors.label.swiftUIColor)
              .minimumScaleFactor(0.8)
          }
        }
        .font(Fonts.bold.swiftUIFont(size: type.fontSize))
      }
    }
    .padding(.bottom, type.verticalSpacing)
  }
}

// MARK: - Kind
extension TransactionDetailRow {
  enum Kind {
    case detail
    case receipt
    
    var verticalSpacing: CGFloat {
      switch self {
      case .detail: return 20
      case .receipt: return 16
      }
    }
    
    var fontSize: CGFloat {
      switch self {
      case .detail: return 16
      case .receipt: return 12
      }
    }
    
    var titleOpacity: CGFloat {
      switch self {
      case .detail: return 1.0
      case .receipt: return 0.75
      }
    }
  }
}
