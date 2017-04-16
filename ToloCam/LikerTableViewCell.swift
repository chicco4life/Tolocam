//
//  LikerTableViewCell.swift
//  ToloCam
//
//  Created by Leo Li on 18/03/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit

class LikerTableViewCell: UITableViewCell {

    @IBOutlet weak var likeName: UILabel!
    @IBOutlet weak var likes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
