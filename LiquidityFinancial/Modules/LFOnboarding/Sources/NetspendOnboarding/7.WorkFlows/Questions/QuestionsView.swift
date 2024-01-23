import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import Services

public struct QuestionsView: View {
  @StateObject var viewModel: QuestionsViewModel
  @State var offsetChange: CGPoint = .zero
  @State var selectedPage: Int = 0
  
  public init(viewModel: QuestionsViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack {
      headerView
        .padding(.top, 30)
      
      TabView(selection: $selectedPage) {
        ForEach(Array($viewModel.questionList.questions.enumerated()), id: \.offset) { index, question in
          AnswerQuestionView(answerOption: question) { _, id in
            viewModel.updateAnswerSelect(questionID: question.wrappedValue.id, answerID: id)
            withAnimation {
              if selectedPage < viewModel.questionList.questions.count - 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                  selectedPage += 1
                }
              }
            }
          }
          .padding(.horizontal, 30)
          .tag(index)
        }
      }
      .onChange(of: selectedPage) { newValue in
        log.debug(newValue)
      }
      .frame(width: UIScreen.main.bounds.width)
      .tabViewStyle(.page(indexDisplayMode: .never))
      .animation(.easeInOut, value: 0.55)
      .transition(.slide)
      
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: !viewModel.isEnableContinue,
        isLoading: $viewModel.isLoading,
        type: .primary
      ) {
        viewModel.actionContinue()
      }
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .popup(item: $viewModel.popup) { popup in
      switch popup {
      case .timeIsUp:
        timeIsUpPopup
      }
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .kycReview:
        KYCStatusView(viewModel: KYCStatusViewModel(state: .inReview(viewModel.accountDataManager.userNameDisplay)))
      case .missingInfo:
        KYCStatusView(viewModel: KYCStatusViewModel(state: .missingInfo))
      case .uploadDocument:
        UploadDocumentView()
      case .agreement:
        AgreementView(viewModel: AgreementViewModel(needBufferData: true)) {
          log.info("after accept agreement will fetch missing step and go next:\(viewModel.onboardingFlowCoordinator.routeSubject.value) ")
        }
      }
    }
    .navigationBarBackButtonHidden()
    .track(name: String(describing: type(of: self)))
  }
}

  // MARK: - View Components
private extension QuestionsView {
  var headerView: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text(L10N.Common.Kyc.Question.title.uppercased())
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Text(L10N.Common.Kyc.Question.desc)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        Text(L10N.Common.Kyc.Question.timeDesc)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.primary.swiftUIColor)
      }
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Color.white)
      HStack {
        GenImages.Images.icKycQuestion.swiftUIImage
        Spacer()
      }
    }
  }
  
  var timeIsUpPopup: some View {
    LiquidityAlert(
      title: L10N.Common.Kyc.TimeIsUp.title,
      message: L10N.Common.Kyc.TimeIsUp.message,
      primary: .init(text: L10N.Common.Button.ContactSupport.title) {
        viewModel.contactSupport()
      },
      secondary: .init(text: L10N.Common.Button.NotNow.title) {
        viewModel.logout()
      }
    )
  }
}

private struct AnswerQuestionView: View {
  @Binding var answerOption: QuestionsEntity.AnswerOptions
  let onChange: (_ isChecked: Bool, _ id: String) -> Void
  
  var body: some View {
    VStack {
      HStack {
        Text(answerOption.question)
          .lineLimit(4)
          .font(Fonts.regular.swiftUIFont(size: 16))
          .foregroundColor(.white)
          .padding(.vertical, 12)
        Spacer()
      }
      ForEach($answerOption.answer, id: \.answerId) { result in
        AnswerButton(answer: result) { isChecked, id in
          onChange(isChecked, id)
        }
      }
    }
  }
}

private struct AnswerButton: View {
  @Binding var answer: QuestionsEntity.Answer
  let onChange: (_ isChecked: Bool, _ id: String) -> Void
  
  var body: some View {
    Button {
      onChange(answer.isSelect, answer.answerId)
    } label: {
      ZStack {
        Rectangle()
          .foregroundColor(.clear)
          .frame(height: 56)
          .background(Colors.secondaryBackground.swiftUIColor)
          .cornerRadius(9)
          .offset(x: 0, y: 0)
        
        HStack {
          Text(answer.text)
            .font(Fonts.regular.swiftUIFont(size: 16))
            .foregroundColor(.white)
            .padding(.leading, 20)
          
          Spacer()
          
          if answer.isSelect {
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
    }
  }
}
