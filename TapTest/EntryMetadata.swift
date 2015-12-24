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
    // The pool's values can be accessed through methods, not directly.
    private var pool = [Int]()

    
    func dateCreated() -> Int {
        return Int(self.pool[0])
    }
    
    func dateAccessed() -> Int {
        return Int(self.pool[1])
    }
    
    func accessCount() -> Int {
        return Int(self.pool[2])
    }
    
    
    
    func setDateCreated(date: Int = Int(NSDate().timeIntervalSince1970)) -> Int {
        self.pool[0] = date
        return date
    }
    
    
    func setDateAccessed(date: Int = Int(NSDate().timeIntervalSince1970)) -> Int {
        self.pool[1] = date
        return date
    }
    
    
    func setAccessCount(count: Int = 0) -> Int {
        self.pool[2] = count
        return count
    }
    
    
    
    // A metadata pool can be created from a String.
    // This is mostly useful when reading from the store.
    init(group: String) {
        let parts = group.componentsSeparatedByString(StoreManager.unitSeparator)
        
        if parts.count > 0 {
            self.pool = poolFromParts(parts)
        }
        else {
            self.pool = poolFromParts([ ])
        }
    }
    
    
    // Or a tags pool can be created from an array of Strings.
    // This is useful when saving a new entry from the form.
    init(group: [String]) {
        self.pool = poolFromParts(group)
    }
    
    
    // Or no parameters can be passed.
    // In this case, the pool will be an array of 0s.
    init() {
        self.pool = poolFromParts([ ])
    }
    
    
    
    // This takes the metadata component of the entry and returns an array of those parts.
    // The pool it returns might contain only 0s. If that's the case, the values will need
    // to be filled with named methods.
    func poolFromParts(parts: [String]) -> [Int] {
        var pool = [Int]()

        if parts.count == 3 {
            pool = parts.map {
                (part) -> Int in
                if (part.rangeOfString("^[0-9]+$", options: .RegularExpressionSearch) != nil) {
                    return Int(part)!
                }
                else {
                    return 0
                }
            }
        }
        
        else {
            print("Error building metadata pool: passed parts are poorly-formed.")
            pool = [0, 0, 0]
        }
        
        return pool
    }
    
    
    
    func join(separator: String?) -> String {
        var unitSep: String
        
        if let sep = separator {
            unitSep = sep
        }
        else {
            unitSep = StoreManager.unitSeparator
        }
        
        return self.pool.map(String.init).joinWithSeparator(unitSep)
    }
    
}