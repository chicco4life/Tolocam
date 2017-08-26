//
//  ChatsTableViewCell.swift
//  ToloCam
//
//  Created by Leo Li on 13/02/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    var userObjectId = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        
        self.unreadCountLabel.layer.cornerRadius = self.unreadCountLabel.frame.width/2
        self.unreadCountLabel.layer.masksToBounds = true
        self.unreadCountLabel.layer.backgroundColor = UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1).cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
