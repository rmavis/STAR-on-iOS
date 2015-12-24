//
//  EntryValue.swift
//  TapTest
//
//  Created by Richard Mavis on 9/28/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation

class EntryValue {

    let string: String


    init(part: String) {
        self.string = part.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }



    func match(searchString: String) -> Bool {
        // print("Checking \(string.lowercaseString) against \(searchString)")

        if (self.string.lowercaseString.rangeOfString(searchString, options: .RegularExpressionSearch) != nil) {
            return true
        }
        else {
            return false
        }
    }

}