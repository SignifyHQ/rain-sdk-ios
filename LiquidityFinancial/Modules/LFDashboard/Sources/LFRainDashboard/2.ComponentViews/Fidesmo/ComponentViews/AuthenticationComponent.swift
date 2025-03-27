//
//  AuthenticationComponent.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-06-21.
//

import SwiftUI
import UIKit
import FidesmoCore
import SafariServices

// SwiftUI View to use SFSafariViewController
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}

struct SafariModel: Identifiable {
    let id = UUID()
    let url: URL
}

// ObservableObject ViewModel required to read/write the State outside of the AuthenticationComponent-View
private class AuthenticationViewModel: ObservableObject {
    @Published fileprivate var returnedResult: String? = nil
    private let nextHandler: () async -> Void
    private let appScheme = "fidesmo"
    
    let requirement: DataRequirement
    
    init(requirement: DataRequirement, nextHandler: @escaping () async -> Void) {
        self.requirement = requirement
        self.nextHandler = nextHandler
    }
    
    fileprivate func handleUrl(_ openedUrl: URL?, _ safariModel: @escaping (SafariModel?) -> Void) async {
        if let openedUrl = openedUrl {
            if openedUrl.scheme == appScheme {
                // Used for app to app activation, will get triggered when the issuer app returns
                // Also used for web activation, will get triggered if the custom scheme is launched from the web
                if let response = FidesmoUrlParser.appAuthentication(for: openedUrl) {
                    DispatchQueue.main.async { [self] in
                        safariModel(nil)
                        returnedResult = response
                    }
                    await nextHandler()
                }
            }
        }
    }
    
    fileprivate func buttonRequirementTile() -> String {
        switch requirement.type {
        case .appAuth:
            return "Open App"
        case .openUrl:
            return "Open URL"
        case .webActivation:
            return "Open Safari"
        default: return "No Requirement"
        }
    }

    fileprivate func openApp() {
        guard let appUrl = requirement.appUrl else { return }
        if let url = URL(string: appUrl) {
            UIApplication.shared.open(url, completionHandler: { (success) in
                if !success {
                    if let appStoreId = self.requirement.appStoreId {
                        guard let appStoreUrl = URL(string: "itms-apps://apple.com/app/id\(appStoreId)") else {return}
                        UIApplication.shared.open(appStoreUrl)
                    }
                }
            })
        }
    }

    fileprivate func openUrl() {
        if let stringUrl = requirement.url, let fetchedUrl = URL(string: stringUrl) {
            UIApplication.shared.open(fetchedUrl)
        }
    }

    fileprivate func openSafari(_ safariModel: @escaping (SafariModel) -> Void) {
        if let stringUrl = requirement.url, let fetchedUrl = URL(string: stringUrl) {
            safariModel(SafariModel(url: fetchedUrl))
        }
    }
}

struct AuthenticationComponent: View {
    @ObservedObject private var viewModel: AuthenticationViewModel
    @State private var safariModel: SafariModel?
    
    init(requirement: DataRequirement, nextHandler: @escaping () async -> Void = {}) {
        viewModel = AuthenticationViewModel(requirement: requirement, nextHandler: nextHandler)
    }

    var body: some View {
        VStack {
            Button(viewModel.buttonRequirementTile()) {
                handleDataRequirement()
            }
        }
        .onOpenURL { url in
            Task {
                await viewModel.handleUrl(url) {
                    safariModel = $0
                }
            }
        }
        .onAppear {
            handleDataRequirement()
        }
        .onChange(of: viewModel.requirement) { _ in
            handleDataRequirement()
        }
        .sheet(item: $safariModel) { safariModel in
            SafariView(url: safariModel.url)
        }
    }
    
    private func handleDataRequirement() {
        switch viewModel.requirement.type {
        case .appAuth:
            viewModel.openApp()
        case .openUrl:
            viewModel.openUrl()
        case .webActivation:
            viewModel.openSafari {
                safariModel = $0
            }
        default: break
        }
    }
}

extension AuthenticationComponent: Component {
    var value: ComponentValue {
        return (viewModel.requirement.id, viewModel.returnedResult ?? "")
    }

    func verify() -> Bool {
        return true
    }
}
