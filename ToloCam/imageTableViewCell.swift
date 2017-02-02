//
//  imageTableViewCell.swift
//  ToloCam
//
//  Created by Federico Li on 2/17/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
//import ParseUI

class imageTableViewCell: UITableViewCell {
    
    let postImageView = UIImageView()
    let cellData = UIView()
    
    let postCaption = UILabel()
    let addedBy = UILabel()
    let dateLabel = UILabel()

    init (style: UITableViewCellStyle, reuseIdentifier: String?, height: CGSize) {
    super.init (style: style, reuseIdentifier: reuseIdentifier)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postCaption.translatesAutoresizingMaskIntoConstraints = false
        addedBy.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        cellData.translatesAutoresizingMaskIntoConstraints = false
        
        
        postImageView.backgroundColor = UIColor.red
        cellData.backgroundColor = UIColor.blue
        
        contentView.addSubview(postImageView)
        contentView.addSubview(cellData)
        cellData.addSubview(addedBy)
        cellData.addSubview(dateLabel)
        cellData.addSubview(postCaption)
        
        let viewdic =
        [
        "postImageView": postImageView,
        "cellData" : cellData,
        "addedBy" : addedBy,
        "dateLabel" : dateLabel,
        "postCaption" : postCaption
        ]
        
        let metrics =
        [
            "toppadding":0,
            "celldataheight": 100,
            "imageheight": height.height
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[postImageView]|", options: [], metrics: metrics, views: viewdic))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[postImageView(imageheight)][cellData(celldataheight)]|", options: [], metrics: metrics, views: viewdic))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cellData]|", options: [], metrics: metrics, views: viewdic))
        
        cellData.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[addedBy][dateLabel(==addedBy)]|", options: [], metrics: metrics, views: viewdic))
        
        cellData.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[addedBy][postCaption]|", options: [], metrics: metrics, views: viewdic))
        
        cellData.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dateLabel][postCaption]|", options: [], metrics: metrics, views: viewdic))
        
        cellData.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[postCaption]|", options: [], metrics: metrics, views: viewdic))
        
    }
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
   

}

