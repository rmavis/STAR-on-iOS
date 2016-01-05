//
//  FileManager.swift
//  TapTest
//
//  Created by Richard Mavis on 9/28/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation

class StoreManager: NSObject, NSFileManagerDelegate {

    // This is the name of the store file.
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
        // let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        // let documentsDirectory = paths[0]
        // return "\(documentsDirectory)/\(StoreManager.fileName)"
        return NSBundle.mainBundle().pathForResource(StoreManager.fileName, ofType: nil)!
    }



    static func readDataFromFile() -> String? {
        do {
            let dataString = try String(contentsOfFile: StoreManager.filePath(), encoding: NSUTF8StringEncoding)
            return dataString
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

        if let fileHandle = NSFileHandle.init(forUpdatingAtPath: StoreManager.filePath()) {
            let entry = StoreManager.entrySeparator + entry.join()

            print("Adding \(entry)")
            print("To \(StoreManager.filePath())")

            fileHandle.seekToEndOfFile()
            fileHandle.writeData(entry.dataUsingEncoding(NSUTF8StringEncoding)!)
            fileHandle.closeFile()

            // This is only for testing  #HERE
            StoreManager.copyFileFromSandboxToBundle()

            return true
        }

        else {
            return false
        }
    }



    // This is pointless because it copies from the virtual, sandboxed bundle
    // to the virtual, sandboxed app in the virtual machine. It never touches
    // the store file relative to this file.

    static func copyFileFromBundleToSandbox() {
        do {
            let storeManager = StoreManager()

            try storeManager.fileManager.copyItemAtPath(
                NSBundle.mainBundle().pathForResource(StoreManager.fileName, ofType: nil)!,
                toPath: StoreManager.filePath()
            )

            print("Copied store file from bundle to sandbox.")
        }

        catch let error as NSError {
            print("Error copying bundle file to the sandbox.")
            print(error)
        }
    }


    static func copyFileFromSandboxToBundle() {
        do {
            let storeManager = StoreManager()

            try storeManager.fileManager.copyItemAtPath(
                StoreManager.filePath(),
                toPath: NSBundle.mainBundle().pathForResource(StoreManager.fileName, ofType: nil)!
            )

            print("Copied store file from sandbox to bundle.")
        }

        catch let error as NSError {
            print("Error copying sandbox file to the bundle.")
            print(error)
        }
    }





    //
    // These are properties and methods related to the instance.
    //

    // This is the file manager.  #HERE
    var fileManager: NSFileManager



    override init() {
        self.fileManager = NSFileManager.init()

        super.init()

        self.fileManager.delegate = self
    }



    // When copying a file, if the destination file already exists,
    // then the NSFileManager pings this to check if it should proceed.
    func fileManager(fileManager: NSFileManager, shouldProceedAfterError error: NSError, copyingItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        // print("Should proceed with copying from \(srcPath) to \(dstPath)? You betcha.")
        return true
    }

    func fileManager(fileManager: NSFileManager, shouldCopyItemAtURL srcURL: NSURL, toURL dstURL: NSURL) -> Bool {
        // print("Should proceed with copying from \(srcURL) to \(dstURL)? You betcha.")
        return true
    }

    /*
    Should proceed with copying from /Users/rfm/Library/Developer/CoreSimulator/Devices/BB0D9A98-B3A8-43C5-97E6-3E8FF32FC32D/data/Containers/Bundle/Application/CC22DAD4-6CBF-479D-B480-F6F171B418C5/TapTest.app/store to /Users/rfm/Library/Developer/CoreSimulator/Devices/BB0D9A98-B3A8-43C5-97E6-3E8FF32FC32D/data/Containers/Data/Application/C6953432-28C9-44C0-BC6D-DF1B8EA8C2FD/Documents/store? You betcha.
    */

}