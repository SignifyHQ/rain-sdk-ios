import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import ExternalFundingData

struct ConnectedAccountRow: View {
  @StateObject private var viewModel: ConnectedAccountRowViewModel
  
  let deleteAction: (() -> Void)?
  
  init(sourceData: LinkedSourceContact, deleteAction: (() -> Void)? = nil) {
    _viewModel = .init(
      wrappedValue: ConnectedAccountRowViewModel(sourceData: sourceData)
    )
    self.deleteAction = deleteAction
  }

  public var body: some View {
    HStack(spacing: 8) {
      GenImages.CommonImages.Accounts.connectedAccounts.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      HStack(spacing: 8) {
        Text(viewModel.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
      Spacer()
      HStack(spacing: 8) {
        CircleButton(style: .delete)
          .onTapGesture {
            deleteAction?()
          }
      }
    }
    .padding(.horizontal, 12)
    .frame(height: 56)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(9)
  }
}
