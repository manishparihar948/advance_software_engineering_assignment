//
//  ChatCollectionViewCell.swift
//  PocketFriend
//
//  Created by Manish Parihar on 28/11/16.
//

import UIKit

let ChatCollectionViewCellIdentifier = "ChatCollectionViewCellIdentifier"
//let font:UIFont = UIFont.boldSystemFont(ofSize: 18)
class ChatCollectionViewCell: UICollectionViewCell {
    
    
    lazy var textContent: UILabel! = {
        let textContent = UILabel(frame: CGRect.zero)
        textContent.minimumScaleFactor = 8/14;
        textContent.adjustsFontSizeToFitWidth = true;
        //textContent.layer.cornerRadius = 25
       // textContent.layer.borderWidth = 2
        //textContent.layer.borderColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1).cgColor
        textContent.font = font14
        textContent.textAlignment = NSTextAlignment.center
        return textContent
    }()
    
    func initContent(optionText:String, bgColor:UIColor, textColor:UIColor,BGImage:UIImage?=nil) {
        if let image:UIImage = BGImage{
            let bgImage:UIImageView = UIImageView(image:image)
            bgImage.frame = CGRect(x:0, y: 0, width:self.frame.size.width,height:self.frame.size.height)
            bgImage.contentMode=UIViewContentMode.scaleAspectFit
            self.contentView.addSubview(bgImage)
        }
        else{
           self.contentView.backgroundColor=bgColor
        }
        self.contentView.addSubview(textContent)
        textContent.text = optionText
        
        textContent.textColor=textColor
        textContent.sizeToFit()
        let frame:CGRect = CGRect(x:5,y:5,width:self.frame.size.width-10,height:self.frame.size.height-10)
        textContent.frame = frame
       // textContent.frame.size.height = self.frame.size.height
                //textContent.backgroundColor = UIColor.clear
    }
    
    
    func animateSelection() {
         
        self.textContent.frame.size = CGSize(width: self.textContent.frame.size.width - 20, height: self.textContent.frame.size.height - 20)
        self.textContent.frame.origin = CGPoint(x: self.textContent.frame.origin.x + 10, y: self.textContent.frame.origin.y + 10)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
        
            self.textContent.frame.size = CGSize(width:self.textContent.frame.size.width + 20,height: self.textContent.frame.size.height + 20)
            self.textContent.center = CGPoint(x:self.contentView.frame.size.width / 2,y: self.contentView.frame.size.height / 2)
            }, completion: nil)
    }
    
    class func contentHeight(_ content: String) -> CGSize {
        let styleText = NSMutableParagraphStyle()
        styleText.alignment = NSTextAlignment.center
        let attributs = [NSParagraphStyleAttributeName:styleText, NSFontAttributeName:font16]
        let sizeBoundsContent = (content as NSString).boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width,
                                                                                height: UIScreen.main.bounds.size.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributs, context: nil)
        return CGSize(width: sizeBoundsContent.width + 10, height: sizeBoundsContent.height + 10)
    }
}
