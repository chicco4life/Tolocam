//
//  CameraViewController.swift
//  ToloCam
//
//  Created by Federico Li on 4/30/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Bolts
import AVFoundation


class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var imageCaptured : UIImage!
    var previewLayer : AVCaptureVideoPreviewLayer?
    var audioPlayer:AVAudioPlayer!
    
    
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = true
        
        
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
                
                
                
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
                
                
                
            }
            
            
        }
        
        
    }
    
    @IBOutlet weak var tempImageView: UIImageView!
    
    
    @IBAction func takePicture(sender: AnyObject) {
        
        print("Capturing image")
        
//        let path = NSBundle.mainBundle().pathForResource("meow.mp3", ofType:nil)!
//        let url = NSURL(fileURLWithPath: path)
//        
//        do {
//            let sound = try AVAudioPlayer(contentsOfURL: url)
//            audioPlayer = sound
//            sound.play()
//        } catch {
//            // couldn't load file :(
//        }
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo){
            stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer, error) in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProviderCreateWithCFData(imageData)
                let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                
                
                self.imageCaptured = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                
                print("passing image view")
                //self.tempImageView.image = imageCaptured
                //self.tempImageView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.width)
                
                //imageView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.width)
                
                //Show the captured image to
                //self.view.addSubview(imageView)
                
                //Save the captured preview to image
                
                UIImageWriteToSavedPhotosAlbum(self.imageCaptured, nil, nil, nil)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("Compose2ViewController") as! Compose2ViewController
                vc.newImage = self.imageCaptured
                self.navigationController!.pushViewController(vc, animated: true)
                print("image saved")
                
                
                
            })
            
            
            
        }
        
    }
    
    
    
    
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //
    //        if segue.identifier == "toCompose" {
    //            let dvc = segue.sourceViewController as! Compose2ViewController
    //            dvc.newImage = self.imageCaptured
    //        }
    //    }
    //    
    
    
}