//
//  TextInputComponent.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-05-22.
//

import SwiftUI
import FidesmoCore

// ObservableObject ViewModel required to read/write the State outside of the TextInputComponent-View
private class TextInputViewModel: ObservableObject {
    @Published fileprivate var input: String = ""
    @Published fileprivate var error: String? = nil
    let requirement: DataRequirement
    
    init(requirement: DataRequirement) {
        self.requirement = requirement
    }
    
    fileprivate func validateInput() async {
        var inputError: String?
        if requirement.mandatory {
            inputError = validateMandatory()
        }
        if case .edit(.email) = requirement.type {
            inputError = validateAsEmail()
        }
        await handleError(inputError)
    }
    
    private func handleError(_ validationError: String?) async {
        DispatchQueue.main.async {
            self.error = validationError
        }
    }
    
    private func validateAsEmail() -> String? {
        return UserInteractionValidator.validateUserInteractionTypeInput(input, requirement: requirement) ? nil : "Incorrect Email Format"
    }
    
    private func validateMandatory() -> String? {
        return UserInteractionValidator.validateMandatoryField(input, requirement: requirement) ? nil : "Mandatory Field not Entered"
    }
}

struct TextInputComponent: View {
    @ObservedObject private var viewModel: TextInputViewModel
    
    init(requirement: DataRequirement) {
        viewModel = TextInputViewModel(requirement: requirement)
    }
    
    var body: some View {
        let keyboardType: UIKeyboardType = {
            if case let .edit(format) = viewModel.requirement.type {
                switch format {
                case .email: return .emailAddress
                case .number: return .numberPad
                default: return .default
                }
            }
            return .default
        }()
        
        VStack {
            TextField(viewModel.requirement.label?.getFormattedText() ?? "", text: $viewModel.input)
                .frame(maxWidth: .infinity)
                .keyboardType(keyboardType)
                .validateInputLength($viewModel.input, error: $viewModel.error, requirement: viewModel.requirement, regexPattern: .textMaximumInput)
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

extension TextInputComponent: Component {
    var value: ComponentValue {
        return (viewModel.requirement.id, viewModel.input)
    }
    
    func asyncVerify() async -> Bool {
        await viewModel.validateInput()
        return viewModel.error == nil
    }
}

extension View {
  func componentButton() -> some View {
    frame(maxWidth: .infinity)
      .padding(8)
      .foregroundColor(.white)
      .border(Color.white, width: 2)
  }
  
  // Receives an input and throws an error if the input-limit is exceeded
  func validateInputLength(_ input: Binding<String>, error: Binding<String?>, requirement: DataRequirement, regexPattern: RegexPattern) -> some View {
    self.onChange(of: input.wrappedValue) {
      error.wrappedValue = FieldRegexValidator.validateInput($0, regexPattern: regexPattern) ? nil : "Character limit exceeded"
    }
  }
}
