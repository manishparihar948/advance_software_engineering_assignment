//
//  LoadingView.swift
//  Mag-nificent
//
//  Created by Manish Parihar on 12/06/15.
//

import UIKit

class LoadingView: UIView {

    var activityIndicator:UIActivityIndicatorView=UIActivityIndicatorView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadingDesigning()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.loadingDesigning()
    }
   
    func loadingDesigning()
    {
        self.isUserInteractionEnabled=false
        self.backgroundColor=UIColor(white: 0, alpha: 0.4)
//        var width:CGFloat=self.frame.size.width
//        var height:CGFloat = self.frame.size.height
        
        let centerPoint:CGPoint=self.center
        let xAxis=centerPoint.x-50
        let yAxis=centerPoint.y-50
        
        let viewHud : UIView=UIView(frame: CGRect(x:xAxis,y:yAxis, width:100,height:100))
        viewHud.backgroundColor=UIColor(white: 0.0, alpha: 0.8)
        viewHud.layer.cornerRadius=10;
    

        
        activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyle.gray
        activityIndicator.color=UIColor.white
        activityIndicator.frame=CGRect(x:40,y:40, width:20,height:20)
        activityIndicator.hidesWhenStopped=true;
        viewHud.addSubview(activityIndicator)
        
        let lblLoading:UILabel = UILabel(frame: CGRect(x:0,y:65, width:100,height:20) )
        lblLoading.text = "Loading..."
        lblLoading.textAlignment = NSTextAlignment.center
        lblLoading.textColor = UIColor.white
        viewHud.addSubview(lblLoading)
        
        self.addSubview(viewHud)
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
