
//FileName : BaseViewController.swift
//Version : 0.1
//DateOfCreation : 28/11/16
//Author : Manish Parihar
//Dependencies :
//Description : This ViewController will be a Base controller having generalised Methods

import UIKit
import QuartzCore

let backgroundThemeColor:UIColor = UIColor(red:233/255, green:235/255, blue:244/255, alpha:1.0)//#e9ebf4
let themeColor:UIColor = UIColor(red:45/255, green:150/255, blue:205/255, alpha:1.0)//#b51a00
let subThemeColor:UIColor = UIColor(red:255/255, green:153/255, blue:0, alpha:1.0)//#FF9900
let textThemeColor:UIColor = UIColor.white 
let textDarkColor:UIColor = UIColor.darkGray



class BaseViewController: UIViewController {

     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     var screenHeight:CGFloat=0
     var screenWidth:CGFloat=0
     var accessoryToolBar:UIToolbar!
    
    let headerView:UIView = UIView()
    var leftHeaderButton = UIButton(type: .custom)
    var rightHeaderButton = UIButton(type: .custom)

    //MARK: - View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.screenDesigningOfBaseVC()
      //  self.navigationItem.backBarButtonItem
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ScreenDesigning
    
    func screenDesigningOfBaseVC(){
        let screenRect:CGRect = UIScreen.main.bounds
        
        screenHeight = screenRect.size.height
        screenWidth = screenRect.size.width

        self.view.backgroundColor = backgroundThemeColor
        headerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 80)
        let headerBGImageView:UIImageView = UIImageView(image:UIImage(named: "header_bg"))
        headerBGImageView.frame = headerView.bounds
        headerView.backgroundColor=UIColor.clear
        headerView.addSubview(headerBGImageView)
        self.view.addSubview(headerView)
        
        leftHeaderButton.frame = CGRect(x: 10, y: 25, width: 40, height: 40)
        leftHeaderButton.setImage(UIImage(named: "Logo"), for: .normal)
        leftHeaderButton.addTarget(self, action: #selector(leftHeaderButtonClicked(_:)), for: .touchUpInside)
        headerView.addSubview(leftHeaderButton)
        
        rightHeaderButton.frame = CGRect(x: screenWidth-120, y: 28, width: 110, height: 36)
        rightHeaderButton.setTitle("About me", for: .normal)
        rightHeaderButton.backgroundColor = themeColor
        rightHeaderButton.layer.cornerRadius = 18
        rightHeaderButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        rightHeaderButton.addTarget(self, action: #selector(rightHeaderButtonClicked(_:)), for: .touchUpInside)
        headerView.addSubview(rightHeaderButton)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func leftHeaderButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func rightHeaderButtonClicked(_ sender: UIButton) {
        let aboutme: PFAboutMeVC = self.storyboard?.instantiateViewController(withIdentifier: "PFAboutMeVC") as! PFAboutMeVC
        self.navigationController?.pushViewController(aboutme, animated: true)
        //self.present(aboutme, animated: true, completion: nil)
    }
}
