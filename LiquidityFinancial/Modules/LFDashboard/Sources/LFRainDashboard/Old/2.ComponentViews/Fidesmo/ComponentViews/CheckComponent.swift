//
//  CheckComponent.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-06-20.
//

import SwiftUI
import FidesmoCore

// ObservableObject ViewModel required to read/write the State outside of the CheckComponent-View
private class CheckViewModel: ObservableObject {
    @Published fileprivate var selection: Bool = false
    let requirement: DataRequirement
    
    init(requirement: DataRequirement) {
        self.requirement = requirement
    }
}

struct CheckComponent: View {
    @ObservedObject private var viewModel: CheckViewModel
    
    init(requirement: DataRequirement) {
        viewModel = CheckViewModel(requirement: requirement)
    }
    
    var body: some View {
        Button {
            viewModel.selection.toggle()
        } label: {
            HStack {
                Image(systemName: viewModel.selection ? "checkmark.square" : "square")
                Text(viewModel.requirement.label?.getFormattedText() ?? "")
            }
        }
    }
}

extension CheckComponent: Component {
    var value: ComponentValue {
        return (viewModel.requirement.id, String(viewModel.selection))
    }
    
    func verify() -> Bool {
        return UserInteractionValidator.validateUserInteractionTypeInput(value.1, requirement: viewModel.requirement)
    }
}
