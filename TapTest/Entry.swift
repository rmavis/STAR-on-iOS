//
//  Entry.swift
//  TapTest
//
//  Created by Richard Mavis on 9/28/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation

class Entry {

    let value: EntryValue?
    let tags: EntryTags?
    // let metadata: EntryMetadata


    init(group: String) {
        let parts = group.componentsSeparatedByString(StoreManager.recordSeparator)
        // print("Line has \(parts.count) parts.")

        if parts.count == 3 {
            // print("Parts: \(parts[0]), \(parts[1]), \(parts[2])")

            self.value = EntryValue(part: parts[0])
            self.tags = EntryTags(group: parts[1])
            // self.metadata = nil
        }
        else {
            self.value = nil
            self.tags = nil

            print("Error building entry: group does not contain three parts.")
        }
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