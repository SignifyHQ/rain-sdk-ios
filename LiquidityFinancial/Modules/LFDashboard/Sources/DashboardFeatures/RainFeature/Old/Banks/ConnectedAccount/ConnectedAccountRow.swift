import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import NetSpendData

struct ConnectedAccountRow: View {
  @StateObject private var viewModel: ConnectedAccountRowViewModel
  
  let verifyAction: (() -> Void)?
  let deleteAction: (() -> Void)?
  
  init(sourceData: APILinkedSourceData, verifyAction: (() -> Void)? = nil, deleteAction: (() -> Void)? = nil) {
    _viewModel = .init(
      wrappedValue: ConnectedAccountRowViewModel(sourceData: sourceData)
    )
    self.verifyAction = verifyAction
    self.deleteAction = deleteAction
  }

  public var body: some View {
    HStack(spacing: 8) {
      GenImages.CommonImages.connectedAccounts.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      HStack(spacing: 8) {
        Text(viewModel.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
        if viewModel.showVerified {
          GenImages.Images.icVerified.swiftUIImage
        }
      }
      Spacer()
      HStack(spacing: 8) {
        if !viewModel.showVerified {
          Button {
            verifyAction?()
          } label: {
            Text(L10N.Common.Button.Verify.title)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
              .foregroundColor(Colors.primary.swiftUIColor)
          }
          .frame(width: 64, height: 32)
          .background(Colors.buttons.swiftUIColor)
          .cornerRadius(8)
        }
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
