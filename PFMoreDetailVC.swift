//
//  PFMoreDetailVC.swift
//  PocketFriend
//
//  Created by Manish Parihar on 02/12/16.
//

import UIKit

class PFMoreDetailVC: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    var arrDates:NSArray = NSArray()
    
    var subTrack_id   : NSInteger = 0
    var timeSpan : TimeSpan = .CurrentTimeSpan
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       arrDates = PFModelManager.getInstance().getDatesOfEmotion(subtrackID: subTrack_id, userID: appDelegate.userInfo.UserID, timeSpan: timeSpan)
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var doneButtonClicked: UIButton!

    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: nil)
        }

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK: - Table
    
   func numberOfSections(in tableView: UITableView) -> Int {
    
    let count:NSInteger = arrDates.count
        return count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let objPFDetail:PFDetailObj = arrDates.object(at: section) as! PFDetailObj

        let arr:NSArray = objPFDetail.arrDetails
        let count:NSInteger = arr.count
        return count

    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
       let objPFDetail:PFDetailObj = arrDates.object(at: section) as! PFDetailObj
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date:Date = dateFormatter.date(from: objPFDetail.dateString)!
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let string:String = dateFormatter.string(from: date)
        print(string)
        return string
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellIdentifier")
        let objPFDetail:PFDetailObj = arrDates.object(at: indexPath.section) as! PFDetailObj
        
        let arr:NSArray = objPFDetail.arrDetails
        let detailChildObj : PFEmotionSubDetailObj =  arr.object(at: indexPath.row) as! PFEmotionSubDetailObj
        cell?.textLabel?.text = detailChildObj.descriptionString
        cell?.detailTextLabel?.text = detailChildObj.timeString
        
        return cell!
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//       // self.addChoice(choice: arrItems.object(at: indexPath.row) as! String)
//        //  print("You selected cell #\(indexPath.row)!")
//    }
}
