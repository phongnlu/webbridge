//
// WebBridgeDelegate.swift
//

import Foundation
import WebKit
import SwiftyJSON

public class WebBridgeDelegate: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    fileprivate let requestEventKey = "event"
    fileprivate let requestContextKey = "context"
    fileprivate let requestPayloadKey = "payload"
    fileprivate let nativeToWeb = "WebBridge.nativeToWeb"
    
    fileprivate var webView: WKWebView
    
    public init(_ webView: WKWebView) {
        self.webView = webView
        
        super.init()
        
        let userContentController = self.webView.configuration.userContentController
        //inject js to native bridge
        userContentController.add(self, name: "nativeManager")
        
        //add observer to monitor webview progress
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        WebBridgeUtil.log("webview - didFailNavigation url: \(webView.url), error: \(error)")
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation: WKNavigation) {
        let ts = Double(NSDate().timeIntervalSince1970)
        let dataToSend = ts
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didStartProvisionalNavigation"), object: dataToSend)
        WebBridgeUtil.log("webview - didStartProvisionalNavigation url: \(webView.url)")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        WebBridgeUtil.log("webview - didFinishNavigation url: \(webView.url)")
        if let url = webView.url?.absoluteString {
            //TODO: phongtest
            //didFinishLoad(url)
        }
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        WebBridgeUtil.log("webview - didFailProvisionalNavigation url: \(webView.url), error: \(error)")
        //TODO: phongtest
        //didFailLoad(error)
    }
    
    // this handles target=_blank links by opening them in the same view
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        WebBridgeUtil.log("webView - createWebViewWith configuration url: \(webView.url)")
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = webView.estimatedProgress
            //TODO: phongtest
            //onProgressChanged(progress)
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        WebBridgeUtil.log("userContentController called");
        
        if (message.name == "nativeManager") {
            WebBridgeUtil.log("postMessageHandler payload: \(message.body)")
            if let body = message.body as? String,
                let jsonFromString = body.data(using: .utf8, allowLossyConversion: false) {
                var json = JSON.null
                do {
                    json = try JSON(data: jsonFromString)
                } catch _ {
                    WebBridgeUtil.log("cannot convert to JSON object from JSON string");
                }
                let context = json[requestContextKey].stringValue
                let event = json[requestEventKey].stringValue
                let payload = json[requestPayloadKey]
                
                
                //invoke eventProcessor
                
                //send data back to web
                /*var dict = Dictionary<String, Any?>()
                var dataDict = Dictionary<String, Any?>()
                dict["data"] = dataDict
                let json = JSON(dict)
                sendDataBackToWeb(json)*/
            } else {
                WebBridgeUtil.log("postMessageHandler sends invalid payload")
            }
        }
    }
    
    fileprivate func sendDataBackToWeb(_ json: JSON) {
        //TODO: phongtest
        //sendDataBackToWebDidStart()
        let data = "\(nativeToWeb)(\(json))"
        WebBridgeUtil.log("Data to send back to CCT: \(data)")
        if let dataStr = data.decodeUrl() {
            webView.evaluateJavaScript(dataStr, completionHandler: { [weak self] (result, error) in
                if let ss = self {
                    if let error = error {
                        WebBridgeUtil.log("webview - evaluateJavaScript error: \(error)");
                        //TODO: phongtest
                        //ss.sendDataBackToWebDidFail()
                    }
                    WebBridgeUtil.log("webview - evaluateJavaScript result: \(result)")
                    //TODO: phongtest
                    //ss.sendDataBackToWebDidFinish()
                } else {
                    WebBridgeUtil.log("self had been deallocated");
                    //TODO: phongtest
                    //self?.sendDataBackToWebDidFail()
                }
                
            })
        } else {
            WebBridgeUtil.log("Cannot url decode data to send back to CCT, data to decode: \(data)")
            //TODO: phongtest
            //sendDataBackToWebDidFail()
        }
    }
}
