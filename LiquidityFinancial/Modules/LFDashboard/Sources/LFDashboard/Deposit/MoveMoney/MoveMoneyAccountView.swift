import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

struct MoveMoneyAccountView: View {
  @StateObject private var viewModel: MoveMoneyAccountViewModel
  @State private var showListView: Bool = false
  @State private var showAnnotationView: Bool = false
  @State private var screenSize: CGSize = .zero

  init(kind: MoveMoneyAccountViewModel.Kind) {
    _viewModel = .init(
      wrappedValue: MoveMoneyAccountViewModel(kind: kind)
    )
  }

  var body: some View {
    content
      .frame(maxWidth: .infinity)
      .readGeometry { geo in
        screenSize = geo.size
      }
      .onChange(of: viewModel.amountInput) { _ in
        viewModel.validateAmountInput()
      }
      .onTapGesture {
        showListView = false
        showAnnotationView = false
      }
      .navigationBarTitleDisplayMode(.inline)
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
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
    // TODO: Will show selected card later
    let selectedCard = "Debit card **** 7424"
    
    Button {
      showListView.toggle()
    } label: {
      HStack {
        Text(
          selectedCard
        )
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        Image(systemName: showListView ? "chevron.up" : "chevron.down")
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
      }
      .frame(width: screenSize.width * 0.46, height: 40)
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
    // TODO: Will update it later
    let contactCards = [
      "Debit card **** 1234",
      "Debit card **** 2222",
      "Debit card **** 3333"
    ]
    let selectedCard = "Debit card **** 2222"
    if showListView {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(contactCards, id: \.self) { item in
          HStack {
            Text(item)
              .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundColor(Colors.label.swiftUIColor)
            Spacer()
            Image(systemName: "checkmark")
              .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(
                selectedCard == item ?
                Colors.primary.swiftUIColor : .clear
              )
          }
          .onTapGesture {
            showListView.toggle()
          }
        }
        addAccountButton
      }
      .frame(width: screenSize.width * 0.46)
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
      isDisable: !viewModel.isAmountActionAllowed
    ) {
      // TODO: Will implementation later
      // callBioMetric()
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
      // TODO: Will navigate to account view
      // viewModel.navigateToAccountView()
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
}

// MARK: - AddMoneyAccountView_Previews

struct AddMoneyAccountView_Previews: PreviewProvider {
  static var previews: some View {
    MoveMoneyAccountView(kind: .receive)
      .embedInNavigation()
  }
}
