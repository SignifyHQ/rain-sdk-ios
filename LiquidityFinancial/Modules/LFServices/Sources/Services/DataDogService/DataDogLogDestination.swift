import DatadogLogs
import SwiftyBeaver
import LFUtilities
import UIKit

class DataDogLogDestination: BaseDestination {
  private lazy var logger: LoggerProtocol = {
    let ddLogger = Logger.create(
        with: Logger.Configuration(
            name: "ios-liquidity-logger-new-\(LFUtilities.target?.rawValue.lowercased() ?? "")",
            networkInfoEnabled: true,
            remoteLogThreshold: .info
        )
    )

    ddLogger.addAttribute(forKey: "device-model", value: UIDevice.current.model)

    #if DEBUG
    ddLogger.addTag(withKey: "build_configuration", value: "debug")
    #else
    ddLogger.addTag(withKey: "build_configuration", value: "release")
    #endif
    return ddLogger
  }()

  public override var defaultHashValue: Int { 100 }

  override func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any? = nil) -> String? {
    switch level {
    case .verbose:
      logger.notice("[FILE:\(file)]-[MESSAGE:\(msg)] ", attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": function])
    case .debug:
      logger.debug("[FILE:\(file)]-[MESSAGE:\(msg)] ", attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": function])
    case .info:
      logger.info("[FILE:\(file)]-[MESSAGE:\(msg)] ", attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": function])
    case .warning:
      logger.warn("[FILE:\(file)]-[MESSAGE:\(msg)] ", attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": function])
    case .error:
      logger.error("[FILE:\(file)]-[MESSAGE:\(msg)] ", attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": function])
    }
    return super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)
  }
}
