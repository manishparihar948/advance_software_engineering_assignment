//
//  PFSendMailVC.swift
//  PocketFriend
//
//  Created by Manish Parihar on 08/12/16.
//

import UIKit

class PFSendMailVC: BaseViewController,PFShareDelegate {

    @IBOutlet weak var txtField: UITextField!
     let pfShare:PFShare = PFShare()
    
    @IBOutlet weak var lblMessage: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
rightHeaderButton.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendClicked(_ sender: UIButton) {
        appDelegate.addLoadingView()
        lblMessage.text = ""
        txtField.resignFirstResponder()
        pfShare.delegate=self
        let defaults = UserDefaults.standard
        let syncRowID = defaults.integer(forKey: lastSyncRowID)
        let CSVString:String = PFModelManager.getInstance().getCompleteUserData(userID: appDelegate.userInfo.UserID,afterID:syncRowID)
        let data:Data = CSVString.data(using: .utf8)!
        let subject = "Details of user : \(appDelegate.userInfo.Name)"
        let body = "Hello Admin,\n\nPlease find the attached csv file of the user: \n\nName: \(appDelegate.userInfo.Name)\n\n"
        pfShare.sendMailUsingSMTP(subject: subject, from: "sandhya.banshal@epictenet.com", to: "soniya.vishwakarma@epictenet.com", bcc: "", cc: "", body: body, attachment:data , attachmentContentType: PFShare.ContentType.CSVType, fileName: "userDetail.csv", isHTML: false, hasAttachment: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func mailSentUsingSMTPSuccessfully(success:Bool,message:String){
        appDelegate.removeLoadingView()
        lblMessage.text = message
        if success{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GlobalSwift.dateStandardFormat()
        let date:String = dateFormatter.string(from: Date())
        let rowID = PFModelManager.getInstance().getLastRowID(userID: appDelegate.userInfo.UserID)
        let defaults = UserDefaults.standard
        defaults.set(date, forKey: lastSyncDateTime)
        defaults.set(rowID, forKey: lastSyncRowID)
        }
//        if success{
//            print(message)
//        }
    }

}
