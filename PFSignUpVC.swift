//
//  PFSignUpVC.swift
//  PocketFriend
//
//  Created by Manish Parihar on 20/10/16.
//

import UIKit


class PFSignUpVC: BaseViewController,UIGestureRecognizerDelegate, FBSDKLoginButtonDelegate,UITextFieldDelegate {
    
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //<#code#>
    }
    
    
//    @IBOutlet weak var firstNameField : UITextField!
//    @IBOutlet weak var lastNameField : UITextField!
    @IBOutlet weak var nameField : UITextField!
    @IBOutlet weak var dobField  : UITextField!
    @IBOutlet weak var cityField : UITextField!
    @IBOutlet weak var tfBackgroundView : UIView!
    @IBOutlet weak var segmentButton : UISegmentedControl!
    var  datePicker : UIDatePicker!
    
    var GenderString : String = String()
    var dateString : String = String()
    
    // Button Facebook
    @IBOutlet var btnFacebook: FBSDKLoginButton!
    var fbFirstNameString : String = String()
    var fbLastNameString : String = String()
    var fbEmailString : String = String()
    var fbProfilePicString : String = String()
    var fbTokenString : String = String()
    
    
    var resultDate : String = String()
    var resultTime : String = String()
    
    var deviceUUID : String = String()
    
        //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.screenDesigningOfSignUpVC()
    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Screen Designing Methods
    func screenDesigningOfSignUpVC() {
        
        self.rightHeaderButton.isHidden=true
        // Date
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        resultDate = formatter.string(from: date)
        print(resultDate)
        
        // Time
        let formatterTime = DateFormatter()
        formatterTime.dateFormat = "HH:MM"
        resultTime = formatterTime.string(from: date)
        print(resultTime)
        
        // Device ID
        deviceUUID = (UIDevice.current.identifierForVendor?.uuidString)!
        print(deviceUUID)
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect (x:0, y: 0, width:self.view.frame.size.width,height:216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        dobField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(PFSignUpVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(PFSignUpVC.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        dobField.inputAccessoryView = toolBar
        
        // Tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        // Facebook
        self.configureFacebook()
    }
    // Keyboard Dismiss
    func dismissKeyboard(sender: UITapGestureRecognizer? = nil)
    {
        // return keyboard
        
        nameField.resignFirstResponder()
        
        //firstNameField.resignFirstResponder()
        
        //lastNameField.resignFirstResponder()
        
        dobField.resignFirstResponder()
        
        cityField.resignFirstResponder()
    }
    
    // MARK: - Button Action
    func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        // dateFormatter1.timeStyle = .NoStyle
        dobField.text = dateFormatter1.string(from: datePicker.date)
        dateString = dobField.text!
        print(dateString)
        dobField.resignFirstResponder()
    }
    // MARK: - Keyboard Dismiss
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        nextTextFieldToFirstResponder(textField: textField)
        
        return true;
    }
    
    func nextTextFieldToFirstResponder(textField: UITextField)
    {
        /*
        if textField == firstNameField {
            self.lastNameField.becomeFirstResponder()
        }else if textField == lastNameField{
            self.dobField.becomeFirstResponder()
        }
        */
        if textField == nameField{
            self.dobField.becomeFirstResponder()
        }
        else if textField == self.cityField{
            cityField.resignFirstResponder()
        }else {
            // self.textField.becomeFirstResponder()
        }
    }
    
   
    
    // MARK: - Animate TextField
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        animateViewMoving(up: true, moveValue: 100)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        animateViewMoving(up: false, moveValue: 100)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat)
    {
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.tfBackgroundView.frame = self.tfBackgroundView.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    func cancelClick() {
        
        dobField.resignFirstResponder()
        
        cityField.becomeFirstResponder()
    }
    
    // MARK: -  Facebook
    func configureFacebook()
    {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.web //Without safari Browser
        btnFacebook.readPermissions = ["public_profile", "email", "user_friends"];
        btnFacebook.delegate = self
    }
    
    // MARK: FBSDKLoginButtonDelegate Methods
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
       // let fbAccessToken = FBSDKAccessToken.current().tokenString
        
       // print(fbAccessToken)
        
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, email, picture.type(large)"]).start
            {
                (connection, result, error) -> Void in
                
                print(result)
                if let dic = result as? [String: Any]
                {
                    self.fbFirstNameString = (dic["first_name"] as? String)!
                    print(self.fbFirstNameString)
                    self.fbLastNameString  = (dic["last_name"] as? String)!
                    print(self.fbLastNameString)
                    
                    // Display name
                    //self.lblName.text = "Welcome, \(strFirstName) \(strLastName)"
                    self.fbEmailString = (dic["email"] as? String)!
                    print(self.fbEmailString)
                    
                    self.fbProfilePicString = (dic["id"] as? String)!
                    let url = NSURL(string: "https://graph.facebook.com/\(self.fbProfilePicString)/picture?type=large&return_ssl_resources=1")
                    print(url)
                    
                    // Show Imaeg
                    //self.ivUserProfileImage.image = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
                    
                    /*
                    let city = (dic["user_location"] as? String)!
                    print(city)
                    
                    let bday = (dic["user_birthday"] as? String)!
                    print(bday)
                     */
                    
//                    if(self.fbFirstNameString != nil)
//                    {
//                        
                        // User Information Dictionary & Saving Procedure
                        let userInfo : PFUserInfo = PFUserInfo()
                        userInfo.Name = self.fbFirstNameString
                        userInfo.LastName = self.fbLastNameString
                        userInfo.DOB  = self.dateString
                       // userInfo.City = "Boston"
                        userInfo.Gender = "Male"
                        userInfo.DeviceID = self.deviceUUID
                        userInfo.Date = self.resultDate
                        userInfo.Time = self.resultTime
                        
                        let isInserted = PFModelManager.getInstance().addUserFormData(userInfo)
                        
                        if isInserted
                        {
                            
                             self.navigateToChatpage()
                            
                        } else {
                            
                            
                            PFUtility.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
                        }
                   // }
                    
                }
                
        }
    }
    
    // MARK: - Time
    func getTime() -> (hour:Int, min:Int, sec:Int) {
        let date = NSDate()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date as Date)
        let minutes = calendar.component(.minute, from: date as Date)
        let seconds = calendar.component(.second, from: date as Date)
        print("hours = \(hour):\(minutes):\(seconds)")
        return (hour,minutes,seconds)
    }
    
    // MARK: -  Segment Button
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentButton.selectedSegmentIndex {
        case 0:
            GenderString = "Male"
            print(GenderString)
            
        case 1:
            GenderString = "Female"
            print(GenderString)
        case 2:
            GenderString = "Other"
            print(GenderString)
            
        default:
            break;
        }
    }
    
    // MARK: - Save User Registration
    @IBAction func btnSaveUserRegistration(_ sender: AnyObject)
    {
        self.dismissKeyboard()
//        if (firstNameField.text == "")
//        {
//            PFUtility.invokeAlertMethod("", strBody: "Please enter first name.", delegate: nil)
//        }
//        else if (lastNameField.text == "")
//        {
//            PFUtility.invokeAlertMethod("", strBody: "Please enter last name.", delegate: nil)
//        }
        if (nameField.text == "")
        {
                    PFUtility.invokeAlertMethod("", strBody: "Please enter name.", delegate: nil)
        }
        else if (dobField.text == "")
        {
            PFUtility.invokeAlertMethod("", strBody: "Please select value from picker", delegate: nil)
        }
//        else  if (cityField.text == "")
//        {
//             PFUtility.invokeAlertMethod("", strBody: "Please enter city.", delegate: nil)
//        }
        else  if (GenderString == "")
        {
            PFUtility.invokeAlertMethod("", strBody: "Please select gender.", delegate: nil)
        }
        else
        {
          
            // User Information Dictionary & Saving Procedure
            let userInfo : PFUserInfo = PFUserInfo()
//            userInfo.FirstName = firstNameField.text!
//            userInfo.LastName = lastNameField.text!
            userInfo.Name = nameField.text!
            userInfo.DOB  = dateString
            //userInfo.City = cityField.text!
            userInfo.Gender = GenderString
            userInfo.DeviceID = deviceUUID
            userInfo.Date = resultDate
            userInfo.Time = resultTime
            
            let isInserted = PFModelManager.getInstance().addUserFormData(userInfo)
            
            if isInserted
            {
//                // Save Username in UserDefaults
//                let defaults = UserDefaults.standard
//                
//                defaults.set(userInfo.Name, forKey: "userNameKey")
                
                // PFUtility.invokeAlertMethod("", strBody: "Record Inserted successfully.", delegate: nil)
                
               self.navigateToChatpage()
               
                // Go To ChatBot
               
                
            } else {
                
                
                PFUtility.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
            }
            
        }
    }
    
        func navigateToChatpage(){
            let userArray:NSArray =  PFModelManager.getInstance().fetchRegisteredUserFromDB()
            if(userArray.count != 0)
            {
                let  userInfo : PFUserInfo = userArray.object(at: 0) as! PFUserInfo
                appDelegate.userInfo = userInfo
                let initVC = self.storyboard?.instantiateViewController(withIdentifier: "PFStartVC") as! PFStartVC
                let chatViewController = self.storyboard?.instantiateViewController(withIdentifier: "PFChatVC") as! PFChatVC
                let viewControllers = [initVC,chatViewController]
                self.navigationController?.setViewControllers(viewControllers, animated: true)

        }
    }
}
