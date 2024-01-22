import Foundation

struct RemainingAvailableAmount {
  let day: Double
  let week: Double
  let month: Double
  
  static let `default` = RemainingAvailableAmount(from: [])
  
  init(from entities: [TransferLimitConfig]) {
    let dayLimitConfig = entities.first { $0.period == .day }
    let weekLimitConfig = entities.first { $0.period == .week }
    let monthLimitConfig = entities.first { $0.period == .month }
    
    day = (dayLimitConfig?.amount ?? 0) - (dayLimitConfig?.transferredAmount ?? 0)
    week = (weekLimitConfig?.amount ?? 0) - (weekLimitConfig?.transferredAmount ?? 0)
    month = (monthLimitConfig?.amount ?? 0) - (monthLimitConfig?.transferredAmount ?? 0)
  }
}
