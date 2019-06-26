//
//  SharePrayToCell.swift
//  Prayer
//
//  Created by Harri Westman on 7/29/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

class SharePrayToCell: UITableViewCell {

    var circle: FCircle? = nil
    
    @IBOutlet weak var lblCircleName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func resetWithCircle (_circle: FCircle?) {
        if _circle == nil {
            return
        }
        
        self.circle = _circle
        lblCircleName.text = _circle!.name
    }
}
