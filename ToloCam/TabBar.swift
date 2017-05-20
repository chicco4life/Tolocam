
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
        postsVC.tabBarItem.title = "关注"
//        postsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        postsVC.tabBarItem.image = UIImage(named: "home")?.withRenderingMode(.alwaysOriginal)
        postsVC.tabBarItem.selectedImage = UIImage(named: "homesel")?.withRenderingMode(.alwaysOriginal)
        let cameraVC = storyboard.instantiateViewController(withIdentifier: "CameraNavigationController") as! UINavigationController
        cameraVC.tabBarItem.title = "拍摄"
//        cameraVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        cameraVC.tabBarItem.image = UIImage(named: "takePicture")?.withRenderingMode(.alwaysOriginal)
        cameraVC.tabBarItem.selectedImage = UIImage(named: "takePictureSel")?.withRenderingMode(.alwaysOriginal)
        let chatsVC = storyboard.instantiateViewController(withIdentifier: "ChatsNavigationController") as! UINavigationController
        chatsVC.tabBarItem.title = "消息"
//        chatsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        chatsVC.tabBarItem.image = UIImage(named: "chat")?.withRenderingMode(.alwaysOriginal)
        chatsVC.tabBarItem.selectedImage = UIImage(named: "chatsel")?.withRenderingMode(.alwaysOriginal)
        let exploreVC = storyboard.instantiateViewController(withIdentifier: "ExploreNavigationController") as! UINavigationController
        exploreVC.tabBarItem.title = "发现"
//        exploreVC.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        exploreVC.tabBarItem.image = UIImage(named: "explore")?.withRenderingMode(.alwaysOriginal)
        exploreVC.tabBarItem.selectedImage = UIImage(named: "exploresel")?.withRenderingMode(.alwaysOriginal)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
        profileVC.tabBarItem.title = "我的"
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 1, left: 0, bottom: -1, right: 0)
        profileVC.tabBarItem.image = UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal)
        profileVC.tabBarItem.selectedImage = UIImage(named: "profilesel")?.withRenderingMode(.alwaysOriginal)
        
        let controllers = [
            postsVC,
            exploreVC,
            cameraVC,
            chatsVC,
            profileVC
        ]
        
        tabBarController.viewControllers = controllers
        tabBarController.restorationIdentifier = "tabBarController"
        tabBarController.tabBar.barTintColor = UIColor.white
        tabBarController.tabBar.backgroundImage = UIImage.imageWithColor(UIColor.white)
        tabBarController.tabBar.backgroundColor = UIColor.white
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
