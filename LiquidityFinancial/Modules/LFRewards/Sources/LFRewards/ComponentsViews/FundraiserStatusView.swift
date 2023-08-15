import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct FundraiserStatusView: View {
  let fundraiser: FundraiserDetailModel
  
  var body: some View {
    Group {
      if shouldShow {
        HStack {
          raised
            .frame(maxWidth: .infinity)
          divider
          donations
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .background(ModuleColors.buttons.swiftUIColor)
        .cornerRadius(8)
      }
    }
  }
  
  private var shouldShow: Bool {
    fundraiser.currentAmount >= 5
  }
  
  private var raised: some View {
    HStack(alignment: .lastTextBaseline, spacing: 4) {
      Text(fundraiser.currentAmount.formattedAmount(prefix: "$", maxFractionDigits: 0))
        .font(Fonts.medium.swiftUIFont(size: 12))
        .foregroundColor(ModuleColors.label.swiftUIColor)
      
      Text(LFLocalizable.FundraiserStatus.raised)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(ModuleColors.label.swiftUIColor)
    }
  }
  
  private var divider: some View {
    Rectangle()
      .fill(ModuleColors.separator.swiftUIColor.opacity(0.1))
      .frame(width: 1, height: 16)
  }
  
  private var donations: some View {
    Text(LFLocalizable.FundraiserStatus.donations(fundraiser.currentDonations.roundedWithAbbreviations))
      .font(Fonts.regular.swiftUIFont(size: 12))
      .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
  }
}
