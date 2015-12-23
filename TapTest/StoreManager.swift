//
//  FileManager.swift
//  TapTest
//
//  Created by Richard Mavis on 9/28/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation

class StoreManager {

    let bundle = NSBundle.mainBundle()

    static let fileName: String = "store"
    
    static let fileSeparator: String = "\u{001C}"
    static let groupSeparator: String = "\u{001D}"
    static let recordSeparator: String = "\u{001E}"
    static let unitSeparator: String = "\u{001F}"
    
    
    
    static func saveEntryToFile(entry: Entry) -> Bool {
        print("Need to save entry to file!")
        
        return true
    }


    
    init() {
    }


    
    func filePath() -> String? {
        if let path = self.bundle.pathForResource(StoreManager.fileName, ofType: nil) {
            // print(path)
            return path
        }
        else {
            print("Missing \(StoreManager.fileName) file!")
            return nil
        }
    }


    
    func entriesArray() -> [Entry]? {
        do {
            let data = try NSData(contentsOfFile: self.filePath()!, options: NSDataReadingOptions.DataReadingUncached)
            let stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            // print("data read: \(stringData)")

            let groups = stringData!.componentsSeparatedByString(StoreManager.groupSeparator)
            // print("Read \(groups.count) groups from file.")

            var entries: [Entry] = [ ]
            for group in groups {
                if let entry_check = Entry.checkStringForm(group) {
                    entries.append(entry_check)
                }
                else {
                    print("Entry is not well-formed! Skipping.")
                }
            }

            return entries.reverse()
        }

        catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    
}