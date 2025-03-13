//
//  DatePickerComponent.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-06-19.
//

import SwiftUI
import FidesmoCore

// ObservableObject ViewModel required to read/write the State outside of the DatePickerComponent-View
private class DateViewModel: ObservableObject {
    @Published fileprivate var date = Date()
    let requirement: DataRequirement
    
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    init(requirement: DataRequirement) {
        self.requirement = requirement
    }
    
    fileprivate func formattedDate() -> String {
        formatter.string(from: date)
    }
}

struct DatePickerComponent: View {
    @ObservedObject private var viewModel: DateViewModel
    
    init(requirement: DataRequirement) {
        viewModel = DateViewModel(requirement: requirement)
    }
    
    var body: some View {
        VStack {
            Text(viewModel.requirement.label?.getFormattedText() ?? "")
            DatePicker("Select date", selection: $viewModel.date, displayedComponents: .date)
        }
    }
}

extension DatePickerComponent: Component {
    var value: ComponentValue {
        return (viewModel.requirement.id, viewModel.formattedDate())
    }
    
    func verify() -> Bool {
        return UserInteractionValidator.validateUserInteractionTypeInput(value.1, requirement: viewModel.requirement)
    }
}
