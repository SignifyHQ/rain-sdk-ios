import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct KycQuestionsView: View {
  
  @State var offsetChange: CGPoint = .zero
  
  @StateObject var viewModel: KYCQuestionsViewModel
  
  public init(viewModel: KYCQuestionsViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack {
      headerView
      
      OffsetObservingScrollView(offset: $offsetChange) {
        ForEach($viewModel.questionList.questions, id: \.id) { question in
          KYCAnswerQuestionView(answerOption: question) { _, id in
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
        isDisable: false,
        type: .primary
      ) {
       
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 8)
      .padding(.top, 5)

    }
    .frame(max: .infinity)
    .background(Colors.background.swiftUIColor)
    
  }
  
  private var headerView: some View {
    Group {
      Text(LFLocalizable.Kyc.Question.title.uppercased())
        .font(Fonts.Inter.regular.swiftUIFont(size: 20))
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 0)
      Text(LFLocalizable.Kyc.Question.desc)
        .font(Fonts.Inter.regular.swiftUIFont(size: 16))
        .foregroundColor(.white)
        .padding(.top, 2)
        .padding(.horizontal, 20)
      
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Color.white)
        .padding(.vertical, 12)
      
      HStack {
        GenImages.CommonImages.icKycQuestion.swiftUIImage
        Spacer()
      }
      .padding(.horizontal, 20)
    }
  }
  
}

#if DEBUG
struct KycQuestionsView_Previews: PreviewProvider {
  static var previews: some View {
    KycQuestionsView(viewModel: KYCQuestionsViewModel())
  }
}
#endif

private struct KYCAnswerQuestionView: View {
  @Binding var answerOption: KYCQuestion.AnswerOptions
  let onChange: (_ isChecked: Bool, _ id: String) -> Void
  
  var body: some View {
    Group {
      HStack {
        Text(answerOption.question)
          .font(Fonts.Inter.regular.swiftUIFont(size: 16))
          .foregroundColor(.white)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
        Spacer()
      }
      ForEach($answerOption.answer, id: \.answerId) { result in
        KYCAnswerButton(answer: result) { isChecked, id in
          onChange(isChecked, id)
        }
      }
    }
  }
}

private struct KYCAnswerButton: View {
  @Binding var answer: KYCQuestion.Answer
  let onChange: (_ isChecked: Bool, _ id: String) -> Void

  var body: some View {
    Button {
      onChange(answer.isSelect, answer.answerId)
    } label: {
      ZStack {
        Rectangle()
          .foregroundColor(.clear)
          .frame(height: 56)
          .background(Color(red: 0.18, green: 0.17, blue: 0.19))
          .cornerRadius(9)
          .offset(x: 0, y: 0)
        
        HStack {
          Text(answer.text)
            .font(Fonts.Inter.regular.swiftUIFont(size: 16))
            .foregroundColor(.white)
            .padding(.leading, 20)
          
          Spacer()
          
          if answer.isSelect {
            GenImages.CommonImages.icKycQuestionCheck.swiftUIImage
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
      .padding(.horizontal, 20)
    }
  }
}
