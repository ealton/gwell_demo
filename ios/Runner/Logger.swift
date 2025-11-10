import Foundation

class Logger {
    
    static var isDebug = true
    
    static func debug(content: String) {
        if isDebug {
            NSLog("ETI debug: \(content)")
        }
    }
    
    static func info(content: String) {
        NSLog("ETI info: \(content)")
    }
    
    static func error(content: String) {
        NSLog("ETI error: \(content)")
    }
}
