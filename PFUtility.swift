//
//  PFUtility.swift
//  PocketFriend
//
//  Created by Manish Parihar on 20/10/16.
//

import UIKit

class PFUtility: NSObject {
    
    class func getPath(_ fileName : String) -> String
    {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        return fileURL.path
    }
    
    class func copyFile(_ fileName: NSString)
    {
        let dbPath: String = getPath(fileName as String)
        print("DB Path \(dbPath)")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath)
        {
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            
            var error : NSError?
            do
            {
                try fileManager.copyItem(atPath: fromPath.path, toPath:dbPath)
            } catch let error1 as NSError
            {
                error = error1
            }
            let alert: UIAlertView = UIAlertView()
            if (error != nil) {
                alert.title = "Error Occupied"
                alert.message = error?.localizedDescription
                alert.delegate = nil
                alert.addButton(withTitle: "Ok")
                alert.show()
                
            } else
            {
               // alert.title = "Successfully Copy"
               // alert.message = "Your database copy successfully"
                
                print("successfully copy")
            }
            /*
            alert.delegate = nil
            alert.addButton(withTitle: "Ok")
            alert.show()
             */
        }
    }
    
    class func invokeAlertMethod(_ strTitle: NSString, strBody: NSString, delegate: AnyObject?)
    {
        let alert: UIAlertView = UIAlertView()
        alert.message = strBody as String
        alert.title   = strTitle as String
        alert.delegate = delegate
        alert.addButton(withTitle: "Ok")
        alert.show()
    }
    
}
