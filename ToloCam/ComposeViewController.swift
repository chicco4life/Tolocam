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
import AVFoundation

extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}

var captureSession : AVCaptureSession?
var stillImageOutput : AVCaptureStillImageOutput?
var previewLayer : AVCaptureVideoPreviewLayer?


class ComposeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate{

    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionTextView.delegate = self
        
        // Do any additional setup after loading the view.
        
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error : NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if (error == nil && captureSession?.canAddInput(input) != nil){
            
            captureSession?.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if (captureSession?.canAddOutput(stillImageOutput) != nil){
                captureSession?.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
                
            }
            
            
        }
    
    func addImageTapped(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
        imagePicker.allowsEditing = false
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    
        self.previewImage.image = image
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        captionTextView.resignFirstResponder()
        return true;
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func composeTapped(sender: AnyObject) {
        
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let localDate = dateFormatter.stringFromDate(date)
        
        if let imageToBeUploaded = self.previewImage.image {
            let imagedata2 = imageToBeUploaded.lowQualityJPEGNSData
            
            
            let file: PFFile = PFFile(data:imagedata2) as PFFile!
            let fileCaption: String = self.captionTextView.text
            
            let photoToUpload = PFObject(className: "Posts")
            photoToUpload["Image"] = file
            photoToUpload["Caption"] = fileCaption
            photoToUpload["postedBy"] = PFUser.currentUser()!
            photoToUpload["addedBy"] = PFUser.currentUser()!.username!
            photoToUpload["date"] = localDate
            photoToUpload["Likes"] = 0
            photoToUpload["likedBy"] = [:]
            
            do { try photoToUpload.save()} catch {}
            photoToUpload.saveInBackground()
            
            let vc = TabBarInitializer.getTabBarController()
            self.presentViewController(vc, animated: true, completion: nil)
            
        } else {
            print("wauw it was nil")
            let alertController = UIAlertController(title: "Error", message: "Please upload an image first!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)

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
}