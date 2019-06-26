//
//  CircleTableViewCell.swift
//  Prayer
//
//  Created by Harri Westman on 7/28/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

class CircleTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCircleTitle: UILabel!
    @IBOutlet weak var lblNumberOfMembers: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func resetWithCircle (circle: FCircle?) {
        if circle == nil {
            return
        }
        
        lblCircleTitle.text = circle!.name
        lblNumberOfMembers.text = String(circle!.numberOfMembers!) + " members"
    }
}
