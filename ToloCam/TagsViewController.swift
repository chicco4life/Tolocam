//
//  TagsViewController.swift
//  ToloCam
//
//  Created by Leo Li on 18/03/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit
import AVOSCloud

class TagsViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func appendTag(_ sender: Any) {
        if (self.searchBar.text?.characters.count)! <= 8 && (self.searchBar.text?.characters.count)! > 0{
            let query = AVQuery(className: "Tags")
            query.whereKey("tagName", equalTo: self.searchBar.text!)
            query.findObjectsInBackground({ (result:[Any]?, error:Error?) in
                if error != nil{
                    let tag = AVObject(className: "Tags")
                    tag["tagName"] = self.searchBar.text
                    tag.saveInBackground()
                }
            })
            //use delegation to pass data back after popping
            
        }else{
            let alertController = UIAlertController(title: "错误", message: "标签字数超出限制", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)

        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
