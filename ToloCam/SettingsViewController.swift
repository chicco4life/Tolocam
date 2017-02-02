//
//  SettingsViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/17/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
import AVOSCloud

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func logOutTapped(_ sender: AnyObject) {
        
        AVUser.logOut()
        
        print("Successfully logged out")
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginVC")
        self.present(vc!, animated: true, completion: nil)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
