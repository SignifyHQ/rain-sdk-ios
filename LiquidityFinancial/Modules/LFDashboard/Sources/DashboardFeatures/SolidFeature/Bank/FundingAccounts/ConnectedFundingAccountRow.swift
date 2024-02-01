import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import ExternalFundingData

struct ConnectedFundingAccountRow: View {
  @StateObject private var viewModel: ConnectedFundingAccountRowViewModel
  
  let deleteAction: (() -> Void)?
  
  init(sourceData: LinkedSourceContact, deleteAction: (() -> Void)? = nil) {
    _viewModel = .init(
      wrappedValue: ConnectedFundingAccountRowViewModel(sourceData: sourceData)
    )
    self.deleteAction = deleteAction
  }

  var body: some View {
    HStack(spacing: 10) {
      contact
      deleteButton
    }
    .frame(maxWidth: .infinity)
    .frame(height: 56)
  }
  
  var contact: some View {
    HStack(spacing: 8) {
      GenImages.CommonImages.Accounts.connectedAccounts.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      HStack(spacing: 8) {
        Text(viewModel.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .frame(height: 56)
    .padding(.horizontal, 20)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(9)
  }
  
  var deleteButton: some View {
    HStack(spacing: 8) {
      GenImages.CommonImages.icTrash2.swiftUIImage
    }
    .frame(width: 56, height: 56)
    .onTapGesture {
      deleteAction?()
    }
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(9)
  }
}

struct ConnectedFundingAccountRow_Previews: PreviewProvider {
  static var previews: some View {
    ConnectedFundingAccountRow(sourceData: LinkedSourceContact(last4: "4556", sourceType: .bank, sourceId: "acdacdc")) {
      
    }
  }
}
