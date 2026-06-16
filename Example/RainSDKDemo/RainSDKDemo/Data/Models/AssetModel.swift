import Foundation

/// Asset type for demo (e.g. USDC, AVAX). Extend as needed.
enum AssetType: String, CaseIterable {
  case usdc
  case usdt
  case usd
  case avax
  case wavax
  case eth
  case weth
  case frnt
  case other

  init?(rawValue: String) {
    let lower = rawValue.lowercased()
    if let match = AssetType.allCases.first(where: { $0.rawValue == lower }) {
      self = match
    } else if !lower.isEmpty {
      self = .other
    } else {
      return nil
    }
  }
}

/// Demo asset model built from credit-contracts response (RainTokenEntity). Use for UI and Portal Withdraw.
struct AssetModel: Hashable, Identifiable {
  let id: String
  let type: AssetType?

  let availableBalance: Double
  let availableUsdBalance: Double?
  let exchangeRate: Double?
  let advanceRate: Double?

  let externalAccountId: String?

  /// Token decimals resolved on-chain (the Rain contracts endpoint omits them). When present,
  /// it takes precedence over the symbol-based `conversionFactor` heuristic for withdraw math.
  let resolvedDecimals: Int?

  init(
    id: String,
    type: AssetType?,
    availableBalance: Double,
    availableUsdBalance: Double?,
    exchangeRate: Double? = nil,
    advanceRate: Double? = nil,
    externalAccountId: String? = nil,
    resolvedDecimals: Int? = nil
  ) {
    self.id = id
    self.type = type
    self.availableBalance = availableBalance
    self.availableUsdBalance = availableUsdBalance
    self.exchangeRate = exchangeRate
    self.advanceRate = advanceRate
    self.externalAccountId = externalAccountId
    self.resolvedDecimals = resolvedDecimals
  }

  /// Build from RainTokenEntity (contracts response). When the entity carries resolved
  /// `decimals` (enriched on-chain), they are kept for precise withdraw math.
  init(rainCollateralAsset: RainTokenEntity) {
    self.id = rainCollateralAsset.address ?? ""
    self.type = AssetType(rawValue: rainCollateralAsset.symbol?.uppercased() ?? "")
    self.availableBalance = rainCollateralAsset.balance ?? 0
    self.availableUsdBalance = rainCollateralAsset.availableUsdBalance
    self.exchangeRate = (rainCollateralAsset.exchangeRate ?? 0) != 0 ? ((rainCollateralAsset.exchangeRate ?? 0) * 100).rounded() / 100 : nil
    self.advanceRate = rainCollateralAsset.advanceRate
    self.externalAccountId = nil
    self.resolvedDecimals = rainCollateralAsset.decimals.map { Int($0) }
  }
}

// MARK: - Conversion & formatting (demo)

extension AssetModel {
  var conversionFactor: Int {
    // Prefer on-chain–resolved decimals; fall back to the symbol-based heuristic.
    if let resolvedDecimals { return resolvedDecimals }
    switch type {
    case .usdc, .usdt:
      return 6
    case .avax, .wavax, .eth, .weth:
      return 18
    default:
      return 2
    }
  }

  var hasExchangeRate: Bool {
    (exchangeRate ?? 1) != 1
  }

  var hasAdvanceRate: Bool {
    (advanceRate ?? 100) != 100
  }

  var availableBalanceFormatted: String {
    formatBalance(availableBalance, isFiat: type == .usd)
  }

  var totalUsdBalanceFormatted: String? {
    let usdValue = availableBalance * (exchangeRate ?? 1)
    return formatUSD(usdValue)
  }

  var availableToSpendUsdBalanceFormatted: String? {
    let usdValue = availableBalance * (exchangeRate ?? 1) * (advanceRate ?? 100) / 100
    return formatUSD(usdValue)
  }

  var exchangeRateFormatted: String {
    guard let rate = exchangeRate else { return "N/A" }
    return String(format: "%.2f", rate)
  }

  var advanceRateFormatted: String {
    guard let rate = advanceRate else { return "N/A" }
    return String(format: "%.0f%%", rate)
  }
}

// MARK: - Helpers

private func formatBalance(_ value: Double, isFiat: Bool) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.minimumFractionDigits = isFiat ? 2 : 4
  formatter.maximumFractionDigits = isFiat ? 2 : 8
  return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

private func formatUSD(_ value: Double) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.minimumFractionDigits = 2
  formatter.maximumFractionDigits = 2
  let s = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
  return "$\(s)"
}
