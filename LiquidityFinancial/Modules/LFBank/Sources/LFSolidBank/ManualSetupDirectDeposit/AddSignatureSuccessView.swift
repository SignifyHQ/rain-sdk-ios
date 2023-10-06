import LFUtilities
import LFLocalizable
import LFStyleGuide
import SwiftUI
import MessageUI
import LFServices

struct AddSignatureSuccessView: View {
  @StateObject var viewModel: ManualSetupViewModel
  @State private var result: Result<MFMailComposeResult, Error>?
  @State private var isNavigationViewForm = false
  @State private var isShowingMailView = false
  @State private var toastMessage: String?
  
  var body: some View {
    VStack {
      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .frame(104)
        .padding(.top, 10)
      Text(LFLocalizable.DirectDeposit.ManualSetup.successTitle)
        .padding()
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .multilineTextAlignment(.center)
      Text(LFLocalizable.DirectDeposit.ManualSetup.description)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.center)
      Spacer()
      VStack {
        emailFormButton
        FullSizeButton(title: LFLocalizable.DirectDeposit.ViewForm.buttonTitle, isDisable: false, type: .secondary) {
          isNavigationViewForm = true
        }
      }
      .padding(.bottom, 16)
      .popup(item: $toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
    }
    .padding(.horizontal, 30)
    .navigationBarBackButtonHidden(true)
    .background(Colors.background.swiftUIColor)
    .defaultToolBar(icon: .xMark, onDismiss: {
      LFUtilities.popToRootView()
    })
    .onAppear {
      DirectDepositPDFView(viewModel: viewModel).exportToPDF()
    }
    .navigationLink(isActive: $isNavigationViewForm) {
      PDFWebView(documentName: Constants.Default.documentName.rawValue)
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension AddSignatureSuccessView {
  var emailFormButton: some View {
    FullSizeButton(title: LFLocalizable.DirectDeposit.EmailForm.buttonTitle, isDisable: false) {
      if MFMailComposeViewController.canSendMail() {
        isShowingMailView.toggle()
      } else {
        toastMessage = LFLocalizable.DirectDeposit.Mail.toastMessage
      }
    }
    .padding(.bottom, 5)
    .sheet(isPresented: $isShowingMailView) {
      MailView(result: $result) { composer in
        composer.setSubject(LFLocalizable.DirectDeposit.Toolbal.title)
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let outputFileURL = documentDirectory.appendingPathComponent(Constants.Default.documentName.rawValue).path
        if let fileData = NSData(contentsOfFile: outputFileURL) {
          composer.addAttachmentData(fileData as Data, mimeType: "application/pdf", fileName: "DirectDepositForm.pdf")
        }
      }
    }
  }
}
