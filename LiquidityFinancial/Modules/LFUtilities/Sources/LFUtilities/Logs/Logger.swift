import SwiftyBeaver

public let log: SwiftyBeaver.Type = {
  let log = SwiftyBeaver.self

  let console = ConsoleDestination()  // log to Xcode Console
  console.format = "$DHH:mm:ss$d $L $M"
  console.useTerminalColors = true
  log.addDestination(console)
  
  return log
}()
