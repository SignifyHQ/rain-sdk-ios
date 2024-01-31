import Foundation
import SolidDomain

struct MockSolidAccountLimitsEntity: SolidAccountLimitsEntity {
  var depositCardDaily: Double?
  
  var depositCardMonthly: Double?
  
  var depositAchDaily: Double?
  
  var depositAchMonthly: Double?
  
  var depositTotalDaily: Double?
  
  var depositTotalMonthly: Double?
  
  var withdrawalCardDaily: Double?
  
  var withdrawalCardMonthly: Double?
  
  var withdrawalAchDaily: Double?
  
  var withdrawalAchMonthly: Double?
  
  var withdrawalTotalDaily: Double?
  
  var withdrawalTotalMonthly: Double?
  
  static var mockData = MockSolidAccountLimitsEntity(depositTotalDaily: 10.00, depositTotalMonthly: 10.00, withdrawalTotalDaily: 10.00, withdrawalTotalMonthly: 10.00)
}
