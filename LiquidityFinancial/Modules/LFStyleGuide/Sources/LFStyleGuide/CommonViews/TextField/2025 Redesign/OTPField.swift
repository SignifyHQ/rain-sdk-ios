import Combine
import SwiftUI
import LFUtilities

public struct OTPField: View {
  @Binding var code: String
  
  let digitCount: Int
  let isSecureInput: Bool
  
  let boxBackgroundColor = Colors.backgroundOtp.swiftUIColor
  let boxHighlightColor = Colors.backgroundLight.swiftUIColor
  
  @FocusState private var isTextFieldFocused: Bool
  
  public init(
    code: Binding<String>,
    digitCount: Int = 4,
    isSecureInput: Bool = false
  ) {
    self._code = code
    self.digitCount = digitCount
    self.isSecureInput = isSecureInput
  }
  
  private var codeDigits: [String] {
    let codeArray = code.map { String($0) }
    
    guard codeArray.count <= digitCount else {
      return codeArray
    }
    
    let paddingCount = digitCount - codeArray.count
    let paddedArray = codeArray + Array(repeating: "", count: paddingCount)
    
    return paddedArray
  }
  
  public var body: some View {
    ZStack {
      TextField(
        "",
        text: $code
      )
      .keyboardType(.numberPad)
      .textContentType(.oneTimeCode)
      .frame(
        width: 0,
        height: 0
      )
      .opacity(0)
      .allowsHitTesting(true)
      .focused($isTextFieldFocused)
      .id("hiddenTextField")
      .onChange(
        of: code
      ) { newValue in
        if newValue.count > digitCount {
          code = String(newValue.prefix(digitCount))
        }
      }
      
      HStack(
        spacing: 10
      ) {
        let focusedIndex = code.count
        
        ForEach(
          0..<digitCount,
          id: \.self
        ) { index in
          DigitBox(
            digit: codeDigits[index],
            isFocused: index == focusedIndex && code.count < digitCount && isTextFieldFocused,
            backgroundColor: boxBackgroundColor,
            highlightColor: boxHighlightColor,
            isSecureInput: isSecureInput
          )
        }
      }
    }
    .contentShape(Rectangle())
    .frame(
      maxWidth: .infinity
    )
    .onTapGesture {
      isTextFieldFocused = true
    }
  }
}

private struct DigitBox: View {
  let digit: String
  let isFocused: Bool
  let backgroundColor: Color
  let highlightColor: Color
  let isSecureInput: Bool
  
  @State private var shouldFlashDigit: Bool = false
  
  private var shouldDisplayCursor: Bool {
    isFocused && digit.isEmpty
  }
  
  private var displayContent: String {
    guard !digit.isEmpty
    else {
      return shouldDisplayCursor ? "_" : ""
    }
    
    if isSecureInput && !shouldFlashDigit {
      return "•"
    } else {
      return digit
    }
  }
  
  var body: some View {
    ZStack {
      RoundedRectangle(
        cornerRadius: 12
      )
      .fill(shouldDisplayCursor ? highlightColor : backgroundColor)
      .frame(
        width: 65,
        height: 80
      )
      
      Text(displayContent)
        .foregroundColor(Colors.titlePrimary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(fixedSize: Constants.FontSize.otp.value))
        .animation(
          .none,
          value: digit
        )
    }
    .scaleEffect(isFocused ? 1.05 : 1.0)
    .animation(
      .spring(
        response: 0.3,
        dampingFraction: 0.6
      ),
      value: isFocused
    )
    .onChange(
      of: digit
    ) { newValue in
      if isSecureInput && !newValue.isEmpty {
        shouldFlashDigit = true
        
        Task {
          try await Task.sleep(for: .milliseconds(150))
          
          await MainActor.run {
            shouldFlashDigit = false
          }
        }
      } else if newValue.isEmpty {
        shouldFlashDigit = false
      }
    }
  }
}
