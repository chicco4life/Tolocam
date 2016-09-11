
//  TabBarInitializer.swift
//  EtchIQ
//
//  Created by Michael Jianxiong Zhu on 1/3/16.
//  Copyright © 2016 Michael Jianxiong Zhu. All rights reserved.
//

import Foundation
import UIKit

class TabBarInitializer {
    static func getTabBarController() -> UITabBarController {
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = UITabBarController()
        let postsVC = storyboard.instantiateViewControllerWithIdentifier("PostsNavigationController") as! UINavigationController
        postsVC.tabBarItem.title = nil
        postsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        postsVC.tabBarItem.image = UIImage(named: "home")?.imageWithRenderingMode(.AlwaysOriginal)
        postsVC.tabBarItem.selectedImage = UIImage(named: "homesel")?.imageWithRenderingMode(.AlwaysOriginal)
        let cameraVC = storyboard.instantiateViewControllerWithIdentifier("CameraNavigationController") as! UINavigationController
        cameraVC.tabBarItem.title = nil
        cameraVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        cameraVC.tabBarItem.image = UIImage(named: "capture")?.imageWithRenderingMode(.AlwaysOriginal)
        cameraVC.tabBarItem.selectedImage = UIImage(named: "capturesel")?.imageWithRenderingMode(.AlwaysOriginal)
        let settingsVC = storyboard.instantiateViewControllerWithIdentifier("SettingsNavigationController") as! UINavigationController
        settingsVC.tabBarItem.title = nil
        settingsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        settingsVC.tabBarItem.image = UIImage(named: "setting")?.imageWithRenderingMode(.AlwaysOriginal)
        settingsVC.tabBarItem.selectedImage = UIImage(named: "settingsel")?.imageWithRenderingMode(.AlwaysOriginal)
        let exploreVC = storyboard.instantiateViewControllerWithIdentifier("ExploreNavigationController") as! UINavigationController
        exploreVC.tabBarItem.title = nil
        exploreVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        exploreVC.tabBarItem.image = UIImage(named: "explore")?.imageWithRenderingMode(.AlwaysOriginal)
        exploreVC.tabBarItem.selectedImage = UIImage(named: "exploresel")?.imageWithRenderingMode(.AlwaysOriginal)
        let profileVC = storyboard.instantiateViewControllerWithIdentifier("ProfileNavigationController") as! UINavigationController
        profileVC.tabBarItem.title = nil
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        profileVC.tabBarItem.image = UIImage(named: "profile")?.imageWithRenderingMode(.AlwaysOriginal)
        profileVC.tabBarItem.selectedImage = UIImage(named: "profilesel")?.imageWithRenderingMode(.AlwaysOriginal)
        
        let controllers = [
            postsVC,
            exploreVC,
            cameraVC,
            profileVC,
            settingsVC,

        ]
        
        tabBarController.viewControllers = controllers
        tabBarController.restorationIdentifier = "tabBarController"
//        tabBarController.tabBar.translucent = true
        tabBarController.tabBar.barTintColor = UIColor.whiteColor()
        tabBarController.tabBar.backgroundImage = UIImage.imageWithColor(UIColor.whiteColor())
        tabBarController.tabBar.backgroundColor = UIColor.whiteColor()
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        frost.frame = tabBarController.tabBar.bounds
        tabBarController.tabBar.insertSubview(frost, atIndex: 0)
        return tabBarController
        
    }
}

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}