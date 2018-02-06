//
//  PFStartVC.swift
//  PocketFriend
//
//  Created by Manish Parihar on 16/11/16.
//

import UIKit

class PFStartVC: BaseViewController {
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenDesigningOfStartVC()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Screen Designing Methods
    
    func screenDesigningOfStartVC(){
        rightHeaderButton.setTitle("Start", for: .normal)
        leftHeaderButton.isHidden = true
        
        for tag in 100...102{
            let btn:UIButton = self.view.viewWithTag(tag) as! UIButton
            btn.layer.cornerRadius = 30
            btn.layer.masksToBounds = true
        }
        
        }
    // MARK: - Navigation
    
    override func rightHeaderButtonClicked(_ sender: UIButton) {
        self.navigateToSignUp()
    }

    //MARK: - Operational Methods
    func navigateToSignUp(){
        if appDelegate.userInfo==nil{
            let signUpVC: PFSignUpVC = self.storyboard?.instantiateViewController(withIdentifier: "PFSignUpVC") as! PFSignUpVC
            self.navigationController?.pushViewController(signUpVC, animated: true)
        }
        else{
            let chatViewController = self.storyboard?.instantiateViewController(withIdentifier: "PFChatVC") as! PFChatVC
             self.navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
    @IBAction func openURLClicked(_ sender: UIButton)
    {
        
        var urlString:String = "About"
        if sender.tag == 100{
            urlString = "Howtouse"
        }
        else if sender.tag == 102{
            urlString = "Disclaimer"
        }
        
       let  path = Bundle.main.url(forResource: urlString, withExtension: "html")
       let urlRequest = NSURLRequest(url:path!)
        
        // Go To ChatBot
        let webVC:PFWebVC = self.storyboard?.instantiateViewController(withIdentifier: "PFWebVC") as! PFWebVC
        webVC.urlRequest = urlRequest
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    

}
