 //
//  PFChatVC.swift
//  PocketFriend
//
//  Created by Manish Parihar on 25/10/16.
//

import UIKit
import KTCenterFlowLayout
import UserNotifications
import UserNotificationsUI
import CLTimer
 
class PFChatVC: BaseViewController ,UITextFieldDelegate, UITextViewDelegate ,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,PFMultiSelectionVCDelegate,UIGestureRecognizerDelegate,cltimerDelegate {
    
    let requestIdentifier = "ReminderIdentifier"
    
    enum MultiChoiceType : Int {
        
        case TrackType
        case SubTrackType
        case YesNoType
        case MultiSelectionType
        case GenericType
    }
    
    // Global Variable
    var timer: CLTimer!
  var counterAlert = SCLAlertView()
    
    var  yAxis:CGFloat=40
    let  xAxisOfAsker:CGFloat=10
    let  sizeOfLogoImage:CGFloat = 50
    let  padding:CGFloat = 20
    let step: Float = 1
    
    var trackInfo : PFTrackInfo = PFTrackInfo()
    var subtrackInfo:PFSubTrackInfo = PFSubTrackInfo()
    var levelID:NSInteger = 1
    var sequenceID:NSInteger = 1
    var prevSequenceID:NSInteger = 1
    var currentQues:PFQuestionInfo!
    
    // For Loading Ques
    var viewLoader: UIView!
    var loadingImage:UIImageView!
    var pfImage:UIImageView!
    var pfArrowImage:UIImageView!
    var textContainerView: UIView!
    var inputTextField: UITextField!
    var inputTextView:  UITextView!
    var bgViewForBubbleCollection : UIView!
    
    var dontRemindMe:Bool = false
    var isUserInteracting:Bool = false
    // For Temp Var - to be deleted
    var multiChoiceType:MultiChoiceType = .GenericType
    
    @IBOutlet weak var btnAboutMe: UIButton!
    
    var arrOptions   : NSMutableArray!
    var userInfoArray :       NSMutableArray!
    
    
    
    // UIControl
    
    var collectionView:UICollectionView!
    var cellWidth:CGSize = CGSize(width: 100, height: 100)
  var tap : UITapGestureRecognizer!
    // Scroll View
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - View Controller Life Cycle Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.screenDesigningOfChatVC()
    }
    override func viewWillAppear(_ animated: Bool) {
       
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(PFChatVC.appGotLaunch), name: WentInBackgroundState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PFChatVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PFChatVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: WentInBackgroundState, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Screen Designing Methods
    func screenDesigningOfChatVC()
    {
        // Hidden Back Button
        self.navigationItem.setHidesBackButton(true, animated:true);
 
        // ScrollView Scrollable Size
      //  self.scrollView.contentSize = CGSize(width:self.view.frame.size.width, height:self.view.frame.size.height+20)
        
        let imageLogo : UIImage = UIImage(named: "PFLogo")!
        pfImage = UIImageView(image:imageLogo)
        pfImage.frame = CGRect(x:10, y: yAxis, width:sizeOfLogoImage,height:sizeOfLogoImage)
        pfImage.contentMode=UIViewContentMode.scaleAspectFit
        self.scrollView.addSubview(pfImage)
        
        // Triangle Icon For BackgroundView
        let imageTriangle : UIImage = UIImage(named: "quesArrow")!
        pfArrowImage = UIImageView(image:imageTriangle)
        pfArrowImage.image = pfArrowImage.image?.withRenderingMode(.alwaysTemplate)
        pfArrowImage.tintColor = themeColor
        pfArrowImage.frame = CGRect(x:60, y: yAxis, width:28,height:15)
        self.scrollView.addSubview(pfArrowImage)
        
        
        viewLoader = UIView(frame:CGRect(x:70, y: yAxis, width:70,height:50))
        viewLoader.backgroundColor = themeColor
        viewLoader.layer.cornerRadius = 5.0;
        self.scrollView.addSubview(viewLoader)
        
        let img : NSArray  = [UIImage(named:"loading1"),UIImage(named:"loading2"),UIImage(named:"loading3")]
        loadingImage = UIImageView(frame:CGRect(x:0, y: 0, width:70,height:50))
        loadingImage.contentMode=UIViewContentMode.scaleAspectFit
        loadingImage.animationImages = img as? [UIImage]
        loadingImage.animationRepeatCount=0
        loadingImage.animationDuration = 2
        loadingImage.startAnimating()
        viewLoader.addSubview(loadingImage)
        
        // TEXTFIELD INPUT
        textContainerView = UIView(frame:CGRect(x:0, y: screenHeight-80, width:screenWidth,height:80))
        let bgImage:UIImageView = UIImageView(frame:CGRect(x:0, y: 0, width:screenWidth,height:80))
        bgImage.image=UIImage(named: "footer_bg")
        textContainerView.addSubview(bgImage)
        
        let btnSubmit: UIButton = UIButton(type: .custom)
        btnSubmit.setImage(UIImage(named: "sent_btn"), for: .normal)
        btnSubmit.addTarget(self, action: #selector(PFChatVC.submitTextClicked(_:)), for: UIControlEvents.touchUpInside)
        btnSubmit.frame = CGRect(x: screenWidth-75, y: 15, width: 65, height: 65)
        textContainerView.addSubview(btnSubmit)
        
        let defaults = UserDefaults.standard
        dontRemindMe = defaults.bool(forKey: "DontRemindMe")
        /*
        inputTextField  = UITextField(frame: CGRect (x:20, y:15, width:Int(btnSubmit.frame.origin.x-10),height:65))
        inputTextField.font = UIFont.systemFont(ofSize: 17)
        inputTextField.placeholder = "Type here..."
        inputTextField.borderStyle = UITextBorderStyle.none
        inputTextField.autocorrectionType = UITextAutocorrectionType.no
        inputTextField.keyboardType = UIKeyboardType.default
        //self.userNextTextField.returnKeyType = UIReturnKeyType.done
        inputTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        inputTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        inputTextField.delegate = self
        textContainerView.addSubview(inputTextField)
        self.view.addSubview(textContainerView)
        textContainerView.isHidden=true
         */
        
        // TextView
        inputTextView = UITextView(frame: CGRect (x:20, y:15, width:Int(btnSubmit.frame.origin.x-10),height:65))
        inputTextView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        inputTextView.textAlignment = NSTextAlignment.justified
        inputTextView.backgroundColor = UIColor.white
        inputTextView.font = UIFont.systemFont(ofSize: 17)
        inputTextView.textColor = UIColor.black
        //inputTextView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        //inputTextView.text = "Enter your text here"
        inputTextView.isSelectable = false
        inputTextView.isEditable = true
        inputTextView.dataDetectorTypes = UIDataDetectorTypes.link
        inputTextView.autocorrectionType = UITextAutocorrectionType.no
        inputTextView.spellCheckingType = UITextSpellCheckingType.no
        textContainerView.addSubview(inputTextView)
        self.view.addSubview(textContainerView)
        textContainerView.isHidden=true
        
//        // ToolBar
//        let toolBar = UIToolbar()
//        toolBar.barStyle = .default
//        toolBar.isTranslucent = true
//        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
//        toolBar.sizeToFit()
//        
//        // Adding Button ToolBar
//        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(PFChatVC.submitTextClicked(_:)))
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(PFChatVC.cancelClick))
//        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
//        toolBar.isUserInteractionEnabled = true
//        inputTextView.inputAccessoryView = toolBar
        
       

        // Tap Gesture
        tap = UITapGestureRecognizer(target: self, action: #selector(PFChatVC.tapGestureOccur))
        tap.delegate = self
        self.scrollView.addGestureRecognizer(tap)
        
        self.showQuestionLoading(load: true)
        self.perform(#selector(PFChatVC.getQuestion), with: nil, afterDelay: 2.5) // 1.5
    }
    
    
    func appGotLaunch(){
        inputTextView.resignFirstResponder()
        textContainerView.isHidden=true
        for view:UIView in scrollView.subviews{
            view.removeFromSuperview()
        }
        yAxis=40
        
        self.scrollView.addSubview(pfImage)
        self.scrollView.addSubview(pfArrowImage)
        self.scrollView.addSubview(viewLoader)
        
       trackInfo = PFTrackInfo()
       subtrackInfo = PFSubTrackInfo()
        levelID = 1
        sequenceID = 1
        prevSequenceID = 1
        if bgViewForBubbleCollection != nil{
        bgViewForBubbleCollection.frame = CGRect(x:10, y: self.view.frame.size.height , width:self.view.frame.size.width-20,height:200)
        }
        arrOptions.removeAllObjects()
       //  self.scrollView.contentSize = CGSize(width:self.view.frame.size.width, height:self.view.frame.size.height+20)
        self.scrollView.contentOffset = CGPoint(x:0,y:0)
        self.showQuestionLoading(load: true)
        self.perform(#selector(PFChatVC.getQuestion), with: nil, afterDelay: 2.5) // 1.5
    }
    func showCollectionView()
    {
        if(bgViewForBubbleCollection == nil)
        {
            // White Background View
            bgViewForBubbleCollection = UIView(frame:CGRect(x:10, y: self.view.frame.size.height , width:self.view.frame.size.width-20,height:200))
            bgViewForBubbleCollection.backgroundColor = UIColor.clear
            bgViewForBubbleCollection.layer.cornerRadius = 5.0;
            self.view.addSubview(bgViewForBubbleCollection!)
            
            
            // Collection View
            let flowLayout = KTCenterFlowLayout()
            flowLayout.minimumInteritemSpacing = 10.0
            flowLayout.minimumLineSpacing = 10.0
            
            //let flowLayout = UICollectionViewFlowLayout()
            collectionView = UICollectionView(frame: CGRect(x:0, y: 0 , width:bgViewForBubbleCollection.frame.size.width, height:bgViewForBubbleCollection.frame.size.height), collectionViewLayout: flowLayout)
            collectionView.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: ChatCollectionViewCellIdentifier)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = UIColor.clear
            self.bgViewForBubbleCollection.addSubview(collectionView)
        }
        
        cellWidth=CGSize(width:100,height:100)
        var cellWidthTemp:CGSize = CGSize(width:100,height:0)
        
        for recordCount in 0...arrOptions.count-1
        {
            var strTemp:String = ""
            
            if multiChoiceType == .TrackType{
                let  trackInfo : PFTrackInfo = self.arrOptions.object(at: recordCount) as! PFTrackInfo
                strTemp = trackInfo.Description
            }
            else if multiChoiceType == .SubTrackType{
                let subtrackInfo : PFSubTrackInfo = self.arrOptions.object(at: recordCount) as! PFSubTrackInfo
                strTemp = subtrackInfo.subTrack_description
            }
            else if multiChoiceType == .YesNoType || multiChoiceType == .MultiSelectionType{
                strTemp = arrOptions.object(at: recordCount) as! String
            }
            cellWidthTemp =  ChatCollectionViewCell.contentHeight(strTemp)
            cellWidthTemp.height = cellWidthTemp.width
            if cellWidth.width < cellWidthTemp.width{
                cellWidth = cellWidthTemp
            }
            
        }
        
        bgViewForBubbleCollection.isHidden=false
        collectionView.reloadData()
        
        UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions(),
                       animations: { () -> Void in
                        let collectionHeight:CGSize = self.collectionView.collectionViewLayout.collectionViewContentSize
                        self.bgViewForBubbleCollection.frame = CGRect(x:10, y: self.view.frame.size.height-collectionHeight.height-20 , width:self.bgViewForBubbleCollection.frame.size.width,height:collectionHeight.height)
                        self.collectionView.frame = self.bgViewForBubbleCollection.bounds
                        self.changeContentSizeOfScrollView(yContent: collectionHeight.height-collectionHeight.height/6)
            }, completion: nil)
        
    }
    func ansChatBoxWithSlider()
    {
        // Logo Image Left
        let imageLogo : UIImage = UIImage(named: "userLogo")!
        let logo:UIImageView = UIImageView(image:imageLogo)
        logo.frame = CGRect(x:screenWidth-60, y: yAxis, width:sizeOfLogoImage,height:sizeOfLogoImage)
        logo.contentMode=UIViewContentMode.scaleAspectFit
        self.scrollView.addSubview(logo)
        
        // Triangle Icon For BackgroundView
        let imageTriangle : UIImage = UIImage(named: "ansArrow")!
        let triangleIcon:UIImageView = UIImageView(image:imageTriangle)
        triangleIcon.image = triangleIcon.image!.withRenderingMode(.alwaysTemplate)
        triangleIcon.tintColor = textThemeColor
        triangleIcon.frame = CGRect(x:logo.frame.origin.x-28, y: yAxis, width:28,height:15)
        self.scrollView.addSubview(triangleIcon)
        
        
        // Bubble View
        let bubbleView:UIView = UIView(frame:CGRect(x:screenWidth-60, y: yAxis, width:screenWidth/2,height:90))
        bubbleView.backgroundColor = textThemeColor
        bubbleView.layer.cornerRadius = 5.0;
        self.scrollView.addSubview(bubbleView)
        
        
        let hardlyLBL:UILabel = UILabel(frame: CGRect (x:10, y: 5, width:50, height:40))
        hardlyLBL.textColor = UIColor.black
        hardlyLBL.font = UIFont.systemFont(ofSize: 12)
        hardlyLBL.text = "Bad"
        hardlyLBL.numberOfLines = 0
        hardlyLBL.textAlignment = .left
        bubbleView.addSubview(hardlyLBL)
        
        let neutralLBL:UILabel = UILabel(frame: CGRect (x:85, y: 5, width:50, height:40))
        neutralLBL.textColor = UIColor.black
        neutralLBL.font = UIFont.systemFont(ofSize: 12)
        neutralLBL.text = "Neutral"
        neutralLBL.numberOfLines = 0
        neutralLBL.textAlignment = .center
        bubbleView.addSubview(neutralLBL)
        
        let veryLBL:UILabel = UILabel(frame: CGRect (x:170, y: 5, width:50, height:40))
        veryLBL.textColor = UIColor.black
        veryLBL.font = UIFont.systemFont(ofSize: 12)
        veryLBL.text = "Good"
        veryLBL.numberOfLines = 0
        veryLBL.textAlignment = .right
        bubbleView.addSubview(veryLBL)
        
        let slider:UISlider = UISlider(frame: CGRect (x:10, y: 40, width:200, height:40))
        slider.minimumValue = -5
        slider.maximumValue = 5
        slider.isContinuous = true
        slider.tintColor = subThemeColor
        slider.value = 0
        slider.addTarget(self, action: #selector(PFChatVC.sliderValueChanged(_:)), for: UIControlEvents.valueChanged)
        slider.addTarget(self, action: #selector(PFChatVC.sliderValueDidFinishDrag(_:)), for: UIControlEvents.touchUpInside)
        slider.addTarget(self, action: #selector(PFChatVC.sliderValueDidFinishDrag(_:)), for: UIControlEvents.touchUpOutside)
        
        bubbleView.addSubview(slider)
        
    
        //Bubble Label
        let ansLBL:UILabel = UILabel(frame: CGRect (x:210, y: 40, width:40, height:30))
        ansLBL.textColor = UIColor.black
        ansLBL.font = UIFont.boldSystemFont(ofSize: 17)
        ansLBL.numberOfLines = 0
        ansLBL.text = "0"
        ansLBL.textAlignment = .center
        ansLBL.lineBreakMode = NSLineBreakMode.byWordWrapping
        ansLBL.tag=1001
        bubbleView.addSubview(ansLBL)
        
//        let minRangeLBL:UILabel = UILabel(frame: CGRect (x:10, y: 50, width:20, height:20))
//        minRangeLBL.textColor = UIColor.black
//        minRangeLBL.font = UIFont.systemFont(ofSize: 12)
//        minRangeLBL.text = "-5"
//        minRangeLBL.textAlignment = .center
//        bubbleView.addSubview(minRangeLBL)
//        
//        let maxRangeLBL:UILabel = UILabel(frame: CGRect (x:200, y: 50, width:20, height:20))
//        maxRangeLBL.textColor = UIColor.black
//        maxRangeLBL.font = UIFont.systemFont(ofSize: 12)
//        maxRangeLBL.text = "5"
//        maxRangeLBL.textAlignment = .center
//        bubbleView.addSubview(maxRangeLBL)
        
        bubbleView.frame = CGRect(x:triangleIcon.frame.origin.x-230, y: yAxis, width: 250, height: 90);
        
        let newYAxis:CGFloat = yAxis+bubbleView.frame.size.height
        logo.frame = CGRect(x:logo.frame.origin.x, y: newYAxis-sizeOfLogoImage, width:sizeOfLogoImage,height:sizeOfLogoImage)
        
        triangleIcon.frame = CGRect(x:triangleIcon.frame.origin.x, y: newYAxis-15, width:28,height:15)
        yAxis += bubbleView.frame.size.height+padding
        
        levelID += 1
        self.changeContentSizeOfScrollView(yContent: bubbleView.frame.size.height)
    }
    func ansChatBoxWithString(ansString:String)
    {
        // Logo Image Left
        let imageLogo : UIImage = UIImage(named: "userLogo")!
        let logo:UIImageView = UIImageView(image:imageLogo)
        logo.frame = CGRect(x:screenWidth-60, y: yAxis, width:sizeOfLogoImage,height:sizeOfLogoImage)
        logo.contentMode=UIViewContentMode.scaleAspectFit
        self.scrollView.addSubview(logo)
        
        // Triangle Icon For BackgroundView
        let imageTriangle : UIImage = UIImage(named: "ansArrow")!
        let triangleIcon:UIImageView = UIImageView(image:imageTriangle)
        triangleIcon.image = triangleIcon.image!.withRenderingMode(.alwaysTemplate)
        triangleIcon.tintColor = textThemeColor
        triangleIcon.frame = CGRect(x:logo.frame.origin.x-28, y: yAxis, width:28,height:15)
        self.scrollView.addSubview(triangleIcon)
        
        // Bubble View
        let bubbleView:UIView = UIView(frame:CGRect(x:screenWidth-60, y: yAxis, width:screenWidth/2+30,height:50))
        bubbleView.backgroundColor = textThemeColor
        bubbleView.layer.cornerRadius = 5.0;
        self.scrollView.addSubview(bubbleView)
        
        //Bubble Label
        let strAns:String = GlobalSwift.sentenceCase(string: ansString)
        let ansLBL:UILabel = UILabel(frame: CGRect (x:10, y: 10, width:(bubbleView.frame.size.width)-20,height:(bubbleView.frame.size.height)-20))
        ansLBL.text = strAns
        ansLBL.textColor = UIColor.black
        ansLBL.numberOfLines = 0
        ansLBL.lineBreakMode = NSLineBreakMode.byWordWrapping
        bubbleView.addSubview(ansLBL)
        
        if let ns_str: NSString = strAns as NSString?
        {
            let sizeOfString:CGSize = ns_str.boundingRect(
                with: CGSize(width: ansLBL.frame.size.width, height: CGFloat.infinity),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSFontAttributeName: ansLBL.font],
                context: nil).size
            ansLBL.frame = CGRect(x:10, y: 10, width: sizeOfString.width+20, height: ((sizeOfString.height < 30) ? 30 : sizeOfString.height))
            bubbleView.frame = CGRect(x:triangleIcon.frame.origin.x-ansLBL.frame.size.width-3, y: yAxis, width: ansLBL.frame.size.width+20, height: ansLBL.frame.size.height+20);
        }
        
        let newYAxis:CGFloat = yAxis+bubbleView.frame.size.height
        logo.frame = CGRect(x:logo.frame.origin.x, y: newYAxis-sizeOfLogoImage, width:sizeOfLogoImage,height:sizeOfLogoImage)
        
        triangleIcon.frame = CGRect(x:triangleIcon.frame.origin.x, y: newYAxis-15, width:28,height:15)
        yAxis += bubbleView.frame.size.height+padding
        
        levelID += 1
        self.changeContentSizeOfScrollView(yContent: bubbleView.frame.size.height)
        
    }
    func quesChatBoxWithString(quesString:String)
    {
        let imageLogo : UIImage = UIImage(named: "PFLogo")!
        let logo:UIImageView = UIImageView(image:imageLogo)
        logo.frame = CGRect(x:10, y: yAxis, width:sizeOfLogoImage,height:sizeOfLogoImage)
        logo.contentMode=UIViewContentMode.scaleAspectFit
        self.scrollView.addSubview(logo)
        
        // Triangle Icon For BackgroundView
        let imageTriangle : UIImage = UIImage(named: "quesArrow")!
        let triangleIcon:UIImageView = UIImageView(image:imageTriangle)
        triangleIcon.image = triangleIcon.image!.withRenderingMode(.alwaysTemplate)
        triangleIcon.tintColor = themeColor
        triangleIcon.frame = CGRect(x:60, y: yAxis, width:28,height:15)
        self.scrollView.addSubview(triangleIcon)
        
        // Bubble View
        let bubbleView:UIView = UIView(frame:CGRect(x:70, y: yAxis, width:screenWidth/2+30,height:50))
        bubbleView.backgroundColor = themeColor
        bubbleView.layer.cornerRadius = 5.0;
        self.scrollView.addSubview(bubbleView)
        
        var strQues:String = ""
        if (levelID == 1 && sequenceID == 1) {
           strQues = quesString.capitalized
        }
        else{
             strQues = GlobalSwift.sentenceCase(string: quesString)
        }
        //Bubble Label
        let questionLBL:UILabel = UILabel(frame: CGRect (x:10, y: 10, width:(bubbleView.frame.size.width)-20,height:(bubbleView.frame.size.height)-20))
        
        questionLBL.textColor = textThemeColor
        questionLBL.numberOfLines = 0
        questionLBL.lineBreakMode = NSLineBreakMode.byWordWrapping
        bubbleView.addSubview(questionLBL)
        
        if levelID == 7 && sequenceID == 1 && subtrackInfo.subTrack_id == 11{
           // let startIndex = strQues.characters.index(of: "D")
            let textRange = NSMakeRange(5, 2)
            let attributedText = NSMutableAttributedString(string: strQues)
            attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
            questionLBL.attributedText = attributedText
        }
        else{
            questionLBL.text = strQues
        }
        
        if let ns_str: NSString = strQues as NSString?
        {
            let sizeOfString:CGSize = ns_str.boundingRect(
                with: CGSize(width: questionLBL.frame.size.width, height: CGFloat.infinity),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSFontAttributeName: questionLBL.font],
                context: nil).size
            questionLBL.frame = CGRect(x:10, y: 10, width: sizeOfString.width, height: ((sizeOfString.height < 30) ? 30 : sizeOfString.height))
            bubbleView.frame = CGRect(x:bubbleView.frame.origin.x, y: yAxis, width: questionLBL.frame.size.width+20, height: questionLBL.frame.size.height+20);
        }
        yAxis += bubbleView.frame.size.height+padding
        self.changeContentSizeOfScrollView(yContent: bubbleView.frame.size.height)
        showQuestionLoading(load: false)
    }
    
//     func quesChatBoxWithString(quesString:String)
//    {
//        let imageLogo : UIImage = UIImage(named: "PFLogo")!
//        let logo:UIImageView = UIImageView(image:imageLogo)
//        logo.frame = CGRect(x:10, y: yAxis, width:sizeOfLogoImage,height:sizeOfLogoImage)
//        logo.contentMode=UIViewContentMode.scaleAspectFit
//        self.scrollView.addSubview(logo)
//        
//        // Triangle Icon For BackgroundView
//        let imageTriangle : UIImage = UIImage(named: "quesArrow")!
//        let triangleIcon:UIImageView = UIImageView(image:imageTriangle)
//        triangleIcon.image = triangleIcon.image!.withRenderingMode(.alwaysTemplate)
//        triangleIcon.tintColor = themeColor
//        triangleIcon.frame = CGRect(x:60, y: yAxis, width:28,height:15)
//        self.scrollView.addSubview(triangleIcon)
//        
//        // Bubble View
//        let bubbleView:UIView = UIView(frame:CGRect(x:70, y: yAxis, width:screenWidth/2+30,height:50))
//        bubbleView.backgroundColor = themeColor
//        bubbleView.layer.cornerRadius = 5.0;
//        self.scrollView.addSubview(bubbleView)
//        
//        var strQues:String = ""
//        if (levelID == 1 && sequenceID == 1) {
//           strQues = quesString.capitalized
//        }
//        else{
//             strQues = GlobalSwift.sentenceCase(string: quesString)
//        }
//        //Bubble Label
//        let webView : UIWebView = UIWebView(frame: CGRect (x:10, y: 10, width:(bubbleView.frame.size.width)-20,height:(bubbleView.frame.size.height)-20))
//        webView.loadHTMLStringInWebView(strHTML: strQues)
//        webView.scrollView.isScrollEnabled=false
//        webView.isUserInteractionEnabled =  false
//        bubbleView.addSubview(webView)
//        
//        if let ns_str: NSString = strQues as NSString?
//        {
//            let sizeOfString:CGSize = ns_str.boundingRect(
//                with: CGSize(width: webView.frame.size.width, height: CGFloat.infinity),
//                options: NSStringDrawingOptions.usesLineFragmentOrigin,
//                attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17)],
//                context: nil).size
//            webView.frame = CGRect(x:10, y: 10, width: sizeOfString.width, height: ((sizeOfString.height < 30) ? 30 : sizeOfString.height))
//            bubbleView.frame = CGRect(x:bubbleView.frame.origin.x, y: yAxis, width: webView.frame.size.width+20, height: webView.frame.size.height+20);
//        }
//        yAxis += bubbleView.frame.size.height+padding
//        self.changeContentSizeOfScrollView(yContent: bubbleView.frame.size.height)
//        showQuestionLoading(load: false)
//    }
    
    //MARK: - Operational Methods
    func getQuestion(){
        isUserInteracting = false
        var  pickRandom:Bool = false
        if (levelID==1 && sequenceID==2) || (levelID==2 && sequenceID==1) {
            pickRandom=true
        }
        currentQues = PFModelManager.getInstance().getQuestion(trackID: trackInfo.Id, subTrackID: subtrackInfo.subTrack_id, levelID: levelID,sequence:sequenceID,pickAnyRandom:pickRandom )
        if  !currentQues.Q_Desc.isEmpty {
            var quesString = currentQues.Q_Desc
            if (levelID == 1 && sequenceID == 1) {
                let fullName    = appDelegate.userInfo.Name
                let fullNameArr = fullName.components(separatedBy: " ")
                
                let fname    = fullNameArr[0]
                quesString = quesString.replacingOccurrences(of: "<Name>", with: fname) 
            }
            quesString = quesString.replacingOccurrences(of: "<", with: "")
            quesString = quesString.replacingOccurrences(of: ">", with: "")
            self.quesChatBoxWithString(quesString: quesString)
            
            if currentQues.ShowInputField==1{
                isUserInteracting=true
                if currentQues.FieldType=="MultiChoice" {
                    if (levelID == 1 && sequenceID == 3) {
                        arrOptions = PFModelManager.getInstance().getAllTracks()
                        multiChoiceType = .TrackType
                        self.showCollectionView()
                    }
                    else if (levelID == 3) {
                        arrOptions = PFModelManager.getInstance().getSubTracksOfTrack(trackID: currentQues.TrackID)
                        multiChoiceType = .SubTrackType
                        self.showCollectionView()
                    }
                }
                else if currentQues.FieldType=="Slider" {
                    self.ansChatBoxWithSlider()
                }
                else if currentQues.FieldType=="TextField" {
                    textContainerView.isHidden=false
                    // inputTextField.becomeFirstResponder()
                    inputTextView.becomeFirstResponder()
                }
                else if currentQues.FieldType=="YesNo" {
                    arrOptions = ["Yes","No"]
                    multiChoiceType = .YesNoType
                    self.showCollectionView()
                }
                else if currentQues.FieldType=="MultiSelection" {
                    arrOptions = ["Select"]
                    multiChoiceType = .MultiSelectionType
                    self.showCollectionView()
                }
               else if currentQues.FieldType == "Counter"{
                    self.showCounter()
                }
                else{
                    levelID += 1
                    isUserInteracting=false
                     self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
                }
                
            }
            else{
                if levelID<4 || (levelID==4 && sequenceID==1){
                    if levelID==4 && sequenceID==1 {
                        if !dontRemindMe{
                            let alert = SCLAlertView()
                            _ = alert.addButton("Don't remind me again",backgroundColor:themeColor,textColor:textThemeColor) {
                                // Slider Value
                                let defaults = UserDefaults.standard
                                defaults.set(true, forKey: "DontRemindMe")
                            }
                            _ = alert.showInfo("", subTitle: "Tap the view, at your own pace to move futher on therapy", closeButtonTitle: "Okay", duration: 0.0, colorStyle: subThemeColor, colorTextButton: textThemeColor, circleIconImage: nil, animationStyle: SCLAnimationStyle.topToBottom)
                        }
                        
                                          }
                    else{
                    let quesString:String = currentQues.Q_Desc
                    let sleepDuration = Double(quesString.characters.count) * 0.03 + 0.5
                    //}if (trackID == 1 && subTrackID == 1 && levelID == 1 && sequenceID == 1) {
                    self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: sleepDuration)
                }
                }
                
            }
        }
        else{
            self.showQuestionLoading(load: false)
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: yAxis+padding)
            
            self.rightHeaderButtonClicked(rightHeaderButton)
        }
    }
    func goToNextQues(){
        self.showQuestionLoading(load: true)
        print("LEVEL VALUE :")
        print(currentQues.Level_ID)
        print(levelID)
        prevSequenceID = sequenceID
        if currentQues.Level_ID != levelID{
            sequenceID=1
            // levelID += 1
        }
        else{
            sequenceID += 1
        }
        self.perform(#selector(PFChatVC.getQuestion), with: nil, afterDelay: 2.5) // 1.5
        
        
    }
    func showQuestionLoading(load:Bool){
        viewLoader.isHidden = !load;
        pfImage.isHidden = !load;
        pfArrowImage.isHidden = !load;
        
        loadingImage.stopAnimating();
        if load {
            // Logo Image Left
            tap.isEnabled = false
            pfImage.frame = CGRect(x:10, y: yAxis, width:sizeOfLogoImage,height:sizeOfLogoImage)
            // Triangle Icon For BackgroundView
            
            pfArrowImage.frame = CGRect(x:60, y: yAxis, width:28,height:15)
            
            
            loadingImage.startAnimating()
            var frame:CGRect =  viewLoader.frame
            frame.origin.y = yAxis
            viewLoader.frame = frame
            
            viewLoader.isHidden=false;
           
        }
        else{
            tap.isEnabled = true
        }
    }
    func changeContentSizeOfScrollView(yContent:CGFloat){
        if (yAxis>(scrollView.frame.size.height/2)-30)
        {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.contentSize.height+yAxis)
//            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y+yContent+padding), animated: true)
             scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: yAxis+screenHeight/2)
           // scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentSize.height+yContent+padding), animated: true)
//             scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentSize.height+yContent+padding), animated: true)
            let bottomOffset:CGPoint = CGPoint(x:0,y:self.scrollView.contentSize.height - self.scrollView.bounds.size.height);

           scrollView.setContentOffset(bottomOffset, animated: true)
        }
        
    }
    func saveInputInDatabase(inputText:String, track:NSInteger, subTrack:NSInteger){
        
        let userResponseInfo : PFUserAnswerInfo = PFUserAnswerInfo()
        
        userResponseInfo.USER_ID = 1
        userResponseInfo.Q_ID = currentQues.Id
        //userResponseInfo.A_ID = trackInfo.Id // "1"
        userResponseInfo.TEXT = inputText
        //userResponseInfo.A_OPTS_ID = "2"
        userResponseInfo.TRACK_ID = track
        userResponseInfo.SUBTRACK_ID = subTrack
        
        // Save Response for Good Button Click
        let isInserted = PFModelManager.getInstance().saveUserResponse(userResponseInfo)
        
        if isInserted {
            print(userResponseInfo)
        } else {
            
            PFUtility.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
        }
        
    }
    func sliderValueChanged(_ sender: UISlider)
    {
        // Slider Value
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        let parentView:UIView = sender.superview!
        for  subView:UIView in parentView.subviews{
            if subView is UILabel {
                let lbl:UILabel=subView as! UILabel
                if lbl.tag==1001 {
                     lbl.text = "\(Int(roundedValue))"
                }
               
            }
            
        }
        
    }

    func sliderValueDidFinishDrag(_ sender: UISlider)
    {
         let alert = SCLAlertView()
        _ = alert.addButton("Yes",backgroundColor:themeColor,textColor:textThemeColor) {
                // Slider Value
            let roundedValue = round(sender.value / self.step) * self.step
            sender.isUserInteractionEnabled = false
            self.saveInputInDatabase(inputText:"\(Int(roundedValue))" , track: 0, subTrack: 0)
            self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
        }
        _ = alert.showInfo("", subTitle: "Would you like to go with the value you selected?", closeButtonTitle: "No", duration: 0.0, colorStyle: subThemeColor, colorTextButton: textThemeColor, circleIconImage: nil, animationStyle: SCLAnimationStyle.topToBottom)
       
    }
    func submitTextClicked(_ sender: UIButton) {
        // textContainerView.isHidden=true
        // self.ansChatBoxWithString(ansString: inputTextField.text!)
        // inputTextField.resignFirstResponder()
        // self.saveInputInDatabase(inputText:inputTextField.text! , track: 0, subTrack: 0)
        // inputTextField.text = ""

        if inputTextView.text.isEmpty
        {
            PFUtility.invokeAlertMethod("", strBody: "Please enter text.", delegate: nil)
            textContainerView.isHidden=false
        }
        else
        {
        textContainerView.isHidden=true

         self.ansChatBoxWithString(ansString: inputTextView.text!)
         inputTextView.resignFirstResponder()
         self.saveInputInDatabase(inputText:inputTextView.text! , track: 0, subTrack: 0)
         inputTextView.text = ""
        self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
        }
    }
//    func selectSubtrackNextQues(subtrackInfo:PFSubTrackInfo){

     func selectSubtrackNextQues(){
        self.showQuestionLoading(load: true)
        let arrSubtracks:NSArray = PFModelManager.getInstance().getSubtracks(limit: 3, userid: appDelegate.userInfo.UserID)
        var count:NSInteger = 0
        if arrSubtracks.count>0 {
            
            for recordCount in 0...arrSubtracks.count-1{
                let subTrackObj:PFSubTrackInfo = arrSubtracks.object(at: recordCount) as! PFSubTrackInfo
                if subTrackObj.subTrack_id == subtrackInfo.subTrack_id{
                    count += 1
                }
                else{
                    break
                }
            }
            var replyString: String = ""
            let subTrackDesc:String = subtrackInfo.subTrack_description
            
            if count==1 {
                self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
                return
            }
            else if count==2 {
                
                
                if trackInfo.Id==1{
                    replyString = "You are feeling \(subTrackDesc) again that’s is really good news, you are tracking well!"
                }
                else if trackInfo.Id==2 {
                    replyString = "You are still feeling \(subTrackDesc) just like last time we spoke – you should focus on some therapy/mindfulness?"
                }
                
            }
            else if count==3 {
                
                
                if trackInfo.Id==1{
                    replyString = "Hey that’s the third time you mentioned \(subTrackDesc) that is great, you are going places."
                }
                else if trackInfo.Id==2 {
                    replyString = "Hm. That’s the third time you have told me you suffer from \(subTrackDesc) - you better check out your overview of happiness in the About Me section, and think about getting your mind more positive"
                }
                
            }
            
            self.quesChatBoxWithString(quesString: replyString)
            
            self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
        }
        else{
            self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
            return
        }
        
    }
    func dontRemindMeClicked(){
        
    }
    func tapGestureOccur(sender: UITapGestureRecognizer? = nil){
        if !isUserInteracting {
            self.goToNextQues()
        }
        else{
            inputTextView.resignFirstResponder()
        }
    }
//    // Cancel for keyboar on text view
//    func cancelClick()
//    {
//        inputTextView.resignFirstResponder()
//    }
    
    //MARK: - Counter
    
    func showCounter(){
        // Create custom Appearance Configuration
        var appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            dynamicAnimatorActive: true
        )
        
        
        // Initialize SCLAlertView using custom Appearance
        appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        
        counterAlert = SCLAlertView(appearance: appearance)
        
        // Creat the subview
        let subview = UIView(frame: CGRect(x: 0,y: 0,width: 216,height: 150))
        let x = (subview.frame.width - 180) / 2
        
        timer = CLTimer(frame: CGRect(x: x, y: 10, width: 180, height: 120))
        //        timer.countDownColor = themeColor
        timer.cltimer_delegate=self
        timer.backgroundColor = UIColor.clear
        timer.startTimer(withSeconds: 60, format:.seconds , mode: .reverse)
        subview.addSubview(timer)
        
        // Add the subview to the alert's UI property
        counterAlert.customSubview = subview
        
        // Add Button with Duration Status and custom Colors
        _ = counterAlert.addButton("Its Done", backgroundColor:subThemeColor, textColor: textThemeColor, showDurationStatus: false) {
            print("Duration Button tapped")
            if self.levelID==5 && self.sequenceID == 8 && self.subtrackInfo.subTrack_id == 9{
                self.levelID += 1
            }
            self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
        }
        _ = counterAlert.showEdit("Meditate", subTitle:"",circleIconImage:UIImage(named:"Logo"))
    }
    // CLTimer
    func timerDidUpdate(_ time:Int){
        print("updated Time : ",time)
        if(time == 0) {
            print("Dismiss alert view here")
            counterAlert.hideView()
            self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
        }
    }
    
    func timerDidStop(_ time:Int){
        print("Stopped time : ",time)
        if(time == 0) {
            print("Dismiss alert view here")
            counterAlert.hideView()
            self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
        }
        
        
    }
    // MARK: - Reminder Notification
    
    func triggerNotification(title:String,subTitle:String,body:String){
        
       
        //Requesting Authorization for User Interactions
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            print("notification will be triggered in five seconds..Hold on tight")
            let content = UNMutableNotificationContent()
            content.title = "Just reminding you of the \(subTitle.capitalized) we discussed yesterday, and your response was "
            //content.subtitle = "Feel \(subTitle.capitalized)"
            content.body = body
            content.sound = UNNotificationSound.default()
            
            //To Present image in notification
            if let path = Bundle.main.path(forResource: "PFLogo", ofType: "png") {
                let url = URL(fileURLWithPath: path)
                
                do {
                    let attachment = try UNNotificationAttachment(identifier: "PFLogo", url: url, options: nil)
                    content.attachments = [attachment]
                } catch {
                    print("attachment not found.")
                }
            }
            
            // Deliver the notification in five seconds.
    
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60, repeats: false)
        
            let request = UNNotificationRequest(identifier:requestIdentifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().add(request){(error) in
                
                if (error != nil){
                    
                    print(error?.localizedDescription)
                }
            }
        }
        else{
            let types:UIUserNotificationType = UIUserNotificationType.alert
            let mySettings:UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(mySettings)
            let calendar = NSCalendar.autoupdatingCurrent
            let fireDate = calendar.date(byAdding: Calendar.Component.minute, value: 1, to: NSDate() as Date, wrappingComponents: true)
            let localNotification = UILocalNotification()
            localNotification.fireDate = fireDate
            localNotification.alertTitle = "Just reminding you of the \(subTitle.capitalized) we discussed yesterday, and your response was "
            localNotification.alertBody = body
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.alertAction = requestIdentifier
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
    
     func stopNotification() {
        
        print("Removed all pending notifications")
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
             center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
        } else {
            // Fallback on earlier versions
        }
       
        
    }

    // MARK: - Collection View Delegate & Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrOptions.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell: ChatCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCollectionViewCellIdentifier, for: indexPath) as? ChatCollectionViewCell
        
        for view in (cell?.contentView.subviews)!{
            view.removeFromSuperview()
        }

//        cell?.layer.cornerRadius = (cell?.frame.size.height)!/2
//        cell?.layer.masksToBounds = true
        var strTemp:String = ""
        if multiChoiceType == .TrackType{
            let  trackInfo : PFTrackInfo = self.arrOptions.object(at: indexPath.item) as! PFTrackInfo
            strTemp = trackInfo.Description
        }
        else if multiChoiceType == .SubTrackType{
            let subtrackInfo : PFSubTrackInfo = self.arrOptions.object(at: indexPath.item) as! PFSubTrackInfo
           strTemp = subtrackInfo.subTrack_description
        }
        else if multiChoiceType == .YesNoType || multiChoiceType == .MultiSelectionType{
            strTemp = arrOptions.object(at: indexPath.item) as! String
            
        }
        cell?.initContent(optionText: strTemp,bgColor: subThemeColor,textColor: textThemeColor,BGImage: UIImage(named:"OrangeShadowedCircle"))
        
         //cell?.animateSelection()
        return cell!;
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        if (indexPath as NSIndexPath).row < arrOptions.count {
        //            if multiChoiceType == .TrackType {
        //                let  trackInfo : PFTrackInfo = self.arrOptions.object(at: indexPath.item) as! PFTrackInfo
        //                return ChatCollectionViewCell.contentHeight(trackInfo.Description)
        //            }
        //            else if multiChoiceType == .SubTrackType{
        //
        //                let subtrackInfo : PFSubTrackInfo = self.arrOptions.object(at: indexPath.item) as! PFSubTrackInfo
        //                 return ChatCollectionViewCell.contentHeight(subtrackInfo.subTrack_description)
        //            }
        //        }
        return cellWidth//CGSize(width: 40, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let selectedCell: ChatCollectionViewCell? = collectionView.cellForItem(at: indexPath) as? ChatCollectionViewCell
        selectedCell?.animateSelection()
        var  selectedOption:String = ""
        var hold = false
        if multiChoiceType == .TrackType {
            trackInfo = self.arrOptions.object(at: indexPath.item) as! PFTrackInfo
            selectedOption = trackInfo.Description
        }
        else if multiChoiceType == .SubTrackType {
            subtrackInfo = self.arrOptions.object(at: indexPath.item) as! PFSubTrackInfo
            selectedOption = subtrackInfo.subTrack_description
            hold=true
        }
        else if multiChoiceType == .YesNoType{
            selectedOption =  self.arrOptions.object(at: indexPath.item) as! String
            //Currently making things hardcoded which will need to be remove
            if indexPath.item == 0{
                if subtrackInfo.subTrack_id == 5 && levelID==4 {
                    hold = true
                }
                else {
                    
                    //Open Counter
                    let prevQues:PFQuestionInfo = PFModelManager.getInstance().getQuestion(trackID: trackInfo.Id, subTrackID: subtrackInfo.subTrack_id, levelID: levelID-1,sequence:prevSequenceID,pickAnyRandom:false )
                    let ans  = PFModelManager.getInstance().getDescriptionOfQuestion(quesID: prevQues.Id, userID:appDelegate.userInfo.UserID)
                    self.triggerNotification(title: trackInfo.Description, subTitle: subtrackInfo.subTrack_description, body: ans)
                }
            
            }
           else if indexPath.item==1 && currentQues.MoveToLevel != 0{
            levelID = currentQues.MoveToLevel-1
            }
        }
        else if multiChoiceType == .MultiSelectionType{
            let multiSelection:PFMultiSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "PFMultiSelectionVC") as! PFMultiSelectionVC
            multiSelection.ques_id = currentQues.Id
            multiSelection.delegate=self
            self.present(multiSelection, animated: true, completion: nil)
            return
        }
        // levelID += 1
        if multiChoiceType == .YesNoType{
            self.saveInputInDatabase(inputText:selectedOption , track: 0, subTrack: 0)
            
        }
        else{
        self.saveInputInDatabase(inputText:selectedOption , track: trackInfo.Id, subTrack: subtrackInfo.subTrack_id)
        }
        self.ansChatBoxWithString(ansString: selectedOption)
        
        bgViewForBubbleCollection.isHidden=true
//        if (bgViewForBubbleCollection.frame.size.height>150)
//        {
//            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: (scrollView.contentOffset.y-(bgViewForBubbleCollection.frame.size.height)/4)), animated: true)
//        }
        bgViewForBubbleCollection.frame = CGRect(x:10, y: self.view.frame.size.height , width:self.view.frame.size.width-20,height:200)
       
        if hold {
        if multiChoiceType == .SubTrackType {
           // let subtrackInfo : PFSubTrackInfo = self.arrOptions.object(at: indexPath.item) as! PFSubTrackInfo
           // self.selectSubtrackNextQues(subtrackInfo: subtrackInfo)
            self.selectSubtrackNextQues()
        }
        else{
            //Open Counter
            self.showCounter()
            }
        }
        else{
        self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
        }
    }
    
   
    // MARK: - TextField Keyboard Protocol
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //  if textContainerView.frame.origin.y == screenHeight-80{
            textContainerView.frame.origin.y -= keyboardSize.height
            //scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y+(textContainerView.frame.origin.y)/2), animated: true)
            //  }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            //  if textContainerView.frame.origin.y != screenHeight-80{
//            textContainerView.frame.origin.y += keyboardSize.height
            textContainerView.frame = CGRect(x:0, y: screenHeight-80, width:screenWidth,height:80)
           // scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: (scrollView.contentOffset.y-(keyboardSize.height)/4)), animated: true)
            // }
        }
    }
    
    //#MARK:- Multiselection delegate
    func selectedSelections(options:NSArray){
        var strOptions:String = ""
        if options.count != 0 {
            for recordCount in 0...options.count-1{
                strOptions += options.object(at: recordCount) as! String
                if recordCount != options.count-1{
                    strOptions += "\n"
                }
            }
        }
        self.saveInputInDatabase(inputText:strOptions , track: 0, subTrack: 0)
        self.ansChatBoxWithString(ansString: strOptions)
        
        bgViewForBubbleCollection.isHidden=true
        self.perform(#selector(PFChatVC.goToNextQues), with: nil, afterDelay: 1.0)
    }

     //#MARK:- UITextView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars < 140;
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if inputTextView.textColor == UIColor.lightGray {
            inputTextView.text = ""
            inputTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if inputTextView.text == "" {
            
            inputTextView.text = "Enter your words ..."
            inputTextView.textColor = UIColor.lightGray
        }
    }
    // #MARK:- Gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        if (touch.view is UISlider){
            return false
        }
        return true
    }
      }
 
 extension PFChatVC:UNUserNotificationCenterDelegate{
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       

        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications

         SCLAlertView().showInfo("", subTitle: notification.request.content.body, closeButtonTitle: "Ok", duration: 0.0, colorStyle: subThemeColor, colorTextButton: textThemeColor, circleIconImage: nil, animationStyle: SCLAnimationStyle.topToBottom)
        if notification.request.identifier == requestIdentifier{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
 }
