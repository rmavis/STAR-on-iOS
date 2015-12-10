//
//  EntryTags.swift
//  TapTest
//
//  Created by Richard Mavis on 9/28/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation

class EntryTags {

    let pool: [String]



    init(group: String) {
        let pool = group.componentsSeparatedByString(StoreManager.unitSeparator)

        if pool.count > 0 {
            self.pool = pool
        }
        else {
            self.pool = [ ]
        }
    }



    func string() -> String {
        return self.pool.joinWithSeparator(", ")
    }



    func match(searchString: String) -> Bool {
        var matches: Bool = false

        for tag in pool {
            print("Checking \(tag.lowercaseString) against \(searchString)")

            if (tag.lowercaseString.rangeOfString(searchString, options: .RegularExpressionSearch) != nil) {
                matches = true
            }
        }

        return matches
    }

}