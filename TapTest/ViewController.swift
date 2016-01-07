//
//  ViewController.swift
//  TapTest
//
//  Created by Richard Mavis on 9/28/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    // UISearchBarDelegate, UISearchControllerDelegate

    @IBOutlet var viewFrame: UIView!

    // The main actions buttons and their box.
    @IBOutlet weak var entriesActionButtonsBox: UIView!
    @IBOutlet weak var entriesSearchButton: UIButton!
    @IBOutlet weak var entryAddButton: UIButton!
    
    // The border between the buttons and the table.
    @IBOutlet weak var entryElementsBorder: UIView!

    // The search bar and its elements.
    @IBOutlet weak var entriesSearchBarBox: UIView!
    @IBOutlet weak var entriesSearchBar: UITextField!
    @IBOutlet weak var entriesSearchCancelButton: UIButton!



    // The main entries table.
    @IBOutlet weak var entriesTable: UITableView!
    @IBOutlet weak var entriesTableBottomConstraint: NSLayoutConstraint!
    let tableEntryCellID = "EntryCell"
    let tableNewEntryCellID = "NewEntryCell"

    var entries: [Entry] = [ ]
    var filteredEntriesCache: [EntryFilter] = [ ]

    var numberRowsToInsert: Int = 0

    static let animationDelay = 0.0
    static let animationDuration = 0.2

    // var currentKeyboardHeight:CGFloat = 0.0



    @IBAction func toggleSearchBar() {
        // print("Need to toggle search bar!")
        
        if (entriesSearchBarBox.hidden == true) {
            // print("Appearing search bar")
            
            entriesSearchBarBox.hidden = false
            viewFrame.bringSubviewToFront(entriesSearchBarBox)
            
            UIView.animateWithDuration(ViewController.animationDuration, delay: ViewController.animationDelay, options: [],
                animations: {
                    self.entriesSearchBarBox.alpha = 1
                },
                completion: {(completed: Bool) -> Void in
                    self.entriesSearchBar.becomeFirstResponder()
                }
            )
        }
            
        else {
            // print("Disappearing search bar")
            
            entriesSearchBar.resignFirstResponder()
            
            entriesSearchBarClearText()
            
            UIView.animateWithDuration(ViewController.animationDuration, delay: ViewController.animationDelay, options: [],
                animations: {
                    self.entriesSearchBarBox.alpha = 0
                },
                completion: {(completed: Bool) -> Void in
                    self.viewFrame.sendSubviewToBack(self.entriesSearchBarBox)
                    self.entriesSearchBarBox.hidden = true
                }
            )
        }
        
        // print("Done toggling search bar.")
    }





    //
    // UITableViewDataSource methods.
    //

    // This is called while building the table.
    func numberOfSectionsInTableView(entriesTable: UITableView) -> Int {
        // print("Returning number of sections in table view.")
        return 1
    }



    // This is also called while building the table.
    func tableView(entriesTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print("Returning number of rows: \(entries.count + numberRowsToInsert)")
        //        return (entries.count + numberRowsToInsert)
        print("Returning number of rows: \(self.entries.count)")
        return self.entries.count
    }



    // This builds and returns the table cell for the given table at the given row index.
    // The number of times this is called depends on the number of rows.
    // It will be called on as as-needed basis: whenever the table view needs new rows, this is called.
    func tableView(entriesTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // print("Building new cell for table at \(indexPath.section):\(indexPath.row) / \(numberRowsToInsert).")

        if (numberRowsToInsert > 0) && (indexPath.row == 0) {
            // print("Using new entry cell!")
            let cell = entriesTable.dequeueReusableCellWithIdentifier(tableNewEntryCellID, forIndexPath: indexPath) as! TableCellNewEntry

            return cell
        }

        else {
            let cell = entriesTable.dequeueReusableCellWithIdentifier(tableEntryCellID, forIndexPath: indexPath) as! TableCellView

            let row = indexPath.row

            let entry = self.entries[row]
            // These lines size the row according to the row's content.
            // The real work of sizing the row is done by the constraints
            // on the interface elements, but these two lines are needed.
            // They are important.
            // via http://www.raywenderlich.com/87975/dynamic-table-view-cell-height-ios-8-swift
            entriesTable.rowHeight = UITableViewAutomaticDimension;
            entriesTable.estimatedRowHeight = 10.0;

            cell.entryValueDisplay.text = entry.value.string
            cell.entryTagsDisplay.text = entry.tags.join(", ")

            // print("Returning cell for row \(row) with label: \(cell.entryValueDisplay.text!)")
            return cell
        }
    }



    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if editingStyle == UITableViewCellEditingStyle.Delete {
            removeEntryFromStoreAndView(tableView, indexPath: indexPath)
        }

        else {
            print("Want to insert")
        }

    }





    //
    // UITableViewDelegate methods.
    //

    func tableView(entriesTable: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        entriesTable.deselectRowAtIndexPath(indexPath, animated: true)

        let row = indexPath.row
        let entry = self.entries[row]
        let rowValue = entry.value.string

        // Will also want to update the entry's metadata.  #HERE

        let actionURL = EntryAction.buildActionableURL(rowValue)

        if actionURL == nil {
            print("Copying \"\(rowValue)\" to clipboard")
            UIPasteboard.generalPasteboard().string = rowValue
        }
        else {
            print("Acting on \"\(actionURL!)\"!")
            UIApplication.sharedApplication().openURL(NSURL(string: actionURL!)!)
        }

        entry.metadata.updateOnSelect()
        updateEntryInStoreAndView(entry, tableView: entriesTable, indexPath: indexPath)
    }





    //
    // Methods related to inserting, editing, and deleting table rows.
    //

    func removeEntryFromStoreAndView(tableView: UITableView, indexPath: NSIndexPath) -> Bool {
        print("Want to delete entry with value \(self.entries[indexPath.row].value.string)")

        var bkEntries: [Entry] = [ ]
        for (index, entry) in self.entries.enumerate() {
            if index != indexPath.row {
                bkEntries.append(entry)
            }
        }

        let updated = StoreManager.updateStoreWithBackup(
            bkEntries.reverse(),
            wrapup: { () -> Void in
                self.entries = bkEntries

                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                tableView.endUpdates()
            })

        return updated
    }



    func updateEntryInStoreAndView(newEntry: Entry, tableView: UITableView, indexPath: NSIndexPath) -> Bool {
        print("Want to update entry with value \(newEntry.value.string)")

        var bkEntries: [Entry] = [ ]
        for (index, entry) in self.entries.enumerate() {
            if index == indexPath.row {
                bkEntries.append(newEntry)
            }
            else {
                bkEntries.append(entry)
            }
        }

        let updated = StoreManager.updateStoreWithBackup(
            bkEntries.reverse(),
            wrapup: { () -> Void in
                self.entries = bkEntries

                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.endUpdates()
        })

        return updated
    }





    //
    // UITextFieldDelegate methods.
    // These methods occur in order of calling.
    //

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("Search bar should begin editing?")
        // entriesSearchBar.setShowsCancelButton(true, animated: true)
        return true
    }



    @IBAction func entriesSearchBarEditDidBegin(sender: AnyObject) {
        print("Search bar text will begin editing!")
    }



    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("Search bar should change text in a range.")
        return true
    }



    @IBAction func entriesSearchBarTextDidChange(textField: UITextField) {
        print("Search bar text changed!")
        filterEntriesTable(textField.text!.lowercaseString)
    }



    func textFieldTextDidBeginEditing(textField: UITextField) {
        print("Search bar did begin editing.")
    }



    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("Search bar should end editing?")
        return true
    }



    func textFieldTextDidEndEditing(textField: UITextField) {
        print("Seach bar text did end editing.")
    }



    func textFieldShouldClear(textField: UITextField) -> Bool {
        print("Search bar text should clear?")
        return true
    }



    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("Search bar text should return?")

        entriesSearchBar.resignFirstResponder()
        return true
    }



    func entriesSearchBarClearText() {
        print("Clearing search bar text!")

        entriesSearchBar.text = ""
        filterEntriesTable("")
    }



    // It would save time if, rather than reloading the entries array every time,
    // each new searchString was checked against its previous version, and if the
    // new one is just a longer version of the previous, then stick with the same
    // array, else get them all again.
    // Or if there were caches. Say 10?
    func filterEntriesTable(searchString: String) {
        print("Will filter table with \(searchString)!")

        var filteredEntries: [Entry] = [ ]

        if searchString == "" {
            filteredEntries = StoreManager.getEntries()
            self.filteredEntriesCache = [ ]
        }

        else {
            // There's a better way to check this.
            // What if the search string was pasted over the previous one?
            if (filteredEntriesCache.count > 0) {
                print("Checking filtered entries cache. \(filteredEntriesCache.count)")

                for entry in filteredEntriesCache {
                    if entry.searchString == searchString {
                        print("Found entry in cache.")
                        filteredEntries = entry.entriesArray
                    }
                }
            }

            if (filteredEntries.count == 0) {
                for entry in self.entries {
                    if entry.match(searchString) {
                        filteredEntries.append(entry)
                    }
                }

                self.filteredEntriesCache.append(EntryFilter(searchString: searchString, entriesArray: filteredEntries))
            }
        }

        self.entries = filteredEntries

        // Reload the table
        entriesTable.reloadData()
    }





    //
    // Methods related to the keyboard.
    //

    func keyboardWillShow(notification: NSNotification) {
        print("[Main VC] Keyboard will show!")

        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);

            entriesTable.contentInset = contentInsets
            entriesTable.scrollIndicatorInsets = contentInsets
        }
    }



    func keyboardWillHide(notification: NSNotification) {
        print("Keyboard will hide!")

        let contentInsets = UIEdgeInsetsZero
        entriesTable.contentInset = contentInsets
        entriesTable.scrollIndicatorInsets = contentInsets
    }





    //
    // View controller methods.
    //


    // Do any additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        super.viewDidLoad()

        StoreManager.ensureFileExists()  // This is lame.  #HERE
        self.entries = StoreManager.getEntries()

        entriesTable.delegate = self
        entriesTable.dataSource = self

        entriesTable.separatorStyle = UITableViewCellSeparatorStyle.None;

        entriesSearchBar.delegate = self
    }



    override func viewWillAppear(animated: Bool) {
        print("[Main VC] View will appear")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        super.viewWillAppear(animated)

        // This repeats the entire process of building the table.
        // When returning from the new entry form, this doesn't need to run.
        // If it's possible to add only the new entry, that'd be best.
        // entriesTable.beginUpdates()
        // entriesTable.endUpdates()
        entriesTable.reloadData()
    }



    override func viewWillDisappear(animated: Bool) {
        print("[Main VC] View will disappear")

        NSNotificationCenter.defaultCenter().removeObserver(self)

        super.viewWillDisappear(animated)
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
