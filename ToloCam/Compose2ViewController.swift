//
//  ComposeViewController.swift
//  ToloCam
//
//  Created by Federico Li on 4/30/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
//import Parse
//import ParseUI
//import Bolts
import LeanCloud
import AVOSCloud
import AVFoundation

//extension UIImage {
//    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
//    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
//    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
//    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
//    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
//    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
//}



class Compose2ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate{
    
    
    
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var previewImage: UIImageView!
    var newImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        captionTextView.delegate = self
        
        print("loading compose2 preview image")
        previewImage.image = newImage
        print("compose2 preview image loaded")
        
        
        
        // Do any additional setup after loading the view.
    }
    
    //    override func viewDidAppear(animated: Bool) {
    //        super.viewDidAppear(animated)
    //        previewImage.image = newImage
    //
    //        // Do any additional setup after loading the view.
    //    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        captionTextView.resignFirstResponder()
        return true;
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func composeTapped(_ sender: AnyObject) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.short
        let localDate = dateFormatter.string(from: date)
        if let imageToBeUploaded = self.previewImage.image {
            let imagedata2 = imageToBeUploaded.lowQualityJPEGNSData
            
            
            let file = AVFile(data:imagedata2) as AVFile!
            let fileCaption: LCString = LCString(self.captionTextView.text)
            
            let photoToUpload = AVObject(className: "Posts")
            photoToUpload["Image"] = file
            photoToUpload["Caption"] = fileCaption.stringValue
            photoToUpload["postedBy"] = LCUser.current
            photoToUpload["addedBy"] = LCUser.current?.username!
            photoToUpload["date"] = localDate
            photoToUpload["Likes"] = 0
            photoToUpload["likedBy"] = [:]
            
            
            // background save
            //UIActivityIndicatorView spinning effect
            photoToUpload.saveInBackground({ (done:Bool, error:Error?) in
                if done{
                    let vc = TabBarInitializer.getTabBarController()
                    self.present(vc, animated: true, completion: nil)}
                else{
                    print(error)
                }
            })
            
            let vc = TabBarInitializer.getTabBarController()
            self.present(vc, animated: true, completion: nil)
            
        } else {
            print("wauw it was nil")
            let alertController = UIAlertController(title: "Error", message: "Please upload an image first!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
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
    
}
