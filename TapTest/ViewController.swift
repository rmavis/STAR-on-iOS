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

    var numberRowsToInsert: Int = 0

    static let animationDelay = 0.0
    static let animationDuration = 0.2

    var selectedEntry: Entry? = nil





    //
    // This section is related to the entries cache.
    //

    // This is the main store for the Entries.
    // The envare collection is keyed on the empty string, "".
    // While searching, cache entries will be created and deleted,
    // each keyed on the search term.
    var entriesCache: [String: [Entry]] = [:]

    // This is the currently visible entry from the cache.
    var visibleEntries: [Entry] = [ ]

    // This is the limit of the cache. It's not currently being used.
    let entriesCacheEntriesLimit = 10



    // This returns the cache that matches the current search term.
    // If the search term doesn't match a cache key, then it returns nil.
    // If there is no search term, then it returns the whole list.
    func getCurrentEntriesCache() -> [Entry]? {
        if let searchTerm = self.entriesSearchBar.text {
            if let cache = self.entriesCache[searchTerm.lowercaseString] {
                print("Got current entries cache for '\(searchTerm)'")
                return cache
            }
            else {
                print("Weirdness: '\(searchTerm)' in search bar but no matching entry in cache.")
                return nil
            }
        }
        else {
            return self.entriesCache[""]!
        }
    }



    func setCurrentEntriesCache(entries: [Entry]) {
        if let searchTerm = self.entriesSearchBar.text {
            self.entriesCache[searchTerm.lowercaseString] = entries
        }
        else {
            self.entriesCache[""] = entries
        }
    }



    func clearEntriesCache() {
        for (cacheKey, _) in self.entriesCache {
            if cacheKey != "" {
                self.entriesCache[cacheKey] = nil
            }
        }

        print("Entries in the cache: \(self.entriesCache.count)")
    }



    func addEntryToCaches(newEntry: Entry) {
        for (cacheKey, _) in self.entriesCache {
            self.entriesCache[cacheKey]!.insert(newEntry, atIndex: 0)
        }
    }



    func updateEntryInCaches(newEntry: Entry) {
        for (cacheKey, cache) in self.entriesCache {
            loop: for (index, entry) in cache.enumerate() {
                if entry.refId == newEntry.refId {
                    self.entriesCache[cacheKey]![index] = newEntry
                    break loop
                }
            }
        }
    }



    func removeEntryFromCaches(delEntry: Entry) {
        for (cacheKey, cache) in self.entriesCache {
            loop: for (index, entry) in cache.enumerate() {
                if entry.refId == delEntry.refId {
                    print("Removing entry from '\(cacheKey)' cache with value '\(delEntry.value.string)'")
                    self.entriesCache[cacheKey]!.removeAtIndex(index)
                    break loop
                }
            }
        }
        print("Done removing '\(delEntry.value.string)' value from caches.")
    }



    // How to intelligently delete cache entries?
    // Can regex check the search term against the cache keys
    // and delete the one(s) that don't match.
    // And how to intelligently build cache entries from existing entries?
    func filterVisibleEntries(searchString: String) {
        // print("Will filter table with \(searchString)!")

        if searchString == "" {
            // self.visibleEntries = self.entriesCache[""]!

            if self.entriesCache.count > 1 {
                clearEntriesCache()
            }
        }

        else {
            // self.entriesCacheEntriesLimit
            let cacheKey = searchString.lowercaseString

            if self.entriesCache[cacheKey] == nil {
                var filteredEntries: [Entry] = [ ]

                for entry in self.entriesCache[""]! {
                    if entry.match(searchString) {
                        filteredEntries.append(entry)
                    }
                }

                self.entriesCache[cacheKey] = filteredEntries
            }
        }
        
        // Reload the table
        self.entriesTable.reloadData()
    }



    // The SEARCH button calls this.
    @IBAction func toggleSearchBar() {
        if (self.entriesSearchBarBox.hidden == true) {
            self.entriesSearchBarBox.hidden = false
            viewFrame.bringSubviewToFront(self.entriesSearchBarBox)

            UIView.animateWithDuration(ViewController.animationDuration, delay: ViewController.animationDelay, options: [],
                animations: {
                    self.entriesSearchBarBox.alpha = 1
                },
                completion: {(completed: Bool) -> Void in
                    self.entriesSearchBar.becomeFirstResponder()
                    self.entriesTable.scrollToRowAtIndexPath(NSIndexPath.init(forItem: 0, inSection: 0), atScrollPosition: .Top, animated: true)
                }
            )
        }

        else {
            self.entriesSearchBar.resignFirstResponder()
            clearSearchBar()

            // self.entriesTable.scrollToRowAtIndexPath(NSIndexPath.init(forItem: 0, inSection: 0), atScrollPosition: .Top, animated: true)

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
    }



    func clearSearchBar() {
        self.entriesSearchBar.text = ""
        filterVisibleEntries("")
    }
    




    //
    // UITableViewDataSource methods.
    //

    // This is called while building the table.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // print("Returning number of sections in table view.")
        return 1
    }



    // This is also called while building the table.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cache = getCurrentEntriesCache() {
            print("Returning number of rows: \(cache.count + numberRowsToInsert) // \(cache.count)")
            return cache.count
        }
        else {
            return 0
        }
    }



    // This builds and returns the table cell for the given table at the given row index.
    // The number of times this is called depends on the number of rows.
    // It will be called on as as-needed basis: whenever the table view needs new rows, this is called.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // print("Building new cell for table at \(indexPath.section):\(indexPath.row) / \(numberRowsToInsert).")

        let cell = tableView.dequeueReusableCellWithIdentifier(
            self.tableEntryCellID,
            forIndexPath: indexPath
            ) as! TableCellView

        if (self.numberRowsToInsert > 0) && (indexPath.row == 0) {
            // print("Using new entry cell!")
            return cell
        }

        else {
            if let cache = getCurrentEntriesCache() {
                let entry = cache[indexPath.row]

                // These lines size the row according to the row's content.
                // The real work of sizing the row is done by the constraints
                // on the interface elements, but these two lines are needed.
                // They are important.
                // via http://www.raywenderlich.com/87975/dynamic-table-view-cell-height-ios-8-swift
                tableView.rowHeight = UITableViewAutomaticDimension;
                tableView.estimatedRowHeight = 10.0;

                cell.entryValueDisplay.text = entry.value.string
                cell.entryTagsDisplay.text = entry.tags.join(", ")
            }

            // print("Returning cell for row \(row) with label: \(cell.entryValueDisplay.text!)")
            return cell
        }
    }



    // This returns the row's action buttons that appear
    // when the user swipes the row from right to left.
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction.init(style: .Default, title: "Delete", handler: delegateTableCellDeleteAction)
        deleteButton.backgroundColor = UIColor.redColor()

        let editButton = UITableViewRowAction.init(style: .Default, title: "Edit", handler: delegateTableCellEditAction)
        editButton.backgroundColor = UIColor.blueColor()

        return [deleteButton, editButton]
    }



    func delegateTableCellEditAction(rowAction: UITableViewRowAction, indexPath: NSIndexPath) -> Void {
        print("Need to delegate table cell editing action!")

        if let cache = getCurrentEntriesCache() {
            self.selectedEntry = cache[indexPath.row]
            self.performSegueWithIdentifier("SegueEntryFormToTable", sender: nil)
            // After this, `prepareForSegue` will be called.
            // That function sets `selectedEntry` back to nil.
        }
        else {
            print("Major problem: no cache.")
        }
    }



    func delegateTableCellDeleteAction(rowAction: UITableViewRowAction, indexPath: NSIndexPath) -> Void {
        print("Need to delegate table cell deletion action!")
        removeEntryFromStoreAndView(self.entriesTable, indexPath: indexPath)
    }


    // This needs to be broken into the two methods above.  #HERE
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

    // This occurs when the user taps on one of the table rows.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if let cache = getCurrentEntriesCache() {
            let entry = cache[indexPath.row]
            let rowValue = entry.value.string

            let actionURL = EntryAction.buildActionableURL(rowValue)

            if actionURL == nil {
                print("Copying \"\(rowValue)\" to clipboard")
                UIPasteboard.generalPasteboard().string = rowValue
            }
            else {
                // print("Acting on \"\(actionURL!)\"!")
                UIApplication.sharedApplication().openURL(NSURL(string: actionURL!)!)
            }

            entry.metadata.updateOnSelect()
            updateEntryInStoreAndView(entry, tableView: tableView, indexPath: indexPath)
        }
    }





    //
    // Methods related to inserting, editing, and deleting table rows.
    //

    func updateEntryInStoreAndView(edEntry: Entry, tableView: UITableView, indexPath: NSIndexPath) -> Bool {
        // print("Want to update entry with value \(newEntry.value.string)")

        let edId = edEntry.refId
        var bkEntries: [Entry] = [ ]

        for entry in self.entriesCache[""]! {
            if entry.refId == edId {
                bkEntries.append(edEntry)
            }
            else {
                bkEntries.append(entry)
            }
        }

        let updated = StoreManager.updateStoreWithBackup(bkEntries.reverse())

        if updated == true {
            updateEntryInCaches(edEntry)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // tableView.endUpdates()
        }
        
        return updated
    }



    func removeEntryFromStoreAndView(tableView: UITableView, indexPath: NSIndexPath) -> Bool {
        // print("Want to delete entry with value \(getCurrentEntriesCache().value.string)")

        if let cache = getCurrentEntriesCache() {
            let delEntry = cache[indexPath.row]
            let delId = delEntry.refId

            var bkEntries: [Entry] = [ ]

            for entry in self.entriesCache[""]! {
                if entry.refId != delId {
                    bkEntries.append(entry)
                }
            }

            let updated = StoreManager.updateStoreWithBackup(bkEntries.reverse())

            if updated == true {
                removeEntryFromCaches(delEntry)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                // tableView.reloadData()
            }
            
            return updated
        }

        else {
            return false
        }
    }





    //
    // UITextFieldDelegate methods.
    // These methods occur in order of calling.
    //

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // print("Search bar should begin editing?")
        return true
    }



    @IBAction func entriesSearchBarEditDidBegin(sender: AnyObject) {
        // print("Search bar text will begin editing!")
    }



    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // print("Search bar should change text in a range.")
        return true
    }



    @IBAction func entriesSearchBarTextDidChange(textField: UITextField) {
        // print("Search bar text changed!")
        filterVisibleEntries(textField.text!.lowercaseString)
    }



    func textFieldTextDidBeginEditing(textField: UITextField) {
        // print("Search bar did begin editing.")
    }



    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        // print("Search bar should end editing?")
        return true
    }



    func textFieldTextDidEndEditing(textField: UITextField) {
        // print("Seach bar text did end editing.")
    }



    func textFieldShouldClear(textField: UITextField) -> Bool {
        // print("Search bar text should clear?")
        return true
    }



    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // print("Search bar text should return?")

        self.entriesSearchBar.resignFirstResponder()
        return true
    }





    //
    // Methods related to the keyboard.
    //

    func keyboardWillShow(notification: NSNotification) {
        // print("[Main VC] Keyboard will show!")

        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);

            self.entriesTable.contentInset = contentInsets
            self.entriesTable.scrollIndicatorInsets = contentInsets
        }
    }



    func keyboardWillHide(notification: NSNotification) {
        // print("Keyboard will hide!")

        let contentInsets = UIEdgeInsetsZero
        self.entriesTable.contentInset = contentInsets
        self.entriesTable.scrollIndicatorInsets = contentInsets
    }





    //
    // View controller methods.
    //


    // Do any additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        print("[Main VC] View did load")

        super.viewDidLoad()

        StoreManager.ensureFileExists()  // This is lame.  #HERE
        self.entriesCache[""] = StoreManager.getEntries()

        self.entriesTable.delegate = self
        self.entriesTable.dataSource = self

        self.entriesTable.separatorStyle = UITableViewCellSeparatorStyle.None;

        self.entriesSearchBar.delegate = self
    }



    override func viewWillAppear(animated: Bool) {
        print("[Main VC] View will appear")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        super.viewWillAppear(animated)
        
        // This repeats the entire process of building the table.
        // When returning from the new entry form, this doesn't need to run.
        // If it's possible to add only the new entry, that'd be best.
        self.entriesTable.reloadData()
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        // print("[Main VC] View will disappear")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        super.viewWillDisappear(animated)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "SegueEntryFormToTable") {
            if self.selectedEntry != nil {
                print("Seguing to entry form with \(self.selectedEntry!.value.string)!")
                let formVC = segue.destinationViewController as! EntryFormViewController;
                formVC.entryToEdit = self.selectedEntry
                self.selectedEntry = nil
            }
        }
    }
    
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
