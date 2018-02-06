//
//  PFSyncData.swift
//  PocketFriend
//
//  Created by Manish Parihar on 14/12/16.
//

import UIKit
let lastSyncRowID:String = "lastSyncRowID"
let lastSyncDateTime:String = "LastSyncDateTime"
class PFSyncData: NSObject,PFShareDelegate {
   
    var userId:NSInteger = 0
let pfShare:PFShare = PFShare()
    
    func syncData(userID:NSInteger){
        if userID != 0 {
            userId=userID
            let defaults = UserDefaults.standard
            let lastSyncDate:String? =  defaults.string(forKey: lastSyncDateTime)
            
            if let syncDate: String = lastSyncDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = GlobalSwift.dateStandardFormat()
            let date:Date = dateFormatter.date(from: syncDate)!
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                //Open for testing
//            let calendar = NSCalendar.autoupdatingCurrent
//            if calendar.isDateInYesterday(date) {
                
                //For local testing
                let today = Date()
                let timeInterval = today.timeIntervalSince(date)
                let diff=timeInterval/60;
                if (diff>=10){
                // It was yesterday...
                //convert to day now in minutes for testing
                let syncRowID = defaults.integer(forKey: lastSyncRowID)
                let CSVString:String = PFModelManager.getInstance().getCompleteUserData(userID: userId,afterID:syncRowID)
                
                pfShare.delegate=self
                
                let data:Data = CSVString.data(using: .utf8)!
                
                let subject = "Details of user : \(appDelegate.userInfo.Name)"
                let body = "Hello Admin,\n\nPlease find the attached csv file of the user: \n\nName: \(appDelegate.userInfo.Name)\n\n"
             pfShare.sendMailUsingSMTP(subject: subject, from: "soniya.vishwakarma@epictenet.com", to: "manish.parihar948@gmail.com", bcc: "manishparihar948@me.com", cc: "ammy.jackmann@gmail.com", body: body, attachment:data , attachmentContentType: PFShare.ContentType.CSVType, fileName: "userDetail.csv", isHTML: false, hasAttachment: true)
            }
        }
    }
    }
    func mailSentUsingSMTPSuccessfully(success:Bool,message:String){
        if success{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GlobalSwift.dateStandardFormat()
        let date:String = dateFormatter.string(from: Date())
        let rowID = PFModelManager.getInstance().getLastRowID(userID: userId)
        let defaults = UserDefaults.standard
        defaults.set(date, forKey: lastSyncDateTime)
        defaults.set(rowID, forKey: lastSyncRowID)
        }
//        lblMessage.text = message
        //        if success{
                  print(message)
        //        }
    }
}
