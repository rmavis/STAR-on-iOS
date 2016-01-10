//
//  EntryTags.swift
//  TapTest
//
//  Created by Richard Mavis on 9/28/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation

class EntryTags {
    
    
    // Give this a String and it will return an Array of Strings.
    // The Strings will be trimmed. The Array will be sorted and will contain unique values only.
    static func stringToCleanArray(messyStr: String) -> [String] {
        var cleanArr = [String]()
        
        let messyArr = messyStr.stringByReplacingOccurrencesOfString(",", withString: "\n")

        for part in messyArr.componentsSeparatedByString("\n") {
            let cleanStr = part.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if cleanStr.characters.count > 0 {
                cleanArr.append(cleanStr)
            }
        }

        return Array(Set(cleanArr)).sort {
            return $0 < $1
        }
    }

    

    
    
    //
    // Below this are methods and properties related to the instance.
    //
    
    
    let pool: [String]



    // A tags pool can be created from a String.
    // This is mostly useful when reading from the store.
    init(group: String) {
        let pool = group.componentsSeparatedByString(StoreManager.unitSeparator)

        if pool.count > 0 {
            self.pool = pool
        }
        else {
            self.pool = [ ]
        }
    }
    
    
    // Or a tags pool can be created from an array of Strings.
    // This is useful when saving a new entry from the form.
    init(group: [String]) {
        self.pool = group
    }



    func join(separator: String?) -> String {
        if let sep = separator {
            return self.pool.joinWithSeparator(sep)
        }
        else {
            return self.pool.joinWithSeparator(StoreManager.unitSeparator)
        }
    }



    func match(searchString: String) -> Bool {
        var matches: Bool = false

        for tag in self.pool {
            // print("Checking \(tag.lowercaseString) against \(searchString)")

            if (tag.lowercaseString.rangeOfString(searchString, options: .RegularExpressionSearch) != nil) {
                matches = true
            }
        }

        return matches
    }

}