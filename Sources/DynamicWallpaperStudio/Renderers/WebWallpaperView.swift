import AppKit
import SwiftUI
import WebKit

public struct WebWallpaperView: NSViewRepresentable {
    public let htmlContent: String?
    public let webURL: URL?
    public let isPaused: Bool
    
    public init(htmlContent: String? = nil, webURL: URL? = nil, isPaused: Bool = false) {
        self.htmlContent = htmlContent
        self.webURL = webURL
        self.isPaused = isPaused
    }
    
    public func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground") // Transparent background capability
        
        loadContent(in: webView)
        return webView
    }
    
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        if isPaused {
            // Freeze animations on pause for 0% CPU
            nsView.evaluateJavaScript("if (window.pauseAnimation) window.pauseAnimation(); document.body.style.display = 'none';", completionHandler: nil)
        } else {
            nsView.evaluateJavaScript("if (window.resumeAnimation) window.resumeAnimation(); document.body.style.display = 'block';", completionHandler: nil)
        }
    }
    
    private func loadContent(in webView: WKWebView) {
        if let html = htmlContent {
            webView.loadHTMLString(html, baseURL: nil)
        } else if let url = webURL {
            webView.load(URLRequest(url: url))
        }
    }
}
