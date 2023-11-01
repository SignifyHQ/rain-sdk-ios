import SwiftyBeaver

public let log: SwiftyBeaver.Type = {
  let log = SwiftyBeaver.self

  let console = ConsoleDestination()  // log to Xcode Console
  console.levelColor.verbose = "🟣:"
  console.levelColor.debug = "🟢:"
  console.levelColor.info = "🔵:"
  console.levelColor.warning = "🔶:"
  console.levelColor.error = "🔴:"
#if DEBUG
  console.minLevel = .verbose
#else
  console.minLevel = .error
#endif
  
#if DEBUG
  log.addDestination(console)
#endif
  
  return log
}()
