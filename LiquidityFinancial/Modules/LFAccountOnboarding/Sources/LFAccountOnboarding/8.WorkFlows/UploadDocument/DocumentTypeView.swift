import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct DocumentTypeView: View {
  @Binding var selectedType: DocumentType
  let documentTypes: [DocumentType]
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
        Text(LFLocalizable.DocumentType.BottomSheet.title)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
        documentTypeList
        FullSizeButton(title: LFLocalizable.DocumentType.Button.title, isDisable: false) {
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
              .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundColor(Colors.label.swiftUIColor)
            Spacer()
            Circle()
              .stroke(Colors.label.swiftUIColor.opacity(0.25), lineWidth: 1)
              .background(
                ZStack {
                  if selectedType == type {
                    Circle()
                      .fill(Colors.primary.swiftUIColor)
                      .overlay {
                        GenImages.CommonImages.checkmark.swiftUIImage
                          .foregroundColor(Colors.label.swiftUIColor)
                      }
                  }
                }
              )
              .frame(20)
          }
          .padding(16)
          .frame(height: 48)
          .background(Colors.background.swiftUIColor.cornerRadius(9))
        }
      }
    }
  }
}
