//
//  MultiSelectionCell.swift
//  PocketFriend
//
//  Created by Manish Parihar on 02/12/16.
//

import UIKit
let MultiSelectionCellIdentifier = "MultiSelectionCellIdentifier"
let font16:UIFont = UIFont.systemFont(ofSize: 16)
let font14:UIFont = UIFont.systemFont(ofSize: 14)
class MultiSelectionCell: UICollectionViewCell {

    
    lazy var lblTitle: UILabel! = {
        let lblTitle = UILabel(frame: CGRect.zero)
        
       // lblTitle.textAlignment = .center
        
        lblTitle.font = font14
        return lblTitle
    }()
    lazy var btnDelete: UIButton! = {
        let btnDelete = UIButton(type: UIButtonType.custom)
        
      btnDelete.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
       btnDelete.setTitle("x", for: .normal)
        return btnDelete
    }()

    
    func initContent(optionText:String, btnColor:UIColor, crossColor:UIColor,textColor:UIColor) {
        self.contentView.addSubview(lblTitle)
        self.contentView.addSubview(btnDelete)
//        self.contentView.layer.borderColor=btnColor.cgColor
//        self.contentView.layer.borderWidth = 1.0
        self.contentView.backgroundColor = btnColor
        self.contentView.layer.cornerRadius = 6;
        self.contentView.layer.masksToBounds=true
       
        lblTitle.text = optionText
        lblTitle.textColor=textColor
        lblTitle.lineBreakMode = .byCharWrapping
        lblTitle.numberOfLines = 0
        lblTitle.minimumScaleFactor = 8;
        lblTitle.adjustsFontSizeToFitWidth = true;
        lblTitle.frame.origin.x = 10
        lblTitle.frame.size.width = self.frame.size.width-20
        lblTitle.frame.size.height = self.frame.size.height
        
        btnDelete.frame.size.width = 30
        btnDelete.frame.size.height = self.frame.size.height
        btnDelete.frame.origin.x = self.frame.size.width-30
        btnDelete.setTitleColor(crossColor, for: .normal)
        //textContent.backgroundColor = UIColor.clear
    }

    
    class func contentHeight(content: String, width:CGFloat) -> CGSize {
        let styleText = NSMutableParagraphStyle()
        //styleText.alignment = NSTextAlignment.center
        let attributs = [NSParagraphStyleAttributeName:styleText, NSFontAttributeName:font14] as [String : Any]
        let sizeBoundsContent = (content as NSString).boundingRect(with: CGSize(width: width,
                                                                                height: UIScreen.main.bounds.size.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributs, context: nil)
        return CGSize(width: sizeBoundsContent.width + 50, height: sizeBoundsContent.height + 20)
    }
}
