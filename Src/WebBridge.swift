//
//  WebBridge.swift
//

import Foundation
import WebKit

public class WebBridge {
    fileprivate var webView: WKWebView
    fileprivate var request: NSMutableURLRequest
    fileprivate var requestId = 0
    public static var enableLogging = true
    
    //TODO: phongtest, allows passing in list of headers
    public init(_ webView: WKWebView, url: String, userAgent: String? = nil, timeout: Double? = nil) {
        self.webView = webView
        let launchURL = URL(string: url)!
        self.request = NSMutableURLRequest(url: launchURL)
        initialize(userAgent: userAgent, timeout: timeout)
    }
    
    private func initialize(userAgent: String? = nil, timeout: Double? = nil) {
        if let timeout = timeout {
            self.request.timeoutInterval = TimeInterval(timeout)
        } else {
            self.request.timeoutInterval = TimeInterval(WebBridgeConstants.defaultTimeout)
        }
        if let userAgent = userAgent {
            request.setValue(userAgent, forHTTPHeaderField: WebBridgeConstants.userAgent)
        }
        
        deleteAllCookies()
        
        //attach consoleLogger script
        let webBridgeBundle = Bundle.init(for: WebBridge.self)
        let consoleLoggerPath = "\(webBridgeBundle.bundlePath)/WebBridge.bundle/consoleLogger.js"
        if let jsString = try? String(contentsOfFile: consoleLoggerPath, encoding: String.Encoding.utf8) {
            webView.evaluateJavaScript(jsString, completionHandler: nil)
        } else {
            WebBridgeUtil.log("Cannot read console logger with path: \(consoleLoggerPath)")
        }
    }
    
    fileprivate func deleteAllCookies() {
        var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        libraryPath += "/Cookies"
        
        do {
            let _ = try FileManager.default.removeItem(atPath: libraryPath)
            WebBridgeUtil.log("Successfully delete cookies")
        } catch {
            WebBridgeUtil.log("Cannot delete cookies")
        }
        URLCache.shared.removeAllCachedResponses()
    }
    
    public func launch() {
        webView.load(request as URLRequest)
    }
    
    public func reload() {
        webView.reload()
    }
    
    public func close() {
        webView.stopLoading()
        let request = NSMutableURLRequest(url: URL(string:"about:blank")!)
        webView.load(request as URLRequest)
    }
}
