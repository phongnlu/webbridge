//
//  WebBridgeUtil.swift
//

import Foundation

public class WebBridgeUtil {
    static func log<T>(_ object: T, filename: String = #file, line: Int = #line, funcname: String = #function) {
        if WebBridge.enableLogging {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss:SSS"
            let process = ProcessInfo.processInfo
            let threadId = "."
            
            NSLog("%@", "\(dateFormatter.string(from: Date())) \(process.processName))[\(process.processIdentifier):\(threadId)] \((filename as NSString).lastPathComponent)(\(line)) \(funcname):\r\t\(object)\n")
        }
    }
}

extension String {
    func encodeUrl() -> String? {
        if let str = self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            return str
        } else {
            return nil
        }
        
    }
    
    func decodeUrl() -> String? {
        if let str = self.removingPercentEncoding {
            return str
        } else {
            return nil
        }
    }    
}
