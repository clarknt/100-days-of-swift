//
//  DetailViewController.swift
//  Project9
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    var webView: WKWebView!
    var detailItem: Petition?

    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let detailItem = detailItem else {
            return
        }
        
        let html = """
            <html>
                <head>
                    <meta name="viewport" content="width=device-width", initial-scale=1">
                    <style> body { font-size: 130%; } </style>
                </head>
                <body>
                    <h2>\(detailItem.title)</h2>
                    \(detailItem.body)
                </body>
            </html>
            """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
}
