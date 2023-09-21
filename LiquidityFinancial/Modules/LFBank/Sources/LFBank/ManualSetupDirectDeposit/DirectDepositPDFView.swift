import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import LFServices

struct DirectDepositPDFView: View {
  @StateObject var viewModel: ManualSetupViewModel

  var body: some View {
    VStack {
      pdfHeaderView
      accountInformationView
      authenticationView
      paycheckDepositView
      signatureView
      footerView
    }
    .navigationBarHidden(true)
    .background(
      Colors.whiteText.swiftUIColor.edgesIgnoringSafeArea(.all)
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension DirectDepositPDFView {
  var authenticationView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(LFLocalizable.DirectDeposit.Pdf.authorization)
        .font(Fonts.bold.swiftUIFont(size: 11))
        .padding(.top, 10)
      HStack {
        Text(LFLocalizable.DirectDeposit.Pdf.firstDescription)
          .font(Fonts.regular.swiftUIFont(size: 11))
          .padding(.top, -8)
        VStack {
          Text(viewModel.achInformation.accountName)
            .font(Fonts.bold.swiftUIFont(size: 11))
            .frame(width: 150, alignment: .leading)
          Divider()
            .frame(width: 150, alignment: .leading)
            .padding(.top, -10)
        }
        Text(LFLocalizable.DirectDeposit.Pdf.secondDescription)
          .font(Fonts.regular.swiftUIFont(size: 11))
          .padding(.top, -8)
        VStack {
          Text(viewModel.employerName)
            .font(Fonts.bold.swiftUIFont(size: 11))
            .frame(width: 140, alignment: .leading)
          Divider()
            .frame(width: 140, alignment: .leading)
            .padding(.top, -10)
        }
        Text(LFLocalizable.DirectDeposit.Pdf.thirdDescription)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .padding(.top, -8)
      }
      .padding(.top, 0)
      VStack {
        Text(LFLocalizable.DirectDeposit.Pdf.fourthDescription)
          .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
          .font(Fonts.regular.swiftUIFont(size: 11))
          .lineSpacing(3)
        
        Text(LFLocalizable.DirectDeposit.Pdf.fifthDescription(LFUtility.appName))
          .font(Fonts.regular.swiftUIFont(size: 11))
          .lineSpacing(3)
          .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
      }
      .padding(.top, -15)
    }
    .foregroundColor(Colors.darkText.swiftUIColor)
    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 20.0)
    .padding(.top, 30)
  }
  
  var paycheckDepositView: some View {
    HStack {
      Text(LFLocalizable.DirectDeposit.Pdf.sixthDescription)
        .font(Fonts.regular.swiftUIFont(size: 11))
        .foregroundColor(Colors.darkText.swiftUIColor)
      Spacer()
      HStack(spacing: 10) {
        paycheckDepositCell(
          isSelected: viewModel.selectedPaychekOption == .optionPercentage,
          text: "% \(viewModel.selectedPaychekOption == .optionPercentage ? viewModel.paycheckPercentage : .empty)"
        )
        Spacer()
        paycheckDepositCell(
          isSelected: viewModel.selectedPaychekOption == .optionAmount,
          text: viewModel.selectedPaychekOption == .optionAmount ? viewModel.paycheckAmount : Constants.CurrencyUnit.usd.rawValue
        )
        Spacer()
        paycheckDepositCell(
          isSelected: viewModel.selectedPaychekOption == .optionFullPayCheck,
          text: LFLocalizable.DirectDeposit.Pdf.entirePaycheck
        )
      }
    }
    .padding([.top, .horizontal], 30.0)
  }
  
  func paycheckDepositCell(isSelected: Bool, text: String) -> some View {
    HStack(spacing: 8) {
      if isSelected {
        GenImages.CommonImages.icCheckboxSelected.swiftUIImage
          .resizable()
          .frame(width: 20.0, height: 20.0, alignment: .leading)
      } else {
        GenImages.CommonImages.icCheckboxUnselected.swiftUIImage
          .resizable()
          .frame(width: 20.0, height: 20.0, alignment: .leading)
      }
      VStack(alignment: .leading) {
        Text(text)
          .frame(height: 20.0, alignment: .leading)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.darkText.swiftUIColor)
        Divider()
          .foregroundColor(Colors.darkText.swiftUIColor.opacity(0.5))
          .padding(.top, -5)
      }
    }
  }

  var accountInformationView: some View {
    VStack {
      payToTheOrderOfView
      Divider()
        .foregroundColor(Colors.darkText.swiftUIColor.opacity(0.5))
        .padding(.top, -10)
      HStack {
        Text(Constants.Default.accountCardSecurity.rawValue)
          .foregroundColor(Colors.darkText.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .padding(.leading, 50)
        Spacer()
        Text(Constants.Default.currencyDescription.rawValue)
          .font(Fonts.regular.swiftUIFont(size: 10))
          .foregroundColor(Colors.separator.swiftUIColor)
          .frame(width: 45.0, height: 35.0, alignment: .trailing)
          .padding(.trailing, 30)
      }
      Divider()
        .foregroundColor(Colors.darkText.swiftUIColor.opacity(0.5))
        .padding(.horizontal, 30)
        .padding(.top, -10)

      HStack(spacing: 50) {
        numberInformation(title: LFLocalizable.DirectDeposit.RoutingNumber.title, value: viewModel.achInformation.routingNumber)
        numberInformation(title: LFLocalizable.DirectDeposit.AccountNumber.title, value: viewModel.achInformation.accountNumber)
        Spacer()
      }
    }
    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    .padding(.vertical, 20)
    .border(Colors.separator.swiftUIColor, width: 0.5)
    .padding(.horizontal, 20.0)
  }

  var signatureView: some View {
    VStack {
      HStack {
        if let imageData = viewModel.signatureImage {
          if let imageCheck = UIImage(data: imageData) {
            Image(uiImage: imageCheck)
              .resizable()
              .frame(width: 60.0, height: 30.0, alignment: .leading)
          }
        }
        Spacer()
        Text(viewModel.dateFormatter.string(from: Date()))
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.darkText.swiftUIColor)
      }
      Divider()
        .foregroundColor(Colors.darkText.swiftUIColor.opacity(0.5))
        .padding(.top, -10)
      HStack {
        Text(LFLocalizable.DirectDeposit.Pdf.signature)
        Spacer()
        Text(LFLocalizable.DirectDeposit.Pdf.date)
      }
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      .foregroundColor(Colors.separator.swiftUIColor)
      .padding(.top, -10)
    }
    .padding(.horizontal, 30.0)
    .padding(.top, 20)
  }

  var footerView: some View {
    HStack {
      Text("\(LFUtility.appName) | \(Constants.Default.companyInformation.rawValue) \(LFLocalizable.DirectDeposit.Pdf.emailText(LFUtility.appName))")
        .frame(width: 270.0, height: 50.0, alignment: .leading)
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.separator.swiftUIColor)
    }
    .padding(.top, 10)
    .padding([.leading, .trailing], 30.0)
    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
  }

  var payToTheOrderOfView: some View {
    HStack {
      Text(LFLocalizable.DirectDeposit.Pdf.payTo)
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.separator.swiftUIColor)
        .frame(width: 85.0, height: 45.0, alignment: .leading)
        .padding(.leading, 10)
      Text(Constants.Default.accountCardSecurity.rawValue)
        .foregroundColor(Colors.darkText.swiftUIColor)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
        .padding(.top, 5)
        .padding(.leading, 15)
      Spacer()
      HStack(spacing: 5) {
        Text(Constants.CurrencyUnit.usd.rawValue)
          .foregroundColor(Colors.darkText.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
          .frame(10, alignment: .trailing)
        ZStack {
          Rectangle()
            .fill(Color.clear)
            .border(Colors.separator.swiftUIColor, width: 0.5)
            .frame(width: 70.0, height: 25, alignment: .center)

          Text("")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .frame(width: 60.0, height: 30, alignment: .center)
        }
      }
      .padding(.trailing, 20)
    }
  }

  var pdfHeaderView: some View {
    VStack {
      HStack {
        GenImages.Images.icLogo.swiftUIImage
          .resizable()
          .scaledToFill()
          .frame(45.0, alignment: .leading)
        Spacer()
        Text(LFLocalizable.DirectDeposit.Pdf.formText)
          .foregroundColor(Colors.pdfTitleBold.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
      }
      HStack {
        Text(viewModel.achInformation.accountName)
          .foregroundColor(Colors.pdfTitleBold.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      Divider()
        .foregroundColor(Colors.darkText.swiftUIColor.opacity(0.5))
      Text(LFLocalizable.DirectDeposit.Pdf.customName)
        .foregroundColor(Colors.separator.swiftUIColor)
        .font(Fonts.bold.swiftUIFont(size: 10))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }
    .padding(.horizontal, 20.0)
  }

  func numberInformation(title: String, value: String) -> some View {
    VStack {
      Text(value)
        .frame(width: 105.0, alignment: .center)
      Text(title)
        .foregroundColor(Colors.separator.swiftUIColor)
        .frame(width: 105.0, alignment: .center)
        .padding(.leading, 20)
    }
    .padding(.leading, 20)
    .font(Fonts.bold.swiftUIFont(size: 10))
    .foregroundColor(.black)
  }
}

// MARK: - View Helpers
extension DirectDepositPDFView {
  func exportToPDF() {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let outputFileURL = documentDirectory.appendingPathComponent(Constants.Default.documentName.rawValue)
    let printView = DirectDepositPDFView(viewModel: viewModel)
    let pdfVC = UIHostingController(rootView: printView)

    // Render the view behind all other views
    let rootVC = LFUtility.rootViewController
    rootVC?.addChild(pdfVC)
    rootVC?.view.insertSubview(pdfVC.view, at: 0)

    let height: CGFloat = 808 // The height of pdf content file
    let width: CGFloat = 612 // The width of pdf file
    let pdfHeight: CGFloat = 842 // The height of pdf file
    
    pdfVC.view.frame = CGRect(x: 0, y: 0, width: width, height: height)

    let numberOfPagesThatFitVertically = Int(ceil(height / pdfHeight))

    // Render the PDF
    let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: width, height: height))
    do {
      try pdfRenderer.writePDF(to: outputFileURL, withActions: { context in
        for indexVertical in 0 ..< numberOfPagesThatFitVertically {
          let offsetVerticalFloat = CGFloat(indexVertical) * pdfHeight
          let offsetVertical = CGRect(x: 0, y: -offsetVerticalFloat, width: width, height: pdfHeight)
          context.beginPage(withBounds: offsetVertical, pageInfo: ["Page": indexVertical])
          pdfVC.view.layer.render(in: context.cgContext)
        }
      })
      log.debug(outputFileURL)
    } catch {
      log.info("Could not create PDF file: \(error)")
    }
    pdfVC.removeFromParent()
    pdfVC.view.removeFromSuperview()
  }
}
