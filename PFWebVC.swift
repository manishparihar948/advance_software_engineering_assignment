//
//  PFWebVC.swift
//  PocketFriend
//
//  Created by Manish Parihar on 16/11/16.
//

import UIKit

class PFWebVC: BaseViewController, UIWebViewDelegate {

    var urlString : String = String()

    var urlRequest : NSURLRequest = NSURLRequest()
    
    @IBOutlet var webView: UIWebView!
    
    @IBOutlet var activity: UIActivityIndicatorView!

         //MARK: - View Controller Life Cycle Methods

    override func viewDidLoad() {

        super.viewDidLoad()
        self.screenDesigningOfWebVC()
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Screen Designing Methods
    
    func screenDesigningOfWebVC(){
        rightHeaderButton.isHidden = true
        self.webView.loadRequest(urlRequest as URLRequest)
    }
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        activity.startAnimating()
//        return true
//    }
    
     //MARK: - WebViewDelegate Methods
    func webViewDidStartLoad(_ webView: UIWebView) {
        activity.startAnimating()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activity.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activity.stopAnimating()
    }
    
   
}
