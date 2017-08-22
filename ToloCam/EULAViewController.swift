//
//  EULAViewController.swift
//  ToloCam
//
//  Created by Leo Li on 11/08/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit

class EULAViewController: UIViewController {
    
    @IBOutlet weak var EULATextView: UITextView!
    @IBOutlet weak var okButton: UIButton!
    var fromSettings = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.EULATextView.layer.borderWidth = 1
        self.EULATextView.layer.borderColor = UIColor.white.cgColor
        
        self.okButton.layer.cornerRadius = self.okButton.frame.height/2
        self.okButton.layer.borderWidth = 4
        self.okButton.layer.borderColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        self.okButton.addTarget(self, action: #selector(__buttonHighlight), for: .touchDown)
        self.okButton.addTarget(self, action: #selector(__buttonNormal), for: .touchUpInside)
        self.okButton.addTarget(self, action: #selector(__buttonNormal), for: .touchUpOutside)
        
        // Do any additional setup after loading the view.
    }
    
    func __buttonHighlight(){
        self.okButton.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.3)
        self.okButton.layer.borderWidth = 0
    }
    
    func __buttonNormal(){
        self.okButton.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0)
        self.okButton.layer.borderWidth = 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ok(_ sender: Any) {
        if fromSettings{
            self.dismiss(animated: true, completion: nil)
        }else{
            let vc = TabBarInitializer.getTabBarController()
            self.present(vc, animated: true, completion: nil)
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
