//
//  UserDefaults.swift
//  Seraph
//
//  Created by Musa  Mahmud on 23/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import Foundation
import Intents

let userDefault = UserDefaults.standard

func writeData(forKey key: String, withValue value: Any) {
    userDefault.set(value, forKey: key)
}

func readStringData(forKey key: String) -> String {
    if userDefault.object(forKey: key) == nil {
        return ""
    } else {
        return userDefault.string(forKey: key)!
    }
}

func removeData(forKey key: String) {
    userDefault.removeObject(forKey: key)
}
