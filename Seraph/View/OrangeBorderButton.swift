//
//  OrangeBorderButton.swift
//  Seraph
//
//  Created by Musa  Mahmud on 4/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

class OrangeBorderButton: BorderButton {
    
    // Orange border
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.orange.cgColor
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
