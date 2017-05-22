//
//  FriendsSearchTableviewCell.swift
//  ToloCam
//
//  Created by Federico Li on 4/22/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit

class FriendsSearchTableviewCell: UITableViewCell {
    
    var cellUsername = String()

    @IBOutlet weak var friendPicture: UIImageView!
    @IBOutlet weak var friendNickname: UILabel!
    
    override func awakeFromNib() {
        self.friendPicture.layer.masksToBounds = true
        self.friendPicture.layer.cornerRadius = self.friendPicture.frame.width/2
        self.friendPicture.contentMode = .scaleAspectFill
        
    }
    
}
