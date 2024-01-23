import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import NetSpendData

struct DocumentTypeView: View {
  @Binding var selectedType: NetSpendDocumentType
  let documentTypes: [NetSpendDocumentType]
  let action: () -> Void
  
  var body: some View {
    ZStack {
      Colors.secondaryBackground.swiftUIColor
        .ignoresSafeArea(edges: .bottom)
      VStack(spacing: 24) {
        RoundedRectangle(cornerRadius: 4)
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.25))
          .frame(width: 32, height: 4)
          .padding(.top, 6)
        Text(L10N.Common.DocumentType.BottomSheet.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
        documentTypeList
        FullSizeButton(title: L10N.Common.DocumentType.Button.title, isDisable: false) {
          action()
        }
        .padding(.bottom, 16)
      }
      .padding(.horizontal, 30)
    }
  }
}

// MARK: - DocumentTypeView BottomSheet
private extension DocumentTypeView {
  var documentTypeList: some View {
    VStack(spacing: 10) {
      ForEach(documentTypes, id: \.self) { type in
        Button {
          selectedType = type
        } label: {
          HStack {
            Text(type.title)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundColor(Colors.label.swiftUIColor)
            Spacer()
            CircleSelected(isSelected: selectedType == type)
          }
          .padding(16)
          .frame(height: 48)
          .background(Colors.background.swiftUIColor.cornerRadius(9))
        }
      }
    }
  }
}
