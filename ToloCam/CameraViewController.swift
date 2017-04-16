//
//  CameraViewController.swift
//  ToloCam
//
//  Created by Federico Li on 4/30/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
//import Parse
//import ParseUI
//import Bolts
import AVFoundation
import AVOSCloud

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var imageCaptured : UIImage!
    var previewLayer : AVCaptureVideoPreviewLayer?
    var soundPath = URL(fileURLWithPath: Bundle.main.path(forResource: "meow", ofType: "wav")!)
    var shutterSound = AVAudioPlayer()
    
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "PingFangSC-Medium", size: 20)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"#232323"), for: .default)
        
        self.view.backgroundColor = UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1)
        self.view.isOpaque = false
        
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            
//            let picker = UIImagePickerController()
//            picker.delegate = self
//            picker.allowsEditing = true;  //是否可编辑
//            //摄像头
//            picker.sourceType = UIImagePickerControllerSourceType.camera
//            self.present(picker, animated: true, completion: nil)
//        }else{
//            //如果没有提示用户
////            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"你没有摄像头" delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
////            [alert show];
//        }
        
        captureSession = AVCaptureSession()
        
        //avcapture framework bug -- conditionalized code
        //        #if TARGET_IPHONE_SIMULATOR
        //        #else
        #if TARGET_OS_IPHONE
            self.captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        #endif
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
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
                
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
                 
            }
            
            
        }
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
        
//        var instanceOfImageCropView: ImageCropView = ImageCropView()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.backgroundImage = (UIImage(named:"#232323"))
        self.tabBarController?.tabBar.isTranslucent = false
    }
    
    @IBOutlet weak var tempImageView: UIImageView!
    
    @IBAction func didPressPhotoBtn(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.allowsEditing = true
//        imagePicker.navigationItem.title = "照片"
//        imagePicker.navigationBar.titleTextAttributes = [
//            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
//            NSFontAttributeName : UIFont(name: "PingFangSC-Medium", size: 20)! // Note the !
//        ]
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePicture(_ sender: AnyObject) {
        
        print("Capturing image")
        
//        do{
//            shutterSound = try AVAudioPlayer(contentsOf: soundPath)
//            shutterSound.prepareToPlay()
//        }catch let error{
//            print(error.localizedDescription)
//        }
//        
//       shutterSound.play()
        
        
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo){
            stillImageOutput!.captureStillImageAsynchronously(from: videoConnection, completionHandler: {
                (sampleBuffer, error) in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProvider(data: imageData as! CFData)
                let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                
                
                self.imageCaptured = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                imagePicker.allowsEditing = true
                
                print("passing image view")
                
            })
            
            
            
        }
        
    }
    
    func imageCropViewControllerSuccess(_ controller: UIViewController!, didFinishCroppingImage croppedImage: UIImage) {
        
        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Compose2ViewController") as! ComposeViewController
        vc.newImage = croppedImage
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        viewController.navigationItem.title = "照片"
//        viewController.navigationController?.navigationBar.barTintColor = UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1)
//        viewController.navigationController?.navigationBar.isTranslucent = false
//        viewController.view.backgroundColor = UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
//        let controller = ImageCropViewController.init(image: image)
//        controller?.delegate = self
//        controller?.blurredBackground = true
//        self.navigationController?.pushViewController(controller!, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Compose2ViewController") as! ComposeViewController
        vc.newImage = image
        self.navigationController!.pushViewController(vc, animated: true)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imageCropViewControllerDidCancel(_ controller: UIViewController!) {
        self.navigationController!.popViewController(animated: true)
    }
    
}
