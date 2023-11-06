import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

struct EnterPercentageView: View {
  @FocusState private var keyboardFocus: Bool
  @StateObject var viewModel: ManualSetupViewModel
  @State private var isNavigateToAddSignatureView = false
  private let percentagePlaceholder = "0"
  
  var body: some View {
    VStack {
      Spacer()
      HStack(alignment: .center, spacing: 12) {
        Spacer()
        TextField(percentagePlaceholder, text: $viewModel.paycheckPercentage)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: 50))
          .multilineTextAlignment(.trailing)
          .keyboardType(.decimalPad)
          .task {
            keyboardFocus = true
          }
          .focused($keyboardFocus)
          .onChange(of: viewModel.paycheckPercentage, perform: viewModel.onChangedPercentage)
          .fixedSize()
        Text(Constants.Default.percentage.rawValue)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: 50))
        Spacer()
      }
      Spacer()
      FullSizeButton(title: LFLocalizable.Button.Continue.title, isDisable: viewModel.isDisablePercentageContinueButton) {
        isNavigateToAddSignatureView = true
      }
      .padding(.bottom, 16)
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .navigationLink(isActive: $isNavigateToAddSignatureView) {
      AddSignatureView(viewModel: viewModel)
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(LFLocalizable.DirectDeposit.Toolbal.title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .track(name: String(describing: type(of: self)))
  }
}
