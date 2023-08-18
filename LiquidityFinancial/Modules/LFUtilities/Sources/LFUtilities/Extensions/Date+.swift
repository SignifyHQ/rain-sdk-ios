import Foundation

public extension Date {
  func getDateString() -> String {
    DateFormatter.yearMonthDay.string(from: self)
  }

  var asServerDate: String {
    DateFormatter.server.string(from: self)
  }
  
  func netspendDate() -> String {
    DateFormatter.yearDayMonth.string(from: self)
  }
  
  var displayDate: String {
    DateFormatter.monthDayDisplay.string(from: self)
  }
}

public extension DateFormatter {
  /// A formatter following the server representation (`"yyyy-MM-dd'T'HH:mm:ss'Z'"`) and UTC timezone.
  static var server: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter
  }()

  /// A formatter used to represent dates with the display representation of its month (short), day and time.
  /// Example: `Oct 20 at 04:06 PM`
  static var transactionDisplayShort: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd 'at' hh:mm a"
    return formatter
  }()

  /// A formatter used to represent dates with the display representation of its month (short), year, day and time.
  /// Example: `Oct 20 2022 at 04:06 PM`
  static var transactionDisplayFull: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd yyyy 'at' hh:mm a"
    return formatter
  }()

  /// A formatter used to represent dates with the numeric representation of its year, month and day.
  /// Example: `2022-10-20`.
  static var yearMonthDay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
  
  /// A formatter used to represent dates with the numeric representation of its year, month and day.
  /// Example: `2022-10-20`.
  static var yearDayMonth: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-dd-MM"
    return formatter
  }()

  /// A formatter used to represent dates with the numeric representation of its year.
  /// Example: `2022`
  static var year: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter
  }()

  /// A formatter used to represent dates with the numeric representation of its year and month.
  /// Example: `2022/10`
  static var yearMonth: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM"
    return formatter
  }()

  /// A formatter used to represent dates with the display representation of its month and year.
  /// Example: `October 2022`
  static var monthYearDisplay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
  }()

  /// A formatter used to represent dates with the display representation of its month and day.
  /// Example: `Oct 18`
  static var monthDayDisplay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    return formatter
  }()

  /// A formatter used to represent dates with the display representation of its month, day and year.
  /// Example: `Oct 18, 2023`
  static var monthDayYearDisplay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd, yyyy"
    return formatter
  }()

  /// A formatter used for chart titles with the display representation of its month, day, year, hour and minute
  /// Example: `Oct 18, 2023 23:44`
  static var chartGridDisplay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.dd.MM hh:mm"
    return formatter
  }()
  
  static var textField: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM / dd / yyyy"
    return formatter
  }()
}
