
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
        let postsVC = storyboard.instantiateViewController(withIdentifier: "PostsNavigationController") as! UINavigationController
        postsVC.tabBarItem.title = nil
        postsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        postsVC.tabBarItem.image = UIImage(named: "home")?.withRenderingMode(.alwaysOriginal)
        postsVC.tabBarItem.selectedImage = UIImage(named: "homesel")?.withRenderingMode(.alwaysOriginal)
        let cameraVC = storyboard.instantiateViewController(withIdentifier: "CameraNavigationController") as! UINavigationController
        cameraVC.tabBarItem.title = nil
        cameraVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        cameraVC.tabBarItem.image = UIImage(named: "capture")?.withRenderingMode(.alwaysOriginal)
        cameraVC.tabBarItem.selectedImage = UIImage(named: "capturesel")?.withRenderingMode(.alwaysOriginal)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsNavigationController") as! UINavigationController
        settingsVC.tabBarItem.title = nil
        settingsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        settingsVC.tabBarItem.image = UIImage(named: "setting")?.withRenderingMode(.alwaysOriginal)
        settingsVC.tabBarItem.selectedImage = UIImage(named: "settingsel")?.withRenderingMode(.alwaysOriginal)
        let exploreVC = storyboard.instantiateViewController(withIdentifier: "ExploreNavigationController") as! UINavigationController
        exploreVC.tabBarItem.title = nil
        exploreVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        exploreVC.tabBarItem.image = UIImage(named: "explore")?.withRenderingMode(.alwaysOriginal)
        exploreVC.tabBarItem.selectedImage = UIImage(named: "exploresel")?.withRenderingMode(.alwaysOriginal)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
        profileVC.tabBarItem.title = nil
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        profileVC.tabBarItem.image = UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal)
        profileVC.tabBarItem.selectedImage = UIImage(named: "profilesel")?.withRenderingMode(.alwaysOriginal)
        
        let controllers = [
            postsVC,
            exploreVC,
            cameraVC,
            profileVC,
            settingsVC
        ]
        
        tabBarController.viewControllers = controllers
        tabBarController.restorationIdentifier = "tabBarController"
        tabBarController.tabBar.barTintColor = UIColor.white
        tabBarController.tabBar.backgroundImage = UIImage.imageWithColor(UIColor.white)
        tabBarController.tabBar.backgroundColor = UIColor.white
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        frost.frame = tabBarController.tabBar.bounds
        tabBarController.tabBar.insertSubview(frost, at: 0)
        return tabBarController
        
    }
}

extension UIImage {
    class func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
