//
//  AppDelegate.swift
//  ToloCam
//
//  Created by Federico Li on 2/11/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import CoreData
import AVOSCloud
import UserNotifications

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    } }

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AVOSCloud.setApplicationId("TCldgsnzV2zm3EjofgYn20U3-gzGzoHsz",clientKey: "NOTBs0QwYRx242mzzzV7eEv6")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if (AVUser.current() != nil){
            let vc = TabBarInitializer.getTabBarController()
            self.window!.rootViewController = vc
        }else{
            let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            self.window!.rootViewController = vc
        }
        
        self.window!.makeKeyAndVisible()
        
        //push notifications
        let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        
        self.__registerForRemoteNotifications()

        UINavigationBar.appearance().tintColor = UIColor(red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "PingFangSC-Light", size: 17)!], for: .normal)
        UITabBar.appearance().tintColor = UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 1)
        return true
    }
    
    func __registerForRemoteNotifications(){
        if Double(UIDevice.current.systemVersion)! >= 10.0 {
            // 使用 UNUserNotificationCenter 来管理通知
            let uncenter = UNUserNotificationCenter.current()
            // 监听回调事件
            uncenter.delegate = self
            //iOS10 使用以下方法注册，才能得到授权
            uncenter.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: { (done:Bool, error:Error?) in
                UIApplication.shared.registerForRemoteNotifications()
                done ? print("authorized") : print("not authorized")
            })
            // 获取当前的通知授权状态, UNNotificationSettings
            uncenter.getNotificationSettings(completionHandler: { (settings:UNNotificationSettings) in
                if settings.authorizationStatus == UNAuthorizationStatus.notDetermined{
                    print("authorization status undetermined")
                }else if settings.authorizationStatus == UNAuthorizationStatus.denied{
                    print("authorization status denied")
                }else if settings.authorizationStatus == UNAuthorizationStatus.authorized{
                    print("authorization status authorized")
                }
            })
        }
    }
    
    func __showCameraView(){
        if let rootViewController = window?.rootViewController {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cameraController") as! CameraViewController
            rootViewController.present(viewController, animated: true, completion: nil)
        }
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AVOSCloud.handleRemoteNotifications(withDeviceToken: deviceToken)
        print(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        //register for remote notifications
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //remote
        let userInfo = notification.request.content.userInfo
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.superclass()!))!{
        }else{
            //local pushes
        }
        completionHandler(UNNotificationPresentationOptions.badge)
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.superclass()!))!{
        }else{
            //local
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "li.federico.ToloCam" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "ToloCam", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}
