//
//  PFAboutMeVC.swift
//  PocketFriend
//
//  Created by Manish Parihar on 16/11/16.
//

import UIKit

class PFAboutMeVC: BaseViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource {
    
    enum ViewType : Int {
        
        case EmotionsBubbleViewType
        case DetailViewType
        case SummaryViewType
           }
   
    let padding:CGFloat = 10;
    
    var arrSummary:NSArray = NSArray()
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var vwFooter: UIView!
    @IBOutlet weak var vwSummary: UIView!
    @IBOutlet weak var tblSummary: UITableView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var vwInfo: UIView!
    @IBOutlet weak var vwEmotionBubble: UIView!
    @IBOutlet weak var lblSummary: UILabel!
     
    @IBOutlet weak var vwInfoSubContainer: UIView!
    var arrMore:NSMutableArray = NSMutableArray()

    @IBOutlet weak var btnAboutMe: UIButton!
    @IBOutlet weak var btnYou: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    var timeSpan:TimeSpan = .Last7DaysTimeSpan
    
    var currentSelectedEmotion:PFAboutEmotionsInfo!
    
    var onView:ViewType = .EmotionsBubbleViewType
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblErrorMessage: UILabel!
    var percentPixel:CGFloat = 10;
    var arrEmotions   : NSMutableArray!
    var totalRecordCount:NSInteger = 0
    
    var strChosenRange:String = ""
    
    var selectedEmotionView:UIView!
    
    @IBOutlet weak var lblChosenRange: UILabel!
    @IBOutlet weak var emotionsCollectionView: UICollectionView!
     @IBOutlet weak var timeSpanSegmentControl: UISegmentedControl!
    
    //#MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.screenDesigningOfAboutMe()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //#MARK: - ScreenDesigning
    func screenDesigningOfAboutMe(){
      
        rightHeaderButton.setTitle("Send mail", for: .normal)
        
        let view:UIButton = vwInfoSubContainer.viewWithTag(11101) as! UIButton
        view.layer.cornerRadius = 18
        
        btnYou.isUserInteractionEnabled=false
        
        emotionsCollectionView.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: ChatCollectionViewCellIdentifier)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        emotionsCollectionView!.collectionViewLayout = flowLayout
        
        let pixel:CGFloat =  emotionsCollectionView.frame.size.width/5
        //screenWidth/2  //
        percentPixel = pixel/100
        self.tblSummary.estimatedRowHeight = 100
        self.tblSummary.rowHeight = UITableViewAutomaticDimension
//         self.tblSummary.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomTableViewCell")
        self.timeSpanChanged(timeSpanSegmentControl)
    }
    //#MARK: - Operational Methods
    func calculateTotalRecordCount(){
        totalRecordCount=0
        
        for recordCount in 0...arrEmotions.count-1
        {
 let emoInfo:PFAboutEmotionsInfo =  arrEmotions.object(at: recordCount) as! PFAboutEmotionsInfo
        totalRecordCount += emoInfo.subTrack_recordCount
        }
    }
    @IBAction func timeSpanChanged(_ sender: UISegmentedControl){
        
        if timeSpanSegmentControl.selectedSegmentIndex==0{
            timeSpan = .Last7DaysTimeSpan
            strChosenRange = "last 7 days"
        }
        else  if timeSpanSegmentControl.selectedSegmentIndex==1{
            timeSpan = .Last30DaysTimeSpan
            strChosenRange = "last 30 days"
        }
        else if timeSpanSegmentControl.selectedSegmentIndex==2{
            timeSpan = .HalfYearTimeSpan
            strChosenRange = "last 6 months"
        }
        else if timeSpanSegmentControl.selectedSegmentIndex==3{
            timeSpan = .YearTimeSpan
            strChosenRange = "this year"
        }
        if arrEmotions != nil{
             arrEmotions.removeAllObjects()
        }
        
     arrEmotions = PFModelManager.getInstance().getEmotionsOfUser(userID: appDelegate.userInfo.UserID, timeSpan: timeSpan)
        
        if arrEmotions.count != 0 {
        self.calculateTotalRecordCount()
        }
        if totalRecordCount==0{
            scrollView.isHidden=true
            lblErrorMessage.isHidden=false
            btnYou.isUserInteractionEnabled=false
            btnMore.isHidden=true
        }
        else{
            scrollView.isHidden=false
            lblErrorMessage.isHidden=true
            btnMore.isHidden=true
            lblChosenRange.text = "This is what your \(strChosenRange) looks like:"
        }
        

      
        if onView == .DetailViewType {
            self.goToDetailView()
        }
        else if onView == .SummaryViewType {
            self.goToSummaryView()
        }
        else{
            emotionsCollectionView.reloadData()
        }

            GlobalSwift.animateView(transitionType: kCATransitionFade, transitionSubType: kCATransitionFromRight, view: emotionsCollectionView, duration: 0.5)
        }

    @IBAction func moreButtonClicked(_ sender: AnyObject) {
       self.goToSummaryView()
    }

   override func leftHeaderButtonClicked(_ sender: UIButton) {
    
    self.navigationController?.popToRootViewController(animated: true)

    }
   override func rightHeaderButtonClicked(_ sender: UIButton) {
    let pfShareVC:PFSendMailVC = self.storyboard?.instantiateViewController(withIdentifier: "PFSendMailVC") as! PFSendMailVC
    self.navigationController?.pushViewController(pfShareVC, animated: true)
    }
    
    @IBAction func youButtonClicked(_ sender: AnyObject) {
        if self.onView == .SummaryViewType {
            self.onView = .DetailViewType
            self.goToDetailView()
        }
        else if (self.onView == .DetailViewType) {
            self.onView = .EmotionsBubbleViewType
            self.goToEmotionView()
        }
        
    }
    func goToEmotionView(){
        btnYou.isUserInteractionEnabled=false
        vwEmotionBubble.isHidden=false;
        vwInfo.isHidden=true
        vwSummary.isHidden=true
        GlobalSwift.animateView(transitionType: kCATransitionFade, transitionSubType: kCATransitionFromBottom, view: scrollView, duration: 0.5)
    }
    func goToDetailView(){
        self.onView = .DetailViewType
        btnYou.isUserInteractionEnabled=true
        vwEmotionBubble.isHidden=true;
        vwInfo.isHidden=false
        scrollView.isHidden=false
        vwSummary.isHidden=true
        
        
//        let superView:UIView = TitleLabel.superview!
//        if superView.layer.cornerRadius != 60{
//            superView.layer.cornerRadius = 60;
//            //superView.layer.masksToBounds=true
//            
//            superView.layer.shadowColor = UIColor.black.cgColor
//            superView.layer.shadowOffset = CGSize(width: 1, height: 1)
//            superView.layer.shadowOpacity = 0.7
//            superView.layer.shadowRadius = 1.0
//            
//            let frame = superView.bounds
//            //        frame.origin.x -= 50
//            //        frame.origin.x -= 50
//            //        frame.size.height -= 20
//            //        frame.size.width -= 20
//            let gradient = GlobalSwift.gradientColor(gradientColors: [UIColor(red:141/255, green:212/255, blue:249/255, alpha:1.0),UIColor(red:10/255, green:98/255, blue:144/255, alpha:1.0)],frame:frame)
//            gradient.cornerRadius = (frame.size.height)/2
//            gradient.masksToBounds = true
//            superView.layer.insertSublayer(gradient, at: 0)
//            
//        }
        
        let stringTitle:String = currentSelectedEmotion.subTrack_description
        
        TitleLabel.text = stringTitle
        
        detailLabel.text=""
        let mutableString:NSMutableAttributedString = NSMutableAttributedString()
       // let normalFontAttribute = [NSFontAttributeName:  UIFont.systemFont(ofSize: 15)]
        let mutableString2 = NSAttributedString(string: "You felt ", attributes: [NSFontAttributeName:  UIFont.systemFont(ofSize: 15)])
         mutableString.append(mutableString2)
        
        let fontAttribute = [NSFontAttributeName:  UIFont.boldSystemFont(ofSize: 15)]
        var descDetail:String = "\(stringTitle) \(currentSelectedEmotion.subTrack_recordCount) times in \(strChosenRange).\n"

        let mutableString1 = NSAttributedString(string: descDetail, attributes: fontAttribute)
        
        detailLabel.attributedText = mutableString1
        mutableString.append(mutableString1)
      
       // var yAxis = detailLabel.frame.origin.y
        arrMore.removeAllObjects()
        arrMore = PFModelManager.getInstance().getDescriptionOfEmotion(subtrackID: currentSelectedEmotion.subTrack_id,userID: appDelegate.userInfo.UserID,timeSpan: timeSpan)
        var count=0
        if arrMore.count>0{
            count = arrMore.count-1
            if count > 1{
                count = 1
            }
            descDetail = "\nYou typically describe \(stringTitle) with words such as \n\n"
            for recordCount in 0...count
            {
                descDetail += "• "
                descDetail += arrMore.object(at: recordCount) as! String
                    descDetail += "\n\n"
                        }
          // let myAttribute = [NSForegroundColorAttributeName:  textDarkColor]
            let mutableString1 = NSAttributedString(string: descDetail, attributes: [NSForegroundColorAttributeName:textDarkColor,NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
            mutableString.append(mutableString1)
        }
        else{
            let mutableString1 = NSAttributedString(string: "\n\n", attributes: [NSForegroundColorAttributeName:textDarkColor,NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
            mutableString.append(mutableString1)
            mutableString.append(mutableString1)
        }
        
        if currentSelectedEmotion.subTrack_recordCount>=2{
            let day:String = PFModelManager.getInstance().getDayOfMaxSelectedSubtrack(subTrackID: currentSelectedEmotion.subTrack_id, userID: appDelegate.userInfo.UserID, timeSpan: timeSpan)
            
            let time:String = PFModelManager.getInstance().getTimeOfMaxSelectedSubtrack(subTrackID: currentSelectedEmotion.subTrack_id, userID: appDelegate.userInfo.UserID, timeSpan: timeSpan)
            
            let string:String = GlobalSwift.getDateFormat(dateString: time, from: "HH", to: "hh a")
           descDetail = "You feel \(stringTitle) mostly on \(day), and often around \(string)"
            
            //let myAttribute = [NSForegroundColorAttributeName:  themeColor]
              let mutableString1 = NSAttributedString(string: descDetail, attributes: [NSForegroundColorAttributeName:themeColor,NSFontAttributeName:UIFont.boldSystemFont(ofSize: 15)])
            mutableString.append(mutableString1)
        }
 detailLabel.attributedText = mutableString
    txtView.attributedText = mutableString
        print(detailLabel.attributedText)
        
        let sizeOfString:CGSize = mutableString.boundingRect(
            with: CGSize(width: detailLabel.frame.size.width, height: CGFloat.infinity),
            options: [NSStringDrawingOptions.usesDeviceMetrics,NSStringDrawingOptions.usesFontLeading,NSStringDrawingOptions.usesLineFragmentOrigin],
            context: nil).size
        detailLabel.frame = CGRect(x:detailLabel.frame.origin.x, y: detailLabel.frame.origin.y, width: detailLabel.frame.size.width, height: sizeOfString.height)
       // yAxis = detailLabel.frame.origin.y + sizeOfString.height
        
        btnMore.isHidden=true
//        if count<arrMore.count-1
//        {
//            btnMore.isHidden=false
////            var frame = btnMore.frame
////            frame.origin.y = yAxis
////            btnMore.frame = frame
////            yAxis += frame.size.height
//        }
        if arrMore.count>0{
            btnMore.isHidden=false
        }
//
//        
//        vwInfoSubContainer.frame.size.height = yAxis
//        scrollView.contentSize.height = yAxis
        
        GlobalSwift.animateView(transitionType: kCATransitionFade, transitionSubType: kCATransitionFromTop, view: vwInfo, duration: 0.5)
        
    }
    func goToSummaryView(){
        self.onView = .SummaryViewType
        btnYou.isUserInteractionEnabled=true
        vwEmotionBubble.isHidden=true;
        vwInfo.isHidden=false
        scrollView.isHidden=true
        vwSummary.isHidden=false
        
        arrSummary = PFModelManager.getInstance().getDatesOfEmotion(subtrackID: currentSelectedEmotion.subTrack_id, userID: appDelegate.userInfo.UserID, timeSpan: timeSpan)
        tblSummary.reloadData()
        tblSummary.setNeedsLayout()
        tblSummary.layoutIfNeeded()
        GlobalSwift.animateView(transitionType: kCATransitionFade, transitionSubType: kCATransitionFromTop, view: vwSummary, duration: 0.5)
        
    }
    //MARK: - Collection View Delegate & Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if arrEmotions==nil{
            return 0
        }
        return arrEmotions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell: ChatCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCollectionViewCellIdentifier, for: indexPath) as? ChatCollectionViewCell
        for view in (cell?.contentView.subviews)!{
            view.removeFromSuperview()
        }
        let  emoInfo : PFAboutEmotionsInfo = arrEmotions.object(at: indexPath.item) as! PFAboutEmotionsInfo
        cell?.initContent(optionText:emoInfo.subTrack_description,bgColor: UIColor.clear,textColor: textThemeColor,BGImage:UIImage(named:"BlueShadowedCircle"))
          return cell!;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        let cell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
      //  selectedEmotionView = collectionView.cellForItem(at: indexPath)
    
            
        let startFrame:CGRect = cell.convert(cell.bounds, to: vwEmotionBubble)
        let finalFrame:CGRect = btnYou.convert(btnYou.bounds, to: vwEmotionBubble)
        
        
        let snapShot:UIView = GlobalSwift.snapshotOfView(inputView: cell)
        snapShot.frame = startFrame
        vwEmotionBubble.addSubview(snapShot)
        
//        let center = cell.center
//        snapShot.center = center
       cell.alpha = 0.0
        

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            snapShot.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            
            }) { (Bool) in
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
                    snapShot.frame = finalFrame
                    snapShot.alpha = 0
                }) { (Bool) in
                    cell.alpha = 1
                    snapShot.removeFromSuperview()
                    self.currentSelectedEmotion = self.arrEmotions.object(at: indexPath.item) as! PFAboutEmotionsInfo
                     self.goToDetailView()
                }
        }
        
       
        //print("You selected cell #\(indexPath.item)!")
    }
     // For Setting Collection View Layout
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
//    {
//        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let  emoInfo : PFAboutEmotionsInfo = arrEmotions.object(at: indexPath.item) as! PFAboutEmotionsInfo
        let size = (emoInfo.subTrack_recordCount*100/totalRecordCount)+30
                var pix:Int =  Int(CGFloat(size) * percentPixel)+10
        if pix<60{
            pix = 60
        }
        return   CGSize(width: pix, height: pix);
    }
    
    //MARK: - Table View Delegate & Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let count:NSInteger = arrSummary.count
        return count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let objPFDetail:PFDetailObj = arrSummary.object(at: section) as! PFDetailObj
        
        let arr:NSArray = objPFDetail.arrDetails
        let count:NSInteger = arr.count
        return count
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        let objPFDetail:PFDetailObj = arrSummary.object(at: section) as! PFDetailObj
         let string:String = GlobalSwift.getDateFormat(dateString: objPFDetail.dateString, from: "yyyy-MM-dd", to: "dd MMMM yyyy")
        return string
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CustomTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomTableViewCell
       
        let objPFDetail:PFDetailObj = arrSummary.object(at: indexPath.section) as! PFDetailObj
        
        let arr:NSArray = objPFDetail.arrDetails
        let detailChildObj : PFEmotionSubDetailObj =  arr.object(at: indexPath.row) as! PFEmotionSubDetailObj
        cell.lblTitle.text = detailChildObj.descriptionString
       let string:String = GlobalSwift.getDateFormat(dateString: detailChildObj.timeString, from: "HH:mm:ss", to: "hh:mm a")
        cell.lblSubTitle.text = string
        cell.backgroundColor=UIColor.clear
        return cell
    }

}
