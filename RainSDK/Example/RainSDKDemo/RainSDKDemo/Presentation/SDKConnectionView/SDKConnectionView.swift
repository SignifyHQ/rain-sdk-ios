import SwiftUI
import RainSDK

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
      
      Text("Connect to Portal Wallet SDK")
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
        // Portal Token Input
        VStack(alignment: .leading, spacing: 8) {
          Text("Portal Session Token")
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          TextField("Enter Portal token", text: $viewModel.portalToken)
            .textFieldStyle(.roundedBorder)
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }
      }
      
      // Chain ID Input
      VStack(alignment: .leading, spacing: 8) {
        Text("Chain ID")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        TextField("e.g., 1 (Ethereum), 137 (Polygon)", text: $viewModel.chainId)
          .textFieldStyle(.roundedBorder)
          .keyboardType(.numberPad)
      }
      
      // RPC URL Input
      VStack(alignment: .leading, spacing: 8) {
        Text("RPC URL")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        TextField("Enter RPC endpoint URL", text: $viewModel.rpcUrl)
          .textFieldStyle(.roundedBorder)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  // MARK: - Actions Section
  
  private var actionsSection: some View {
    VStack(spacing: 12) {
      // Initialize Button
      Button(action: {
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
          
          Text(viewModel.isInitialized ? "Reinitialize" : "Initialize SDK")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.isInitialized ? Color.orange : Color.blue)
        .foregroundColor(.white)
        .cornerRadius(12)
      }
      .disabled(!viewModel.canInitialize)
      .opacity(viewModel.canInitialize ? 1 : 0.6)
      
      // Reset Button
      if viewModel.isInitialized {
        Button(action: {
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
            NavigationLink(destination: PortalWithdrawEntryView()) {
              featureButtonContent(
                icon: "wallet.pass.fill",
                title: "Portal Withdraw",
                subtitle: "Execute withdrawal via Portal (sign & submit)"
              )
            }
            .buttonStyle(.plain)
          }
          
          if !viewModel.useWalletAgnostic {
            featureButton(
              icon: "wallet.pass.fill",
              title: "Portal Wallet Features",
              subtitle: "Access Portal wallet functionality",
              action: {
                viewModel.handlePortalWalletFeatures()
              }
            )
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
