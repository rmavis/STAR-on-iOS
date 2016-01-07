//
//  StoreManager.swift
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

    // This is the ASCII delete control code.
    // This is used to mark entries for deletion.
    static let deleteCode: String = "\u{007F}"



    static func appendFilenameToDocumentsPath(fileName: String = StoreManager.fileName) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]

        return "\(documentsDirectory)/\(fileName)"
    }



    static func readDataFromFile() -> String? {
        do {
            let dataString = try String(contentsOfFile: StoreManager.appendFilenameToDocumentsPath(), encoding: NSUTF8StringEncoding)
            return dataString
        }

        catch let error as NSError {
            print("Error reading data from the store file:")
            print(error)
            return nil
        }
    }



    static func getEntries() -> [Entry] {
        var entriesMade = [Entry]()

        if let dataString = StoreManager.readDataFromFile() {
            // print("data read: \(dataString)")

            let entriesRead = dataString.componentsSeparatedByString(StoreManager.entrySeparator)
            // print("Read \(entriesRead.count) groups from file.")

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
            print("Failed to read data from file.")
            return entriesMade
        }
    }



    static func appendEntryToFile(entry: Entry) -> Bool {
        print("Need to save entry to file!")

        if let fileHandle = NSFileHandle.init(forUpdatingAtPath: StoreManager.appendFilenameToDocumentsPath()) {
            let entryString = entry.joinAndAddSeparator()

            print("Adding \(entryString) to \(StoreManager.appendFilenameToDocumentsPath())")

            fileHandle.seekToEndOfFile()
            fileHandle.writeData(entryString.dataUsingEncoding(NSUTF8StringEncoding)!)
            fileHandle.closeFile()

            // This is only for testing  #HERE
            StoreManager.copyFileFromSandboxToBundle()

            return true
        }

        else {
            return false
        }
    }



    static func updateStoreWithBackup(entries: [Entry], wrapup: () -> Void) -> Bool {
        if let backupFilePath = StoreManager.makeBackupFile(entries) {
            print("Created backup file '\(backupFilePath)'")

            if StoreManager.replaceStoreWithBackup(backupFilePath) == true {
                print("Successfully deleted entry from file. Running wrapup function.")
                wrapup()
                return true
            }

            else {
                print("Failed to replace store file with backup.")
                return false
            }
        }

        else {
            print("Failed to make backup file.")
            return false
        }
    }



    static func makeBackupFile(entries: [Entry]) -> String? {
        let filename = "\(StoreManager.fileName)_bk_\(Int(NSDate().timeIntervalSince1970))"
        let filepath = StoreManager.appendFilenameToDocumentsPath(filename)

        // print("Need to make a backup file at '\(filepath)'!")
        let storeManager = StoreManager()
        let fileManager = storeManager.fileManager

        if fileManager.createFileAtPath(filepath, contents: nil, attributes: nil) {
            if let fileHandle = NSFileHandle.init(forWritingAtPath: filepath) {
                print("Writing \(entries.count) entries to backup file.")
                
                for entry in entries {
                    fileHandle.writeData("\(entry.join())\(entrySeparator)\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                }

                fileHandle.closeFile()

                return filepath
            }
                
            else {
                return nil
            }
        }

        else {
            return nil
        }
    }



    static func replaceStoreWithBackup(from: String, to: String = StoreManager.appendFilenameToDocumentsPath()) -> Bool {
        do {
            let storeManager = StoreManager()
            try storeManager.fileManager.moveItemAtPath(from, toPath: to)
            print("Replaced '\(to)' with '\(from)'.")

            // This is only for testing  #HERE
            StoreManager.copyFileFromSandboxToBundle()
            return true
        }

        catch let error as NSError {
            print("Error replacing file from '\(from)' to '\(to)':\n\(error)")
            return false
        }
    }



    static func deleteBackupFile(filepath: String) -> Bool {
        print("Deleting backup file at '\(filepath)'")

        do {
            let storeManager = StoreManager()
            try storeManager.fileManager.removeItemAtPath(filepath)
            return true
        }

        catch let error as NSError {
            print("Error deleting file at '\(filepath)':\n\(error)")
            return false
        }
    }



    static func ensureFileExists() {
        print("Ensuring file exists!")

        let storeManager = StoreManager()
        let fileManager = storeManager.fileManager
        
        if fileManager.fileExistsAtPath(StoreManager.appendFilenameToDocumentsPath()) {
            print("Store file exists: \(StoreManager.appendFilenameToDocumentsPath())")
        }
        else {
            print("Store file does not exist.")
            StoreManager.copyFileFromBundleToSandbox()
        }
    }



    static func copyFile(from: String, to: String = StoreManager.appendFilenameToDocumentsPath()) -> Bool {
        do {
            let storeManager = StoreManager()
            try storeManager.fileManager.copyItemAtPath(from, toPath: to)
            print("Copied store file from '\(from)' to '\(to)'.")
            return true
        }

        catch let error as NSError {
            print("Error copying file from '\(from)' to '\(to)':\n\(error)")
            return false
        }
    }


    static func copyFileFromBundleToSandbox() {
        StoreManager.copyFile(
            NSBundle.mainBundle().pathForResource(StoreManager.fileName, ofType: nil)!,
            to: StoreManager.appendFilenameToDocumentsPath()
        )
    }

    static func copyFileFromSandboxToBundle() {
        StoreManager.copyFile(
            StoreManager.appendFilenameToDocumentsPath(),
            to: NSBundle.mainBundle().pathForResource(StoreManager.fileName, ofType: nil)!
        )
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

        // StoreManager.ensureFileExists()
    }



    // When copying a file, if the destination file already exists,
    // then the NSFileManager pings this to check if it should proceed.
    func fileManager(fileManager: NSFileManager, shouldProceedAfterError error: NSError, copyingItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        // print("Should proceed with copying from \(srcPath) to \(dstPath)? You betcha.")
        return true
    }


    //    func fileManager(fileManager: NSFileManager, shouldCopyItemAtURL srcURL: NSURL, toURL dstURL: NSURL) -> Bool {
    //        print("Should proceed with copying from \(srcURL) to \(dstURL)? You betcha.")
    //        return true
    //    }

    func fileManager(fileManager: NSFileManager, shouldCopyItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        print("Should proceed with copying from \(srcPath) to \(dstPath)? You betcha.")
        return true
    }


    func fileManager(fileManager: NSFileManager, shouldMoveItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        print("Should proceed with moving from \(srcPath) to \(dstPath)? You betcha.")
        return true
    }


    func fileManager(fileManager: NSFileManager, shouldProceedAfterError error: NSError, movingItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        print("Should proceed with moving from \(srcPath) to \(dstPath)? You betcha.")
        return true
    }


    func fileManager(fileManager: NSFileManager, shouldRemoveItemAtPath path: String) -> Bool {
        if path == StoreManager.appendFilenameToDocumentsPath() {
            print("Delegate disapproving deletion of store file.")
            return false
        }
        else {
            print("Delegate approving deletion of file at '\(path)'")
            return true
        }
    }

}