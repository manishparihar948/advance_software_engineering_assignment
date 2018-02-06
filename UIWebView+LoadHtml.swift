//
//  UIWebView+LoadHtml.swift
//  PocketFriend
//
//  Created by Manish Parihar on 16/12/16.
//

import Foundation
extension UIWebView {
    
    func loadHTMLStringInWebView(strHTML:String) {
        
        // code to create the cropped circle with colored border
        let htmlString = "<html>\n<head>\n<style type=\"text/css\">\nbody {font-family: \"Helvetica-Neue\"; font-size: 17;}\n</style> \n</head> \n<body>\(strHTML)</body>\n</html>"
        self.loadHTMLString(htmlString, baseURL: nil)
    }
}
