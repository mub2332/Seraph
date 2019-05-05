//
//  BlackTextField.swift
//  Seraph
//
//  Created by Musa  Mahmud on 5/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

class BlackTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 1).cgColor
        let clearButton = self.value(forKey: "_clearButton") as! UIButton
        let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        clearButton.setImage(templateImage, for: .normal)
        clearButton.setImage(templateImage, for: .highlighted)
        clearButton.backgroundColor = UIColor.darkGray
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
