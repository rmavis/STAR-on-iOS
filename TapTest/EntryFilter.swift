//
//  EntryFilter.swift
//  TapTest
//
//  Created by Richard Mavis on 9/30/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation

struct EntryFilter {

    let searchString: String
    let entriesArray: [Entry]

    init(searchString: String, entriesArray: [Entry]) {
        self.searchString = searchString
        self.entriesArray = entriesArray
    }
}
