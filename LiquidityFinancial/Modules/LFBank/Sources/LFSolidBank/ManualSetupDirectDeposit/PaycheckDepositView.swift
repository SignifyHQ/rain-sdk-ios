import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

struct PaycheckDepositView: View {
  @StateObject var viewModel: ManualSetupViewModel
  @State private var navigation: Navigation?
  
  var body: some View {
    VStack {
      Text(LFLocalizable.DirectDeposit.Paycheck.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.top, 16)
      Spacer()
      VStack(spacing: 12) {
        FullSizeButton(title: LFLocalizable.DirectDeposit.Paycheck.full, isDisable: false) {
          viewModel.selectedPaychekOption = .optionFullPayCheck
          navigation = .signature
        }
        
        FullSizeButton(title: LFLocalizable.DirectDeposit.Paycheck.enterPercentage, isDisable: false, type: .secondary) {
          viewModel.selectedPaychekOption = .optionPercentage
          navigation = .percentage
        }
        
        FullSizeButton(title: LFLocalizable.DirectDeposit.Paycheck.enterAmount, isDisable: false, type: .secondary) {
          viewModel.selectedPaychekOption = .optionAmount
          navigation = .amount
        }
      }
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .navigationLink(item: $navigation) { navigation in
      switch navigation {
      case .signature:
        AddSignatureView(viewModel: viewModel)
      case .percentage:
        EnterPercentageView(viewModel: viewModel)
      case .amount:
        EnterAmountView(viewModel: viewModel)
      }
    }
    .track(name: String(describing: type(of: self)))
  }
}

private extension PaycheckDepositView {
  enum Navigation {
    case signature
    case percentage
    case amount
  }
}
