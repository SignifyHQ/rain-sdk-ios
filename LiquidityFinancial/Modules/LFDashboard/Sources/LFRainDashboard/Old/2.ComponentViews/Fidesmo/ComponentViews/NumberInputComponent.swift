//
//  NumberInputComponent.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-05-22.
//

import SwiftUI
import FidesmoCore

// ObservableObject ViewModel required to read/write the State outside of the NumberInputComponent-View
private class NumberInputViewModel: ObservableObject {
    @Published fileprivate var input: String = ""
    @Published fileprivate var error: String? = nil
    
    fileprivate let obfuscated: Bool
    let requirement: DataRequirement
    
    init(requirement: DataRequirement, obfuscated: Bool) {
        self.requirement = requirement
        self.obfuscated = obfuscated
    }
    
    fileprivate func validateInput() async {
        var inputError: String?
        
        if case .edit(let format) = requirement.type, format == .number || format == .obfuscatedNumber {
            inputError = validateAsNumber()
        }
        await handleError(inputError)
    }
    
    private func validateAsNumber() -> String? {
        if !FieldRegexValidator.validateInput(input, regexPattern: .numberInputFormat) {
            return "Invalid Numeric Input"
        } else if !FieldRegexValidator.validateInput(input, regexPattern: .numberMaximumInput) {
            return "Character limit exceeded"
        }
        return nil
    }
    
    private func handleError(_ validationError: String?) async {
        DispatchQueue.main.async {
            self.error = validationError
        }
    }
}

struct NumberInputComponent: View {
    @ObservedObject private var viewModel: NumberInputViewModel
    
    init(requirement: DataRequirement, obfuscated: Bool) {
        viewModel = NumberInputViewModel(requirement: requirement, obfuscated:  obfuscated)
    }
    
    var body: some View {
        VStack {
            if viewModel.obfuscated {
                SecureField(viewModel.requirement.label?.getFormattedText() ?? "", text: $viewModel.input)
                    .frame(maxWidth: .infinity)
                    .keyboardType(.numberPad)
                    .validateInputLength($viewModel.input, error: $viewModel.error, requirement: viewModel.requirement, regexPattern: .numberMaximumInput)
            } else {
                TextField(viewModel.requirement.label?.getFormattedText() ?? "", text: $viewModel.input)
                    .frame(maxWidth: .infinity)
                    .keyboardType(.numberPad)
                    .validateInputLength($viewModel.input, error: $viewModel.error, requirement: viewModel.requirement, regexPattern: .numberMaximumInput)
            }
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

extension NumberInputComponent: Component {
    var value: ComponentValue {
        return (viewModel.requirement.id, viewModel.input)
    }
    
    func asyncVerify() async -> Bool {
        await viewModel.validateInput()
        return viewModel.error == nil
    }
}
