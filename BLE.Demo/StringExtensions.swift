//
//  StringExtensions.swift
//  Test01
//
//  Created by Jay Bergonia on 4/6/2018.
//  Copyright © 2018 Tektos Limited. All rights reserved.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(
            self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
