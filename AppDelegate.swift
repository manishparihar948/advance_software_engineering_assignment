
//
//  AppDelegate.swift
//  PocketFriend
//
//  Created by Manish Parihar on 24/10/16.
//

import UIKit
import Fabric
import Crashlytics
let WentInBackgroundState = Notification.Name("WentInBackgroundState")
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let pfSync:PFSyncData = PFSyncData()
    var loadingView:LoadingView!

    var  userInfo : PFUserInfo!
//    var userIDString : String = ""
//    var name : String = ""
//    
//    var pf_userNameString : String = String()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        // Override point for customization after application launch.
        
        // Fabric
        Fabric.with([Crashlytics.self])
        
        // Database
        PFUtility.copyFile("PocketFriend.sqlite")
    
        let screenRect:CGRect = UIScreen.main.bounds
        let screenHeight:CGFloat = screenRect.size.height
        let screenWidth:CGFloat = screenRect.size.width
        loadingView=LoadingView(frame: CGRect(x:0, y:0, width:screenWidth, height:screenHeight))

        let defaults = UserDefaults.standard
        let firstLaunch:Bool = defaults.bool(forKey: "alreadyLaunched")
        if !firstLaunch {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = GlobalSwift.dateStandardFormat()
            let date:String = dateFormatter.string(from: Date())
            defaults.set(date, forKey: lastSyncDateTime)
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
       // return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        let state:UIApplicationState = UIApplication.shared.applicationState
        switch (state) {
        case UIApplicationState.active:
            /* ... */
            break;
        case UIApplicationState.inactive:
            /* Device was/is locked  */
            break;
        case UIApplicationState.background:
            /* User pressed home button or opened another App (from an alert/email/etc) */
            NotificationCenter.default.post(name: WentInBackgroundState, object: nil)
            break;
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let userDetail:PFUserInfo = userInfo{
        DispatchQueue.main.async {
            
   self.pfSync.syncData(userID: userDetail.UserID)
        }
        }
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(
            app,
            open: url as URL!,
            sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
            annotation: options[UIApplicationOpenURLOptionsKey.annotation]
        )
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation
        )
    }
    
    // MARK: - LoadingView
    
    func addLoadingView() {
        
        if self.loadingView!.isDescendant(of: self.window!){
            self.loadingView!.activityIndicator.stopAnimating()
            self.loadingView!.removeFromSuperview()
        }
        //dispatch_get_main_queue().asynchronously() {+
        DispatchQueue.main.async {
            self.window!.addSubview(self.loadingView!)
            self.loadingView!.activityIndicator.startAnimating()
        }
        //}
        
    }
    
    func removeLoadingView() {
        
        if self.loadingView!.isDescendant(of: self.window!){
            self.loadingView!.activityIndicator.stopAnimating()
            self.loadingView!.removeFromSuperview()
        }
    }
    
        // MARK: - Local Notification
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        print(notificationSettings.types.rawValue)
    }
    
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // Do something serious in a real app.
        print("Received Local Notification:")
        print(notification.alertBody)
        SCLAlertView().showInfo("", subTitle: notification.alertBody!, closeButtonTitle: "Ok", duration: 0.0, colorStyle: subThemeColor, colorTextButton: textThemeColor, circleIconImage: nil, animationStyle: SCLAnimationStyle.topToBottom)
    }

}

