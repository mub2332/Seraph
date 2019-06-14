//
//  PhoneValidator.swift
//  Seraph
//
//  Created by Musa  Mahmud on 4/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import Foundation

// Convenience class for validating phone numbers
class PhoneValidator {
    class func isPhone(_ string: String) -> Bool {
        return string.isValid(regex: .phone)
    }
}
