//
//  FileManager.swift
//  TapTest
//
//  Created by Richard Mavis on 9/28/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation

class StoreManager {

    static let fileName: String = "store"

    // This is the ASCII file separator character.
    // It isn't currently being used, but might be useful later.
    static let fileSeparator: String = "\u{001C}"

    // This is the ASCII group separator character.
    // It separates entries.
    static let entrySeparator: String = "\u{001D}"

    // This is the ASCII record separator character.
    // This separates the groups of an entry.
    static let groupSeparator: String = "\u{001E}"

    // This is the ASCII unit separator character.
    // This separates parts of a group.
    static let unitSeparator: String = "\u{001F}"



    static func filePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return "\(documentsDirectory)/\(StoreManager.fileName)"

        // Filepath: /Users/rfm/Library/Developer/CoreSimulator/Devices/B43B9E48-A081-4C1A-B102-114E11B5C621/data/Containers/Data/Application/B9C3E13C-4597-4324-A180-301885062BDB/Documents/store

        //        if let path = NSBundle.mainBundle().pathForResource(StoreManager.fileName, ofType: nil) {
        //            // print(path)
        //            return path
        //        }
        //        else {
        //            print("Missing \(StoreManager.fileName) file!")
        //            return nil
        //        }
    }



    static func readDataFromFile() -> String? {
        do {
            let dataString = try String(contentsOfFile: StoreManager.filePath(), encoding: NSUTF8StringEncoding)
            return dataString
            // let data = try NSData(contentsOfFile: filePath, options: NSDataReadingOptions.DataReadingUncached)
            //                if let string = String(data: data, encoding: NSUTF8StringEncoding) {
            //                    return string
            //                }
            //                else {
            //                    return nil
            //                }
        }

        catch let error as NSError {
            print("Error reading data from the store file:")
            print(error)
            return nil
        }
    }



    static func getEntries() -> [Entry]? {
        if let dataString = StoreManager.readDataFromFile() {
            // print("data read: \(stringData)")

            let entriesRead = dataString.componentsSeparatedByString(StoreManager.entrySeparator)
            // print("Read \(groups.count) groups from file.")

            var entriesMade: [Entry] = [ ]
            for group in entriesRead {
                if let entry_check = Entry.checkStringForm(group) {
                    entriesMade.append(entry_check)
                }
                else {
                    print("Entry is not well-formed! Skipping.")
                }
            }

            return entriesMade.reverse()
        }

        else {
            return nil
        }
    }



    static func appendEntryToFile(entry: Entry) -> Bool {
        print("Need to save entry to file!")

        if let existingEntries = StoreManager.readDataFromFile() {
            let newEntries = [existingEntries, entry.join()].joinWithSeparator(StoreManager.entrySeparator)

            do {
                try newEntries.writeToFile(StoreManager.filePath(), atomically: false, encoding: NSUTF8StringEncoding)
                return true
            }

            catch let error as NSError {
                print(error)
                return false
            }
        }

        else {
            return false
        }
    }



    static func copyFileFromBundleToSandbox() {
        if let path = NSBundle.mainBundle().pathForResource(StoreManager.fileName, ofType: nil) {
            do {
                let bundleData = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)

                do {
                    try bundleData.writeToFile(StoreManager.filePath(), atomically: false, encoding: NSUTF8StringEncoding)
                    print("Copied store file from bundle to sandbox")
                }

                catch let error as NSError {
                    print("Error writing bundle data to sandbox file")
                    print(error)
                }

            }

            catch let error as NSError {
                print("Error reading bundle data")
                print(error)
            }
        }
        else {
            print("Missing \(StoreManager.fileName) file in app bundle!")
        }
    }



    init() {
    }

}