//
//  PFMultiSelectionVC.swift
//  PocketFriend
//
//  Created by Manish Parihar on 02/12/16.
//

import UIKit

@objc protocol PFMultiSelectionVCDelegate{
    @objc optional func selectedSelections(options:NSArray)
}
class PFMultiSelectionVC: BaseViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    var delegate: PFMultiSelectionVCDelegate?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tblList: UITableView!
       @IBOutlet weak var doneClicked: UIButton!
    
    var ques_id:NSInteger = 0
    var arrayOfChoices:NSMutableArray = NSMutableArray()
    var arrItems:NSArray = NSArray()
    
     //MARK: - View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenDesigningOfSelectionVC()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
        //MARK: - Screen Designing Methods
    
    func screenDesigningOfSelectionVC(){
        rightHeaderButton.setTitle("Done", for: .normal)
        collectionView.register(MultiSelectionCell.self, forCellWithReuseIdentifier: MultiSelectionCellIdentifier)
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector( PFMultiSelectionVC.handleLongGesture(gesture:))))
        self.getItems()
    }
    //MARK: - Operational Methods
    override func leftHeaderButtonClicked(_ sender: UIButton) {
        if((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: nil)
        }
    }
      override func rightHeaderButtonClicked(_ sender: UIButton) {
//        delegate?.selectedSelections!(options:arrayOfChoices)
//        if((self.presentingViewController) != nil){
//            self.dismiss(animated: true, completion: nil)
//        }
        if(arrayOfChoices.count == 0)
        {
        SCLAlertView().showInfo("", subTitle: "Please add atleast one choice", closeButtonTitle: "Ok", duration: 0.0, colorStyle: subThemeColor, colorTextButton: textThemeColor, circleIconImage: nil, animationStyle: SCLAnimationStyle.topToBottom)
        }
        else
        {
            delegate?.selectedSelections!(options:arrayOfChoices)
            if((self.presentingViewController) != nil){
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func textEditingDone(_ sender: AnyObject) {
        textField.resignFirstResponder()
    }
    func getItems() {
        arrItems = PFModelManager.getInstance().getOption(ofQuesID: ques_id)
        tblList.reloadData()
    }
    @IBAction func addButtonClicked(_ sender: AnyObject) {
        if textField.text?.characters.count==0 {
              SCLAlertView().showInfo("", subTitle: "Please add your choice", closeButtonTitle: "Ok", duration: 0.0, colorStyle: subThemeColor, colorTextButton: textThemeColor, circleIconImage: nil, animationStyle: SCLAnimationStyle.topToBottom)
        }
        else{
            self.addChoice(choice: textField.text!)
            textField.text=""
            }
    }
    func addChoice(choice:String){
        if arrayOfChoices.count>=5{
             SCLAlertView().showInfo("", subTitle: "Select maximum 5 choices in order of priority?", closeButtonTitle: "Ok", duration: 0.0, colorStyle: subThemeColor, colorTextButton: textThemeColor, circleIconImage: nil, animationStyle: SCLAnimationStyle.topToBottom)
        }
        else{
            if arrayOfChoices.contains(choice){
                SCLAlertView().showInfo("", subTitle: "Already exists in your list.", closeButtonTitle: "Ok", duration: 0.0, colorStyle: subThemeColor, colorTextButton: textThemeColor, circleIconImage: nil, animationStyle: SCLAnimationStyle.topToBottom)
                }
            else{
            arrayOfChoices.add(choice)
            collectionView.reloadData()
        }
        }
 
    }
    func deleteButtonClicked(_ sender: UIButton){
        let tag=sender.tag
        arrayOfChoices.removeObject(at: tag)
        collectionView.reloadData()
    }
    
    //MARK: - Gestures Methods
    func handleLongGesture(gesture: UILongPressGestureRecognizer)
    {
        
        switch(gesture.state)
        {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView!.indexPathForItem(at: gesture.location(in: self.collectionView)) else
            {
                break
            }
            collectionView!.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionView!.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionView!.endInteractiveMovement()
        default:
            collectionView!.cancelInteractiveMovement()
        }
    }

    //MARK: - Table View Delegate & Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrItems.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellIdentifier")
        
        cell?.textLabel?.text = arrItems.object(at: indexPath.row) as? String
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.addChoice(choice: arrItems.object(at: indexPath.row) as! String)
      //  print("You selected cell #\(indexPath.row)!")
    }
//MARK: - Collection View Delegate & Data Source

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrayOfChoices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell: MultiSelectionCell? = collectionView.dequeueReusableCell(withReuseIdentifier: MultiSelectionCellIdentifier, for: indexPath) as? MultiSelectionCell
        let choice : String = self.arrayOfChoices.object(at: indexPath.item) as! String
        cell?.initContent(optionText: choice,btnColor: themeColor, crossColor: subThemeColor,textColor:textThemeColor)
        cell?.btnDelete.tag = indexPath.item
        cell?.btnDelete.addTarget(self, action:#selector(PFMultiSelectionVC.deleteButtonClicked(_:)), for: .touchUpInside)
        return cell!;
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
//    {
//        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                if (indexPath as NSIndexPath).item < arrayOfChoices.count {
                    
                        let choice : String = self.arrayOfChoices.object(at: indexPath.item) as! String
                    return MultiSelectionCell.contentHeight(content:choice,width:collectionView.frame.size.width-10)
                    }
        return CGSize(width: 60, height: 35)
    }
   
   /*  public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool{
        return true
     }*/
    
    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath){
        let choice : String = self.arrayOfChoices.object(at: sourceIndexPath.item) as! String
        arrayOfChoices.removeObject(at: sourceIndexPath.item)
        arrayOfChoices.insert(choice, at: destinationIndexPath.item)
        collectionView.reloadData()
    }
}
