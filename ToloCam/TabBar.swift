//
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
        postsVC.tabBarItem.title = "Posts"
        postsVC.tabBarItem.image = UIImage(named: "Home30")
        let cameraVC = storyboard.instantiateViewControllerWithIdentifier("CameraNavigationController") as! UINavigationController
        cameraVC.tabBarItem.title = "Camera"
        cameraVC.tabBarItem.image = UIImage(named: "Analytics30")
        let settingsVC = storyboard.instantiateViewControllerWithIdentifier("SettingsNavigationController") as! UINavigationController
        settingsVC.tabBarItem.title = "Setting"
        settingsVC.tabBarItem.image = UIImage(named: "Setting30")
        let exploreVC = storyboard.instantiateViewControllerWithIdentifier("ExploreNavigationController") as! UINavigationController
        exploreVC.tabBarItem.title = "Explore"
        exploreVC.tabBarItem.image = UIImage(named: "Home30")
        let profileVC = storyboard.instantiateViewControllerWithIdentifier("ProfileNavigationController") as! UINavigationController
        profileVC.tabBarItem.title = "Profile"
        profileVC.tabBarItem.image = UIImage(named: "Analytics30")
        
        let controllers = [
            postsVC,
            exploreVC,
            cameraVC,
            settingsVC,
            profileVC,

        ]
        
        tabBarController.viewControllers = controllers
        tabBarController.restorationIdentifier = "tabBarController"
        tabBarController.tabBar.barStyle = UIBarStyle.Default
        tabBarController.tabBar.translucent = false
        return tabBarController
        
    }
}