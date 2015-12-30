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
        let groups = group.componentsSeparatedByString(StoreManager.groupSeparator)
        // print("Line has \(groups.count) groups.")
        
        if groups.count == 3 {
            let entry = Entry(value: groups[0], tags: groups[1], metadata: groups[2])
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
    
    
    let value: EntryValue
    let tags: EntryTags
    let metadata: EntryMetadata

    
    
    // An Entry can be created when all the parameters are Strings.
    // This is useful for reading Entries from the store.
    init(value: String, tags: String, metadata: String) {
        self.value = EntryValue(part: value)
        self.tags = EntryTags(group: tags)
        self.metadata = EntryMetadata(group: metadata)
    }
    
    
    
    // An Entry can be created when the tags are an Array of Strings.
    // This is useful when saving a new entry from the form.
    init(value: String, tags: [String]) {
        self.value = EntryValue(part: value)
        self.tags = EntryTags(group: tags)

        self.metadata = EntryMetadata()
        self.metadata.setDateCreated()
        // That sets the Date Created value to the current timestamp.
        // The other metadata values can remain 0.
    }



    func match(searchString: String) -> Bool {
        var matched = false

        if self.value.match(searchString) {
            matched = true
        }

        if (matched == false) && (self.tags.match(searchString)) {
            matched = true
        }

        return matched
    }



    func join() -> String {
        return [
            self.value.string,
            self.tags.join(nil),
            self.metadata.join(nil)
        ].joinWithSeparator(StoreManager.groupSeparator)
    }

}