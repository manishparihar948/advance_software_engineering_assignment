//
//  GlobalSwift.swift
//  Mag-nificent
//
//  Created by Manish Parihar on 6/4/15.
//

import UIKit

class GlobalSwift {
    
    // MARK: - Error Messages
    
    class func invalidEmaildIDFormatErrorMessage() -> String {
       return "Please provide valid email id"
    }
    class func blankEmailIDErrorMessage() -> String {
        return "Please provide email id"
    }
    class func blankPasswordErrorMessage() -> String {
       return "Please provide password"
    }
    class func invalidDigitsInPasswordErrorMessage() -> String {
        return "Password should be of minimum 5 character"
    }
    class func blankFnameErrorMessage() -> String {
        return "Please provide your first name"
    }
    class func blankLnameErrorMessage() -> String {
        return "Please provide your last name"
    }
    class func blankPhoneNumberErrorMessage() -> String {
        return "Please provide your mobile number"
    }
    class func invalidPhoneNumberErrorMessage() -> String {
        return "Please provide 10 digits mobile number"
    }
    class func blankConfirmPasswordErrorMessage() -> String {
        return "Please confirm password"
    }
    class func passwordMissMatchErrorMessage() -> String {
        return "Password miss match"
    }
    class func blankDOBErrorMessage() -> String {
        return "Please provide your date of birth"
    }
    class func networkErrorMessage() -> String {
        return "Network is either slow or not Connected"
    }
    class func invalidLoginErrorMessage() -> String {
        return "Invalid username or password"
    }
    class func blankAddressErrorMessage() -> String {
        return "Please provide your address"
    }
    class func blankStateErrorMessage() -> String {
        return "Please provide your state"
    }
    class func blankZipCodeErrorMessage() -> String {
        return "Please provide your zipcode"
    }
    class func blankCountryErrorMessage() -> String {
        return "Please provide your country"
    }
    class func blankCityErrorMessage() -> String {
        return "Please provide your city"
    }
     // MARK: - Formats
    
    class func dateStandardFormat() -> String {
        return "yyyy-MM-dd HH:mm:ss"
    }
    class func date120Format() -> String {
        return "MM/dd/yyyy hh:mm:ss a"
    }
    
    class func getDateFormat(dateString:String,from:String,to:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = from
        let date:Date = dateFormatter.date(from: dateString)!
        dateFormatter.dateFormat = to
        let string:String = dateFormatter.string(from: date)
        return string
    }
    // MARK: - String
    
    class func sentenceCase(string:String)-> String{
        if string.characters.count>0 {
            let first = String(string.characters.prefix(1)).capitalized
            let other = String(string.characters.dropFirst()).lowercased()
            return first + other

        }
        return string
            }
    
    // MARK: - Animation
    
   class func animateView(transitionType:String,transitionSubType:String,view:UIView,duration:CFTimeInterval)
    {
        let animation:CATransition = CATransition()
        animation.duration = duration
        animation.type=transitionType
        animation.subtype=transitionSubType
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        view.layer.add(animation, forKey: "Animation")
        
    }
    // MARK: - Validate
    
    class func isValidEmail(emailID:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }

    
    //MARK : - Special character checking in string
    
    class func isHavingSpecialCharacter(string:NSString) -> Bool {
        
        let set:NSCharacterSet = NSCharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890").inverted as NSCharacterSet
        if string.rangeOfCharacter(from: set as CharacterSet).location == NSNotFound    {
            //No special character exists
            return false
        }
        //special character exists
        return true
    }
 /*   // MARK: - Color
    
   class func lightGrayGradientColor() -> CAGradientLayer {
        let topColor = UIColor(red: (251/255.0), green: (251/255.0), blue: (251/255.0), alpha: 1)
        let bottomColor = UIColor(red: (234/255.0), green: (234/255.0), blue: (234/255.0), alpha: 1)
        
        let gradientColors: Array <AnyObject> = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: Array <AnyObject> = [0.0 as AnyObject, 1.0 as AnyObject]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }*/
    //Frame Selection
    
    class func gradientColor(gradientColors:[UIColor], frame:CGRect) -> CAGradientLayer {
        var colors:[CGColor] = []
        for color in gradientColors {
            colors.append(color.cgColor)
        }
         let gradientLocations = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        gradientLayer.frame = frame
        return gradientLayer
    }
    //Image
    
    class func blurWithCoreImage(sourceImage:UIImage) -> UIImage
    {
    let imageToBlur = CIImage(image: sourceImage)
    let blurfilter = CIFilter(name: "CIGaussianBlur")
    blurfilter?.setValue(imageToBlur, forKey: "inputImage")
    let resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
        let blurredImage:UIImage = UIImage(ciImage: resultImage)
    return blurredImage
    }
    
   class func snapshotOfView(inputView: UIView) -> UIView {
//    let snapshotView:UIView =  inputView.snapshotView(afterScreenUpdates: true)!
//    snapshotView.layer.shadowOpacity = 0.5;
//    snapshotView.layer.shadowRadius = 3;
//    snapshotView.layer.shadowColor = UIColor.lightGray.cgColor;
//    snapshotView.layer.shadowOffset = CGSize(width:5,height: 5);
//    return snapshotView
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }

//
//    class func blurWithCoreImage(sourceImage:UIImage) -> UIImage
//    {
//        
//  
//    let inputImage:CIImage = CIImage(CGImage: sourceImage.CGImage)
//    
//    // Apply Affine-Clamp filter to stretch the image so that it does not
//    // look shrunken when gaussian blur is applied
//        let transform:CGAffineTransform = CGAffineTransformIdentity;
//      let  clampFilter:CIFilter = CIFilter(name: "CIAffineClamp")
//        clampFilter.setValue(inputImage, forKey: "inputImage")
//        
//        clampFilter.setValue(NSValue(CGAffineTransform: transform), forKey: "inputTransform")
//     
//        
//    // Apply gaussian blur filter with radius of 30
//        let gaussianBlurFilter:CIFilter = CIFilter(name: "CIGaussianBlur")
//        gaussianBlurFilter.setValue(clampFilter.outputImage, forKey: "inputImage")
//        gaussianBlurFilter.setValue("30", forKey: "inputRadius")
//   
//        let context: CIContext  = CIContext(options: nil)
//        let cgImage : CGImageRef= context.createCGImage(gaussianBlurFilter.outputImage, fromRect: inputImage.extent())
//    // Set up output context.
//    UIGraphicsBeginImageContext(self.view.frame.size);
//       let outputContext:CGContextRef  = UIGraphicsGetCurrentContext();
//    
//    // Invert image coordinates
//    CGContextScaleCTM(outputContext, 1.0, -1.0);
//    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
//    
//    // Draw base image.
//    CGContextDrawImage(outputContext, self.view.frame, cgImage);
//    
//    // Apply white tint
//    CGContextSaveGState(outputContext);
//    CGContextSetFillColorWithColor(outputContext, [UIColor colorWithWhite:1 alpha:0.2].CGColor);
//    CGContextFillRect(outputContext, self.view.frame);
//    CGContextRestoreGState(outputContext);
//    
//    // Output image is ready.
//    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return outputImage;
//    }

}



