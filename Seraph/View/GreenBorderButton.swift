//
//  GreenBorderButton.swift
//  Seraph
//
//  Created by Musa  Mahmud on 4/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

class GreenBorderButton: BorderButton {
    
    // Green border
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor(red: 85/255, green: 186/255, blue: 85/255, alpha: 1).cgColor
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
