//
//  PFInitialVC.swift
//  PocketFriend
//
//  Created by Manish Parihar on 05/12/16.
//

import UIKit

class PFInitialVC: BaseViewController {

    var customizedLaunchScreenView: UIView?
    
    var userArray   : NSMutableArray!
    
    var quoteView: UITextView = UITextView()
    var staticWelcomeLBL : UILabel = UILabel()
    var staticToLBL : UILabel = UILabel()
    var staticPocketLBL : UILabel = UILabel()
    
    var yAxis = 100;
    
     //MARK: - View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenDesigningOfInitialVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Screen Designing Methods
    func screenDesigningOfInitialVC(){
        
        headerView.isHidden = true
        staticWelcomeLBL.isHidden = true
        staticToLBL.isHidden = true
        
        // Fire Database Query for find Registered User
        userArray =  PFModelManager.getInstance().fetchRegisteredUserFromDB()
        
        // Do any additional setup after loading the view.
        self.showWindow()
        
        if(userArray.count == 0)
        {
            staticWelcomeLBL.isHidden = false
            staticToLBL.isHidden = false
            // Go to SignUp Page through Start Page
            print("Show Start Page")
        }
        else
        {
            staticWelcomeLBL.isHidden = true
            staticToLBL.isHidden = true
            
            let  userInfo : PFUserInfo = userArray.object(at: 0) as! PFUserInfo
            
            appDelegate.userInfo = userInfo
        }
            self.perform(#selector(fadeTheScreen), with: nil, afterDelay: 7)
    }
    func showWindow()
    {
        
        // Show only first time of app, user login first time
        
        // WelCome
        self.staticWelcomeLBL = UILabel(frame: CGRect (x:0, y: yAxis, width:Int(screenWidth),height:20))
        self.staticWelcomeLBL.text = "Welcome"
        self.staticWelcomeLBL.textAlignment = NSTextAlignment.center
        self.staticWelcomeLBL.font = UIFont.boldSystemFont(ofSize: 25) //UIFont(name: "HelveticaNeue", size: CGFloat(20))
        self.staticWelcomeLBL.textColor = subThemeColor
        self.view.addSubview(self.staticWelcomeLBL)
        
        yAxis = yAxis+30
        
        // To
        self.staticToLBL = UILabel(frame: CGRect (x:0, y: yAxis, width:Int(screenWidth),height:20))
        self.staticToLBL.text = "to"
        self.staticToLBL.textAlignment = NSTextAlignment.center
        self.staticToLBL.font = UIFont.boldSystemFont(ofSize: 25)//UIFont(name: "HelveticaNeue", size: CGFloat(20))
        self.staticToLBL.textColor = subThemeColor
        self.view?.addSubview(self.staticToLBL)
        
        yAxis = yAxis+30
        
        // PockectFriend
        self.staticPocketLBL = UILabel(frame: CGRect (x:0, y: yAxis, width:Int((self.view?.frame.size.width)!),height:50))
        self.staticPocketLBL.text = "Pocket Friend"
        self.staticPocketLBL.textAlignment = NSTextAlignment.center
        self.staticPocketLBL.font = UIFont.boldSystemFont(ofSize: 30)//UIFont(name: "HelveticaNeue-Bold", size: CGFloat(30))
        self.staticPocketLBL.textColor = themeColor
        self.view?.addSubview(self.staticPocketLBL)
        
        // Quotes Array
        let array = ["Believe in yourself! Have faith in your abilities! Without a humble but reasonable confidence in your own powers you cannot be successful or happy.",
                     "Sometimes your joy is the source of your smile, but sometimes your smile can be the source of your joy.",
                     "To be kind to all, to like many and love a few, to be needed and wanted by those we love, is certainly the nearest we can come to happiness.",
                     "Success is not the key to happiness. Happiness is the key to success. If you love what you are doing, you will be successful.",
                     "When one door of happiness closes, another opens, but often we look so long at the closed door that we do not see the one that has been opened for us.",
                     "The greater part of our happiness or misery depends upon our dispositions, and not upon our circumstances.",
                     "Let us be grateful to the people who make us happy; they are the charming gardeners who make our souls blossom."]
        
        // Shuffling Array
        
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        print(array[randomIndex])
        
        //Create Mark on Slider Label
        self.quoteView = UITextView(frame: CGRect (x:50, y: (self.view?.frame.size.height)!/2+50, width:screenWidth-100,height:(self.view?.frame.size.height)!))
        self.quoteView.text = array[randomIndex]
        self.quoteView.textAlignment = NSTextAlignment.center
        self.quoteView.font = UIFont.systemFont(ofSize: 18)// UIFont(name: "HelveticaNeue-Thin", size: CGFloat(20))
        self.quoteView.textColor = UIColor.black
        self.quoteView.backgroundColor = UIColor.clear
        self.quoteView.isUserInteractionEnabled=false
        self.view?.addSubview(self.quoteView)

    }
    func fadeTheScreen(){
        if self.staticToLBL.isHidden{
          self.getMySecondView()
           // self.getMyFirstView()
        }
        else{
              self.getMyFirstView()
        }
        self.view?.bringSubview(toFront: self.view!)
        UIView.animate(withDuration: 5, delay: 0, options: .curveEaseOut,
                       animations:
            {
                () -> Void in
                
                self.view?.alpha = 0
            },
                       completion:
            {
                _ in
                self.view?.removeFromSuperview()
        })
    }
    
     //MARK: - Operational Methods
    func getMyFirstView()
    {
        let initVC = self.storyboard?.instantiateViewController(withIdentifier: "PFStartVC") as! PFStartVC
        let viewControllers = [initVC]
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    func getMySecondView()
    {
        let initVC = self.storyboard?.instantiateViewController(withIdentifier: "PFStartVC") as! PFStartVC
        let chatViewController = self.storyboard?.instantiateViewController(withIdentifier: "PFChatVC") as! PFChatVC
        let viewControllers = [initVC,chatViewController]
        self.navigationController?.setViewControllers(viewControllers, animated: true)

    }
    
    
    
}
