import Foundation

public enum LiquidityDateFormatter: String, CaseIterable {
  case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZ"
  case iso8601WithTimeZone = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
  case iso8601WithMilliseconds = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
  case shortTransactionDate = "MMM d 'at' h:mm a"
  case fullTransactionDate = "MMMM d, yyyy 'at' h:mm a"
  case fullReceiptDateTime = "d MMM, yyyy, HH:mm:ss"
  case simpleDate = "yyyy-MM-dd"
  case invertedDate = "yyyy-dd-MM"
  case yearOnly = "yyyy"
  case yearMonth = "yyyy/MM"
  case fullMonthYear = "MMMM yyyy"
  case monthDayAbbrev = "MMM dd"
  case monthDayYearAbbrev = "MMM dd, yyyy"
  case monthYearAbbrev = "MMM, yyyy"
  case chartGridDateTime = "yyyy.dd.MM hh:mm"
  case textFieldDate = "MM / dd / yyyy"
  case hour = "HH:mm"
  case periodSeparated = "yyyy.MM.dd"
  case timeStandard = "h:mma"
  case transactionDateTime = "MMM dd, yyyy | h:mm a"
  case dayMonthYearTimeWithAt = "d MMMM, yyyy 'at' h:mm a"
  case dayMonthYear = "d MMMM, yyyy"
  
  public var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = rawValue
    formatter.locale = Locale.current
    return formatter
  }
  
  public func parseToDate(from dateString: String) -> Date? {
    dateFormatter.date(from: dateString)
  }
  
  public func parseToString(from date: Date) -> String {
    dateFormatter.string(from: date)
  }
  
  public static func getDateFormat(from dateString: String) -> LiquidityDateFormatter? {
    allCases.first { $0.parseToDate(from: dateString) != nil }
  }
}
