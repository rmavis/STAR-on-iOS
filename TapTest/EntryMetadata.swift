//
//  EntryMetadata.swift
//  TapTest
//
//  Created by Richard Mavis on 12/22/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation

class EntryMetadata {


    
    
    //
    // Below this are methods and properties related to the instance.
    //
    
    
    // The metadata parts are, by position:
    // 0: date created as a timestamp
    // 1: date last accessed as a timestamp
    // 2: number of times accessed as an integer
    let pool: [String:Int]
    
    
    
    // A metadata pool can be created from a String.
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
    
}