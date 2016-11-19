//
//  ComposeViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/11/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Bolts

extension UIImage {
    var uncompressedPNGData: Data      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: Data { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: Data    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: Data     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:Data   { return UIImageJPEGRepresentation(self, 0.0)!  }
}


class ComposeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, ImageCropViewControllerDelegate{

    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var previewImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        self.hideKeyboardWhenTappedAround()
        captionTextView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        
        //#if TARGET_OS_IPHONE
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
        //#endif
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let controller = ImageCropViewController.init(image: image)
        controller?.delegate = self
        controller?.blurredBackground = true
        self.navigationController?.pushViewController(controller!, animated: true)
        
        self.dismiss(animated: true, completion: nil)
        
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
            
            
            let file: PFFile = PFFile(data:imagedata2) as PFFile!
            let fileCaption: String = self.captionTextView.text
            
            let photoToUpload = PFObject(className: "Posts")
            photoToUpload["Image"] = file
            photoToUpload["Caption"] = fileCaption
            photoToUpload["postedBy"] = PFUser.current()!
            photoToUpload["addedBy"] = PFUser.current()!.username!
            photoToUpload["date"] = localDate
            photoToUpload["Likes"] = 0
            photoToUpload["likedBy"] = [:]
            
            for _ in 0...10{
            do { try photoToUpload.save()} catch {}
            }
//            photoToUpload.saveInBackground()
            
            let vc = TabBarInitializer.getTabBarController()
            self.present(vc, animated: true, completion: nil)
            
        } else {
            print("wauw it was nil")
            let alertController = UIAlertController(title: "Error", message: "Please upload an image first!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)

        }
    }
    
    func imageCropViewControllerSuccess(_ controller: UIViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        
        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        
        self.previewImage.image = croppedImage
        self.navigationController!.popViewController(animated: true)
    }
    
    func imageCropViewControllerDidCancel(_ controller: UIViewController!) {
        self.navigationController!.popViewController(animated: true)
    }
    

}
