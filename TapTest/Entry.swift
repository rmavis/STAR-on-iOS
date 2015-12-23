//
//  Entry.swift
//  TapTest
//
//  Created by Richard Mavis on 9/28/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation

class Entry {

    
    // The value is required.
    // The tags are optional -- if none are required, pass an empty array.
    static func createFromForm(value: String, tags: [String]) -> Entry {
        print("Creating new Entry object from form.")
        
        let entry = Entry(value: value, tags: tags)
        return entry
    }
    
    
    
    // This will check if the given String looks like an entry from the store.
    static func checkStringForm(group: String) -> Entry? {
        let parts = group.componentsSeparatedByString(StoreManager.recordSeparator)
        // print("Line has \(parts.count) parts.")
        
        if parts.count == 3 {
            // print("Parts: \(parts[0]), \(parts[1]), \(parts[2])")
            let entry = Entry(value: parts[0], tags: parts[1], metadata: parts[2])
            return entry
        }
            
        else {
            print("Error building entry: group does not contain three parts.")
            
            return nil
        }
        
    }
    
    
    
    
    
    //
    // Below this are properties and method related to the instance.
    //
    
    
    let value: EntryValue?
    let tags: EntryTags?
    // let metadata: EntryMetadata

    
    
    // An Entry can be created when all the parameters are Strings.
    // This is useful for reading Entries from the store.
    init(value: String, tags: String, metadata: String) {
        self.value = EntryValue(part: value)
        self.tags = EntryTags(group: tags)
        // self.metadata = EntryMetadata(metadata)
    }
    
    
    
    // An Entry can be created when the tags are an Array of Strings.
    // This is useful when saving a new entry from the form.
    init(value: String, tags: [String]) {
        self.value = EntryValue(part: value)
        self.tags = EntryTags(group: tags)
    }



    func match(searchString: String) -> Bool {
        var matched = false

        if (self.value != nil) {
            if self.value!.match(searchString) {
                matched = true
            }
        }

        if (matched == false) && (self.tags != nil) {
            if (self.tags!.match(searchString)) {
                matched = true
            }
        }

        return matched
    }

}