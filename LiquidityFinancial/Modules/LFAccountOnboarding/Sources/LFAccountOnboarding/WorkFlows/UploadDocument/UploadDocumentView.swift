import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

struct UploadDocumentView: View {
  @StateObject private var viewModel = UploadDocumentViewModel()
  
  var body: some View {
    VStack {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 24) {
          headerTitle
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          uploadDocumentView
          importFilesList
        }
      }
      Spacer()
      uploadButton
    }
    .fileImporter(
      isPresented: $viewModel.isOpenFileImporter,
      allowedContentTypes: [.content, .pdf, .gif, .jpeg, .png, .bmp]
    ) { result in
      viewModel.handleImportedFile(result: result)
    }
    .padding(.top, 30)
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
  }
}

// MARK: - View Components
private extension UploadDocumentView {
  var headerTitle: some View {
    VStack(spacing: 16) {
      Text(LFLocalizable.UploadDocument.Screen.title)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(LFLocalizable.UploadDocument.Screen.description(LFUtility.appName))
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.center)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }
  
  var uploadDocumentView: some View {
    VStack(spacing: 32) {
      VStack(alignment: .leading, spacing: 12) {
        Text(LFLocalizable.UploadDocument.Upload.title)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Text(LFLocalizable.UploadDocument.Upload.description)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      uploadDocumentArea
    }
  }
  
  var uploadDocumentArea: some View {
    HStack {
      Spacer()
      VStack(spacing: 4) {
        GenImages.CommonImages.icDocument.swiftUIImage
          .foregroundColor(Colors.primary.swiftUIColor)
          .padding(.bottom, 6)
        Text(LFLocalizable.UploadDocument.Upload.actionTitle)
          .font(Fonts.Inter.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Text(LFLocalizable.UploadDocument.MaxSize.description(Constants.Default.capacity.rawValue))
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      Spacer()
    }
    .frame(height: 128)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(
          Colors.label.swiftUIColor.opacity(0.75),
          style: StrokeStyle(lineWidth: 0.75, dash: [4])
        )
    )
    .contentShape(Rectangle())
    .onTapGesture {
      viewModel.openFileImporter()
    }
  }
  
  var uploadButton: some View {
    FullSizeButton(
      title: LFLocalizable.UploadDocument.Button.title,
      isDisable: viewModel.documents.isEmpty
    ) {
    }
    .padding(.bottom, 16)
  }
  
  var importFilesList: some View {
    VStack(spacing: 10) {
      ForEach(Array(viewModel.documents.enumerated()), id: \.offset) { index, document in
        documentCell(document: document, index: index)
      }
    }
  }
  
  func documentCell(document: Document, index: Int) -> some View {
    HStack(spacing: 8) {
      GenImages.CommonImages.icDocument.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      VStack(alignment: .leading) {
        Text(document.fileName)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Text(document.formartFizeSize)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      Spacer()
      Button {
        viewModel.removeFile(index: index)
      } label: {
        CircleButton(style: .delete)
      }
    }
    .padding(.horizontal, 16)
    .frame(height: 56)
    .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
  }
}
