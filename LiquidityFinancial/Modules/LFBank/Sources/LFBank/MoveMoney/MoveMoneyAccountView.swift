import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFTransaction
import LFServices
import NetSpendData

public struct MoveMoneyAccountView: View {
  @StateObject private var viewModel: MoveMoneyAccountViewModel
  @State private var showListView: Bool = false
  @State private var showAnnotationView: Bool = false
  @State private var screenSize: CGSize = .zero
  private let completeAction: (() -> Void)?

  public init(kind: MoveMoneyAccountViewModel.Kind, completeAction: (() -> Void)? = nil) {
    _viewModel = .init(
      wrappedValue: MoveMoneyAccountViewModel(kind: kind)
    )
    self.completeAction = completeAction
  }

  public var body: some View {
    content
      .blur(radius: viewModel.showTransferFeeSheet ? 16 : 0)
      .sheet(isPresented: $viewModel.showTransferFeeSheet) {
        transferFeeSheet
          .customPresentationDetents(height: 272)
          .ignoresSafeArea(edges: .bottom)
      }
      .frame(maxWidth: .infinity)
      .readGeometry { geo in
        screenSize = geo.size
      }
      .onAppear {
        viewModel.appearOperations()
      }
      .onChange(of: viewModel.amountInput) { _ in
        viewModel.validateAmountInput()
      }
      .onTapGesture {
        showListView = false
        showAnnotationView = false
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarHidden(viewModel.showTransferFeeSheet)
      .overlay(popupBackground)
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case let .transactionDetai(id):
          TransactionDetailView(
            accountID: viewModel.accountDataManager.fiatAccountID,
            transactionId: id,
            kind: viewModel.kind == .receive ? .deposit : .withdraw,
            destinationView: AnyView(AddBankWithDebitView())
          )
        case .addBankDebit:
          AddBankWithDebitView()
        case .selectBankAccount:
          SelectBankAccountView(linkedAccount: viewModel.linkedAccount, kind: viewModel.kind, amount: viewModel.amount, completeAction: completeAction)
        }
      }
      .background(Colors.background.swiftUIColor)
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: View

private extension MoveMoneyAccountView {
  var content: some View {
    VStack(spacing: .zero) {
      topView
      keyboard
      bottomView
    }
    .overlay(
      accountsList,
      alignment: .top
    )
    .overlay(
      annotationView,
      alignment: .topLeading
    )
    .padding(.horizontal, 30)
    .padding(.bottom, 34)
    .background(Colors.background.swiftUIColor)
  }
  
  @ViewBuilder var popupBackground: some View {
    if viewModel.showTransferFeeSheet {
      Colors.background.swiftUIColor.opacity(0.5).ignoresSafeArea()
    }
  }

  var topView: some View {
    VStack(spacing: 12) {
      titleView
      accountsDropdown
      Spacer(minLength: 0)
      amountInput
      Spacer(minLength: 0)
      preFilledGrid
    }
  }

  var titleView: some View {
    HStack {
      Spacer()
      VStack(spacing: 10) {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
        if viewModel.kind == .send {
          HStack(spacing: 4) {
            Text(viewModel.subtitle)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
              .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
            GenImages.CommonImages.info.swiftUIImage
              .foregroundColor(Colors.label.swiftUIColor)
              .frame(width: 16, height: 16)
              .onTapGesture {
                showAnnotationView.toggle()
              }
          }
        }
      }
      Spacer()
    }
  }
  
  @ViewBuilder var accountsDropdown: some View {
    Button {
      showListView.toggle()
    } label: {
      HStack {
        if let account = viewModel.selectedLinkedAccount {
          Text(viewModel.title(for: account))
            .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.label.swiftUIColor)
        }
        Spacer()
        Image(systemName: showListView ? "chevron.up" : "chevron.down")
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
      }
      .frame(width: screenSize.width * 0.48, height: 40)
    }
    .padding(.horizontal, 12)
    .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(8))
  }

  @ViewBuilder var annotationView: some View {
    if showAnnotationView {
      AnnotationView(description: viewModel.annotationString)
        .frame(width: screenSize.width * 0.64)
        .offset(x: -10, y: 52)
    }
  }

  @ViewBuilder var accountsList: some View {
    if showListView {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(viewModel.linkedAccount, id: \.sourceId) { item in
          HStack {
            Text(viewModel.title(for: item))
              .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundColor(Colors.label.swiftUIColor)
            Spacer()
            Image(systemName: "checkmark")
              .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(
                viewModel.selectedLinkedAccount?.sourceId == item.sourceId ?
                Colors.primary.swiftUIColor : .clear
              )
          }
          .onTapGesture {
            viewModel.selectedLinkedAccount = item
            showListView.toggle()
          }
        }
        addAccountButton
      }
      .frame(width: screenSize.width * 0.48)
      .padding(12)
      .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(8))
      .offset(y: viewModel.kind == .receive ? 80 : 108) // accountDropdown height + spacing + header height
    }
  }

  var amountInput: some View {
    VStack(spacing: 12) {
      HStack(spacing: 4) {
        GenImages.CommonImages.usdSymbol.swiftUIImage
          .frame(width: 19, height: 38)
          .offset(y: 6)
        Text(viewModel.amountInput)
          .font(Fonts.bold.swiftUIFont(size: 50))
          .frame(height: 60)
      }
      .foregroundColor(Colors.label.swiftUIColor)
      .shakeAnimation(with: viewModel.numberOfShakes)
      Text(viewModel.inlineError ?? String.empty)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.error.swiftUIColor)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .opacity(viewModel.inlineError.isNotNil ? 1 : 0)
    }
  }

  var bottomView: some View {
    FullSizeButton(
      title: LFLocalizable.Button.Continue.title,
      isDisable: !viewModel.isAmountActionAllowed,
      isLoading: $viewModel.showIndicator
    ) {
      viewModel.continueTransfer()
    }
  }

  var keyboard: some View {
    KeyboardCustomView(
      value: $viewModel.amountInput,
      action: viewModel.resetSelectedValue,
      disable: viewModel.showIndicator
    )
    .padding(.vertical, 24)
  }

  var preFilledGrid: some View {
    PreFilledGridView(
      selectedValue: $viewModel.selectedValue,
      preFilledValues: viewModel.recommendValues,
      action: viewModel.onSelectedGridItem
    )
  }

  var addAccountButton: some View {
    Button {
      viewModel.navigateAddAccount()
    } label: {
      Text(LFLocalizable.MoveMoney.addAccount)
        .frame(height: 40)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.label.swiftUIColor)
    }
    .frame(maxWidth: .infinity)
    .background(Colors.primary.swiftUIColor.cornerRadius(8))
  }
}

// MARK: UI Helpers

private extension MoveMoneyAccountView {
  var title: String {
    switch viewModel.kind {
    case .receive:
      return LFLocalizable.MoveMoney.Deposit.title
    case .send:
      return LFLocalizable.MoveMoney.Withdraw.title
    }
  }
  
  var transferFeeSheet: some View {
    VStack(spacing: 10) {
      RoundedRectangle(cornerRadius: 4)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .frame(width: 32, height: 4)
        .padding(.top, 6)
      Text(viewModel.transferFeePopupTitle)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .padding(.vertical, 14)
      Button {
        viewModel.selectTransferInstant = true
      } label: {
        HStack(spacing: 12) {
          Text(LFLocalizable.MoveMoney.TransferFeePopup.instant)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.label.swiftUIColor)
          Spacer()
          HStack(spacing: 8) {
            Text("$0.69")
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundColor(Colors.primary.swiftUIColor)
            
            if let isSelect = viewModel.selectTransferInstant, isSelect {
              GenImages.Images.icKycQuestionCheck.swiftUIImage
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(.trailing, 20)
            } else {
              Ellipse()
                .foregroundColor(.clear)
                .frame(width: 20, height: 20)
                .overlay(
                  Ellipse()
                    .inset(by: 0.50)
                    .stroke(.white, lineWidth: 1)
                )
                .opacity(0.25)
                .padding(.trailing, 20)
            }
          }
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
        .background(Colors.background.swiftUIColor)
        .cornerRadius(9)
      }
      
      Button {
        viewModel.selectTransferInstant = false
      } label: {
        HStack(spacing: 12) {
          HStack(spacing: 12) {
            Text(LFLocalizable.MoveMoney.TransferFeePopup.normal)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundColor(Colors.label.swiftUIColor)
            
            Text(LFLocalizable.MoveMoney.TransferFeePopup.normalDays)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
          }
          Spacer()
          HStack(spacing: 8) {
            Text(LFLocalizable.MoveMoney.TransferFeePopup.free)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundColor(Colors.primary.swiftUIColor)
            
            if let isSelect = viewModel.selectTransferInstant, !isSelect {
              GenImages.Images.icKycQuestionCheck.swiftUIImage
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(.trailing, 20)
            } else {
              Ellipse()
                .foregroundColor(.clear)
                .frame(width: 20, height: 20)
                .overlay(
                  Ellipse()
                    .inset(by: 0.50)
                    .stroke(.white, lineWidth: 1)
                )
                .opacity(0.25)
                .padding(.trailing, 20)
            }
          }
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
        .background(Colors.background.swiftUIColor)
        .cornerRadius(9)
      }
      
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: viewModel.selectTransferInstant == nil,
        isLoading: $viewModel.showIndicator
      ) {
        viewModel.continueTransferFeePopup()
      }
      .padding(.vertical, 32)
    }
    .padding(.horizontal, 30)
    .background(Colors.secondaryBackground.swiftUIColor)
  }
}

// MARK: - AddMoneyAccountView_Previews

struct AddMoneyAccountView_Previews: PreviewProvider {
  static var previews: some View {
    MoveMoneyAccountView(kind: .receive)
      .embedInNavigation()
  }
}
