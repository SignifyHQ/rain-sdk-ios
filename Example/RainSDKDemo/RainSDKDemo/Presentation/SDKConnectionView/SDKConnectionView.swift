import SwiftUI
import RainSDK
import AuthenticationServices
import UIKit

/// Demo view for connecting to Rain SDK
/// Can be extended with more SDK functions in the future
struct SDKConnectionView: View {
  @StateObject private var viewModel = SDKConnectionViewModel()

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          // Header
          headerSection
          
          // Status Section
          statusSection
          
          // Input Section
          inputSection
          
          // Actions Section
          actionsSection
          
          // Future Features Section (Placeholder)
          futureFeaturesSection
        }
        .padding()
      }
      .navigationTitle("Rain SDK Demo")
      .navigationBarTitleDisplayMode(.large)
    }
  }
  
  // MARK: - Header Section
  
  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "link.circle.fill")
        .font(.system(size: 60))
        .foregroundColor(.blue)
      
      Text("Rain SDK Connection")
        .font(.title2)
        .fontWeight(.bold)
      
      Text("Initialize with Portal, Turnkey, or wallet-agnostic mode")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    .padding(.vertical)
  }
  
  // MARK: - Status Section
  
  private var statusSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Status")
        .font(.headline)
      
      HStack {
        Circle()
          .fill(viewModel.isInitialized ? Color.green : Color.gray)
          .frame(width: 12, height: 12)
        
        Text(viewModel.statusMessage)
          .font(.body)
      }
      
      if let error = viewModel.error {
        VStack(alignment: .leading, spacing: 4) {
          Text("Error Code: \(error.errorCode)")
            .font(.caption)
            .foregroundColor(.red)
          
          Text(error.localizedDescription)
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  // MARK: - Input Section
  
  private var inputSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Configuration")
        .font(.headline)
      
      // Initialization Mode Toggle
      Toggle("Wallet-Agnostic Mode", isOn: $viewModel.useWalletAgnostic)
        .padding(.vertical, 4)
      
      if !viewModel.useWalletAgnostic {
        // Wallet provider dropdown (Portal only for now)
        HStack {
          Text("Wallet Provider")
            .font(.subheadline)
            .foregroundColor(.secondary)
          Spacer()
          Picker("Wallet Provider", selection: $viewModel.selectedProvider) {
            ForEach(WalletProviderOption.allCases, id: \.self) { option in
              Text(option.displayName).tag(option)
            }
          }
          .pickerStyle(.menu)
        }

        // Portal Token Input (when Portal is selected)
        if viewModel.selectedProvider == .portal {
          VStack(alignment: .leading, spacing: 8) {
            Text("Session Token")
              .font(.subheadline)
              .foregroundColor(.secondary)

            TextField("Enter session token", text: $viewModel.sessionToken)
              .textFieldStyle(.roundedBorder)
              .autocapitalization(.none)
              .disableAutocorrection(true)
          }
        }

        // Turnkey Inputs (when Turnkey is selected)
        if viewModel.selectedProvider == .turnkey {
          turnkeyInputs
        }
      }
      
      // Chain family selector (EVM vs Solana). Prefills chain id + RPC URL on change.
      HStack {
        Text("Chain")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Spacer()
        Picker("Chain", selection: $viewModel.chainFamily) {
          ForEach(ChainFamily.allCases, id: \.self) { family in
            Text(family.displayName).tag(family)
          }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 200)
      }

      // Chain ID Input
      VStack(alignment: .leading, spacing: 8) {
        Text("Chain ID")
          .font(.subheadline)
          .foregroundColor(.secondary)

        TextField("e.g., \(DemoLocalConfig.chainId)", text: $viewModel.chainId)
          .textFieldStyle(.roundedBorder)
          .keyboardType(.numberPad)
      }
      
      // RPC URL Input
      VStack(alignment: .leading, spacing: 8) {
        Text("RPC URL")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        TextField(DemoLocalConfig.rpcUrl, text: $viewModel.rpcUrl)
          .textFieldStyle(.roundedBorder)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  // MARK: - Turnkey Inputs

  private var turnkeyInputs: some View {
    VStack(alignment: .leading, spacing: 12) {
      labeledField(
        title: "Organization ID",
        placeholder: "your-turnkey-suborg-id",
        text: $viewModel.turnkeyOrgId
      )

      labeledField(
        title: "API URL",
        placeholder: "https://api.turnkey.com",
        text: $viewModel.turnkeyApiUrl
      )

      labeledField(
        title: "Auth Proxy URL",
        placeholder: "https://authproxy.turnkey.com",
        text: $viewModel.turnkeyAuthProxyUrl
      )

      labeledField(
        title: "Auth Proxy Config ID",
        placeholder: "required for Sign Up",
        text: $viewModel.turnkeyAuthProxyConfigId
      )

      labeledField(
        title: "Relying Party ID (rpId)",
        placeholder: "your.app.domain",
        text: $viewModel.turnkeyRpId
      )

      Button {
        hideKeyboard()
        guard let anchor = currentPresentationAnchor() else { return }
        Task { await viewModel.signUpWithTurnkeyPasskey(anchor: anchor) }
      } label: {
        HStack {
          if viewModel.isAuthenticatingTurnkey {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          } else {
            Image(systemName: "person.crop.circle.badge.plus")
          }
          Text("Sign Up with Passkey")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(viewModel.canSignUpWithPasskey ? Color.blue : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(10)
      }
      .disabled(!viewModel.canSignUpWithPasskey)
      .opacity(viewModel.canSignUpWithPasskey ? 1 : 0.6)

      Button {
        hideKeyboard()
        guard let anchor = currentPresentationAnchor() else { return }
        Task { await viewModel.loginWithTurnkeyPasskey(anchor: anchor) }
      } label: {
        HStack {
          if viewModel.isAuthenticatingTurnkey {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .blue))
          } else {
            Image(systemName: "person.badge.key.fill")
          }
          Text("Login with Passkey")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.clear)
        .foregroundColor(viewModel.canAuthenticateWithPasskey ? .blue : .gray)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(viewModel.canAuthenticateWithPasskey ? Color.blue : Color.gray, lineWidth: 1)
        )
      }
      .disabled(!viewModel.canAuthenticateWithPasskey)
      .opacity(viewModel.canAuthenticateWithPasskey ? 1 : 0.6)

      Text("First time? Tap Sign Up — it creates a sub-org with a wallet and registers a passkey for this device. Already signed up on this device? Tap Login.")
        .font(.caption)
        .foregroundColor(.secondary)

      Divider()
        .padding(.vertical, 4)

      Text("Or sign in with Email OTP")
        .font(.subheadline).bold()

      labeledField(
        title: "Email",
        placeholder: "you@example.com",
        text: $viewModel.turnkeyEmail
      )

      if viewModel.turnkeyOtpId == nil {
        Button {
          hideKeyboard()
          Task { await viewModel.sendTurnkeyEmailOtp() }
        } label: {
          HStack {
            if viewModel.isProcessingTurnkeyOtp {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
              Image(systemName: "envelope.fill")
            }
            Text("Send OTP")
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .background(viewModel.canSendEmailOtp ? Color.blue : Color.gray)
          .foregroundColor(.white)
          .cornerRadius(10)
        }
        .disabled(!viewModel.canSendEmailOtp)
        .opacity(viewModel.canSendEmailOtp ? 1 : 0.6)
      } else {
        labeledField(
          title: "OTP Code",
          placeholder: "123456",
          text: $viewModel.turnkeyOtpCode
        )

        Button {
          hideKeyboard()
          Task { await viewModel.verifyTurnkeyEmailOtp() }
        } label: {
          HStack {
            if viewModel.isProcessingTurnkeyOtp {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
              Image(systemName: "checkmark.shield.fill")
            }
            Text("Verify OTP & Connect")
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .background(viewModel.canVerifyEmailOtp ? Color.green : Color.gray)
          .foregroundColor(.white)
          .cornerRadius(10)
        }
        .disabled(!viewModel.canVerifyEmailOtp)
        .opacity(viewModel.canVerifyEmailOtp ? 1 : 0.6)

        Button("Use a different email") {
          viewModel.cancelTurnkeyEmailOtp()
        }
        .font(.caption)
        .foregroundColor(.secondary)
      }

      Text("Email OTP handles login vs. sign up automatically; sign up provisions an EVM + Solana wallet.")
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }

  /// Get the key UIWindow to use as the ASPresentationAnchor for passkey UI.
  private func currentPresentationAnchor() -> ASPresentationAnchor? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }

  private func labeledField(
    title: String,
    placeholder: String,
    text: Binding<String>
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline)
        .foregroundColor(.secondary)

      TextField(placeholder, text: text)
        .textFieldStyle(.roundedBorder)
        .autocapitalization(.none)
        .disableAutocorrection(true)
    }
  }

  // MARK: - Actions Section
  
  private var actionsSection: some View {
    VStack(spacing: 12) {
      // Initialize Button — hidden when Turnkey is selected (its own passkey buttons handle init)
      if viewModel.useWalletAgnostic || viewModel.selectedProvider != .turnkey {
        Button(action: {
          hideKeyboard()
          Task {
            await viewModel.initializeSDK()
          }
        }) {
          HStack {
            if viewModel.isInitializing {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
              Image(systemName: viewModel.isInitialized ? "checkmark.circle.fill" : "play.circle.fill")
            }

            Text(initializeButtonTitle)
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(viewModel.isInitialized ? Color.orange : Color.blue)
          .foregroundColor(.white)
          .cornerRadius(12)
        }
        .disabled(!viewModel.canInitialize)
        .opacity(viewModel.canInitialize ? 1 : 0.6)
      }
      
      // Reset Button
      if viewModel.isInitialized {
        Button(action: {
          hideKeyboard()
          viewModel.resetSDK()
        }) {
          HStack {
            Image(systemName: "arrow.counterclockwise")
            Text("Reset SDK")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.red)
          .foregroundColor(.white)
          .cornerRadius(12)
        }
      }
    }
  }
  
  // MARK: - Future Features Section
  
  private var futureFeaturesSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("SDK Features")
        .font(.headline)
      
      if viewModel.isInitialized {
        VStack(spacing: 8) {
          NavigationLink(destination: BuildEIP712MessageDemoView()) {
            featureButtonContent(
              icon: "doc.text.fill",
              title: "Build EIP-712 Message",
              subtitle: "Generate EIP-712 messages for admin signatures"
            )
          }
          .buttonStyle(.plain)
          
          NavigationLink(destination: BuildWithdrawTransactionDemoView()) {
            featureButtonContent(
              icon: "arrow.down.circle.fill",
              title: "Build Withdraw Transaction",
              subtitle: "Generate withdrawal transaction calldata"
            )
          }
          .buttonStyle(.plain)
          
          if !viewModel.useWalletAgnostic {
            NavigationLink(destination: WalletAddressDemoView()) {
              featureButtonContent(
                icon: "person.crop.circle.fill",
                title: "Wallet Address & QR",
                subtitle: "Get wallet address and generate QR code"
              )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: GetBalancesDemoView()) {
              featureButtonContent(
                icon: "dollarsign.circle.fill",
                title: "Get Balances",
                subtitle: "Fetch native and ERC-20 balances"
              )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: GetTransactionsDemoView()) {
              featureButtonContent(
                icon: "list.bullet.rectangle.fill",
                title: "Get Transactions",
                subtitle: "Fetch transaction history"
              )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: TransferDemoView()) {
              featureButtonContent(
                icon: "arrow.right.arrow.left.circle.fill",
                title: "Transfer",
                subtitle: "Send native or ERC-20 (Portal or Turnkey)"
              )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: CollateralWithdrawEntryView()) {
              featureButtonContent(
                icon: "wallet.pass.fill",
                title: "Collateral Withdraw",
                subtitle: "Execute withdrawal via the active wallet provider (sign & submit)"
              )
            }
            .buttonStyle(.plain)
          }
        }
      } else {
        Text("Initialize SDK to access features")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding()
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  private var initializeButtonTitle: String {
    viewModel.isInitialized ? "Reinitialize" : "Initialize SDK"
  }

  // MARK: - Helper Views
  
  private func featureButtonContent(
    icon: String,
    title: String,
    subtitle: String
  ) -> some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(.blue)
        .frame(width: 40)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.body)
          .fontWeight(.medium)
        
        Text(subtitle)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      Image(systemName: "chevron.right")
        .foregroundColor(.secondary)
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(8)
  }
  
  private func featureButton(
    icon: String,
    title: String,
    subtitle: String,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      featureButtonContent(icon: icon, title: title, subtitle: subtitle)
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  SDKConnectionView()
}
