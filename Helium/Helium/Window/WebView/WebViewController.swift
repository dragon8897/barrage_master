//
//  ViewController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa
import WebKit

class HeliumWebView: WKWebView {
    override var mouseDownCanMoveWindow: Bool {
        false
    }
}

class WebViewController: NSViewController, WKNavigationDelegate {
    
    var trackingTag: NSView.TrackingRectTag?
    
    override func loadView() {
        self.view = NSView()
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WebViewController.loadURLObject(_:)), name: NSNotification.Name(rawValue: "HeliumLoadURL"), object: nil)
        
        bind(.title, to: webView, withKeyPath: "title", options: nil)
        
        // Layout webview
//        view.addSubview(webView)

        webView.frame = view.bounds
        webView.autoresizingMask = [.width, .height]
        
        // Allow plug-ins such as silverlight
        webView.configuration.preferences.plugInsEnabled = true
        
        // Setup magic URLs
        webView.navigationDelegate = self
        
        // Allow zooming
        webView.allowsMagnification = true
        
        // Enable inspector
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

        // Alow back and forth
        webView.allowsBackForwardNavigationGestures = true
                
        if let homePage = UserSetting.homePageURL {
            loadAlmostURL(homePage)
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        if let tag = trackingTag {
            view.removeTrackingRect(tag)
        }
        
        trackingTag = view.addTrackingRect(view.bounds, owner: self, userData: nil, assumeInside: false)
    }
    
    func zoomVideo() {
        webView.evaluateJavaScript("""
            var style = document.createElement("style");
            style.appendChild(document.createTextNode(""));
            document.head.appendChild(style);
            style.sheet.insertRule(`
                video {
                    position    : fixed    !important;
                    top         : 0        !important;
                    left        : 0        !important;
                    width       : 100%     !important;
                    height      : 100%     !important;
                    max-width   : 100%     !important;
                    background  : black    !important;
                    visibility  : visible  !important;
                }
            `);
            style.sheet.insertRule(`
                :not(video):not(body) {
                    visibility  : hidden   !important;
                    overflow    : visible  !important;
                }
            `);
        """)
    }

    @objc func resetZoomLevel(_ sender: AnyObject) {
        webView.magnification = 1
    }
    @objc func zoomIn(_ sender: AnyObject) {
        webView.magnification += 0.1
    }
    @objc func zoomOut(_ sender: AnyObject) {
        webView.magnification -= 0.1
    }
    
    func loadAlmostURL(_ text: String) {
        var text = text
        if !(text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("https://")) {
            text = "http://" + text
        }
        
        if let url = URL(string: text) {
            loadURL(url)
        }
        
    }
    
    // MARK: Loading
    
    func loadURL(_ url: URL) {
//        webView.load(URLRequest(url: url))
        let y = Double.random(in: 10.0 ... 600.0)
        let textView = NSText(frame: CGRect(x: 1300.0, y: y, width: 2500.0, height: 50.0))
        let shadow: NSShadow = NSShadow()
        shadow.shadowBlurRadius = 2  // Amount of blur (in pixels) applied to the shadow.
        shadow.shadowOffset = NSMakeSize(4, 4) // the distance from the text the shadow is dropped (positive X = to the right; positive Y = below the text)
        shadow.shadowColor = NSColor.black
        textView.shadow = shadow
        textView.drawsBackground = false
        textView.font = NSFont(name: "Menlo", size: 50)
        textView.string = url.absoluteString
        view.addSubview(textView)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 10
            textView.animator().setFrameOrigin(NSPoint(x: -100, y: y))
            NSAnimationContext.endGrouping()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+13.0) {
            textView.removeFromSuperview()
        }
    }
    
    @objc func loadURLObject(_ urlObject: Notification) {
        if let url = urlObject.object as? URL {
            loadAlmostURL(url.absoluteString);
        }
    }
    
    // FIXME: Shouldn't this be private?
    var webView = HeliumWebView()
    
    // Redirect Hulu and YouTube to pop-out videos
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        if !UserSetting.disabledMagicURLs {
            print("Magic URL functionality not implemented")
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }

}

