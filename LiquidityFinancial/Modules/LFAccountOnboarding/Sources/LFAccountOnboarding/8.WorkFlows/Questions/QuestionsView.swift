import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

struct QuestionsView: View {
  @StateObject var viewModel: QuestionsViewModel
  @State var offsetChange: CGPoint = .zero

  init(viewModel: QuestionsViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    VStack {
      headerView
      OffsetObservingScrollView(offset: $offsetChange) {
        ForEach($viewModel.questionList.questions, id: \.id) { question in
          AnswerQuestionView(answerOption: question) { _, id in
            viewModel.updateAnswerSelect(questionID: question.wrappedValue.id, answerID: id)
          }
        }
      }
      Button {
        
      } label: {
        Image(systemName: "chevron.compact.down")
          .font(.largeTitle)
          .imageScale(.large)
      }
      .padding(3)
      .foregroundColor(.white)
      .isHidden(hidden: offsetChange.y >= 100, remove: true)
      
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: !viewModel.isEnableContinue,
        isLoading: $viewModel.isLoading,
        type: .primary
      ) {
        viewModel.actionContinue()
      }
      .padding(.bottom, 8)
      .padding(.top, 5)
    }
    .onReceive(viewModel.timer) { _ in
      viewModel.coundownTimer()
    }
    .padding(.horizontal, 30)
    .frame(max: .infinity)
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
      }
    }
    .navigationBarBackButtonHidden(viewModel.isLoading)
  }
}

// MARK: - View Components
private extension QuestionsView {
  var headerView: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text(LFLocalizable.Kyc.Question.title.uppercased())
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Text(LFLocalizable.Kyc.Question.desc)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        Text(LFLocalizable.Kyc.Question.timeDesc)
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
      title: LFLocalizable.Kyc.TimeIsUp.title,
      message: LFLocalizable.Kyc.TimeIsUp.message,
      primary: .init(text: LFLocalizable.Button.ContactSupport.title) {
        viewModel.contactSupport()
      },
      secondary: .init(text: LFLocalizable.Button.NotNow.title) {
        viewModel.logout()
      }
    )
  }
}

private struct AnswerQuestionView: View {
  @Binding var answerOption: QuestionsEntity.AnswerOptions
  let onChange: (_ isChecked: Bool, _ id: String) -> Void
  
  var body: some View {
    Group {
      HStack {
        Text(answerOption.question)
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
