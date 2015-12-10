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

    // The search bar and its elements.
    @IBOutlet weak var entriesSearchBarBox: UIView!
    @IBOutlet weak var entriesSearchBar: UITextField!
    @IBOutlet weak var entriesSearchCancelButton: UIButton!



    // The main entries table.
    @IBOutlet weak var entriesTable: UITableView!
    let tableEntryCellID = "EntryCell"
    let tableNewEntryCellID = "NewEntryCell"

    let entriesStore = StoreManager()

    var entries: [Entry] = [ ]
    var filteredEntriesCache: [EntryFilter] = [ ]

    var numberRowsToInsert: Int = 0

    static let animationDelay = 0.0
        static let animationDuration = 0.2



    @IBAction func toggleSearchBar() {
        print("Need to toggle search bar!")

        if (entriesSearchBarBox.hidden == true) {
            print("Appearing search bar")

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
            print("Disappearing search bar")

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

        print("Done toggling search bar.")
    }



    //
    // UITableViewDataSource methods.
    //

    func numberOfSectionsInTableView(entriesTable: UITableView) -> Int {
        print("Returning number of sections in table view.")
        return 1
    }


    func tableView(entriesTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Returning number of rows: \(entries.count + numberRowsToInsert)")
        return (entries.count + numberRowsToInsert)
    }


    func tableView(entriesTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("Building new cell for table at \(indexPath.section):\(indexPath.row) / \(numberRowsToInsert).")

        if (numberRowsToInsert > 0) && (indexPath.row == 0) {
            print("Using new entry cell!")
            let cell = entriesTable.dequeueReusableCellWithIdentifier(tableNewEntryCellID, forIndexPath: indexPath) as! TableCellNewEntry

            return cell
        }

        else {
            let cell = entriesTable.dequeueReusableCellWithIdentifier(tableEntryCellID, forIndexPath: indexPath) as! TableCellView

            let row = indexPath.row
            let entry = entries[row]

            // These lines size the row according to the row's content.
            // They are important.
            // entriesTable.rowHeight = UITableViewAutomaticDimension;
            // entriesTable.estimatedRowHeight = 53.0;

            if entry.value == nil {
                cell.entryValueDisplay.text = "Empty : ("
                cell.entryTagsDisplay.text = "No tags."
            }
            else {
                // print("New label: \(entries[row].value!.string)")

                cell.entryValueDisplay.lineBreakMode = .ByWordWrapping
                cell.entryTagsDisplay.lineBreakMode = .ByWordWrapping

                cell.entryValueDisplay.text = entry.value!.string
                cell.entryTagsDisplay.text = entry.tags!.string()

                // This is helpful.
                print("Value cell height before sizing: \(cell.entryValueDisplay.frame.size.height)")
                cell.entryValueDisplay.numberOfLines = 0
                cell.entryValueDisplay.sizeToFit()
                print("Value cell height after sizing: \(cell.entryValueDisplay.frame.size.height)")

                cell.entryTagsDisplay.numberOfLines = 0
                cell.entryTagsDisplay.sizeToFit()

                // print("Value font size: \(cell.entryValueDisplay.font.pointSize)")
                // print("TAGS font size: \(cell.entryTagsDisplay.font.pointSize)")
                // print("Value cell height after sizing: \(cell.entryValueDisplay.frame.size.height)")
                
                // cell.sizeToFit()

                // entriesTable.rowHeight = 20 + cell.entryTagsDisplay.font.pointSize + cell.entryValueDisplay.font.pointSize;
            }

            print("Returning cell for row \(row) with label: \(cell.entryValueDisplay.text!)")
            return cell
        }
    }



    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        let row = indexPath.row
        let entry = entries[row]

        if editingStyle == UITableViewCellEditingStyle.Delete {
            print("Want to delete entry with value \(entry.value!.string)")
        }
        else {
            print("Want to insert")
        }

    }



    //    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    ////         entriesTable.rowHeight = UITableViewAutomaticDimension;
    ////         entriesTable.estimatedRowHeight = 23.0;
    //
    //        print("Estimating table row height.")
    //        return UITableViewAutomaticDimension;
    //    }





    //
    // UITableViewDelegate methods.
    //

    func tableView(entriesTable: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        entriesTable.deselectRowAtIndexPath(indexPath, animated: true)

        let row = indexPath.row

        print("Do something with this: \(entries[row].value!.string)")
    }



//    func textViewDidEndEditing(textView: UITextView) -> Bool {
//        print("Text view did end editing?")
//        return true
//    }





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
            filteredEntries = entriesStore.entriesArray()!
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
                for entry in entries {
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



//    func getScreenDimensions() -> (height: CGFloat, width: CGFloat) {
//        let screenRect = UIScreen.mainScreen().bounds
//        return (height: screenRect.size.height, width: screenRect.size.width)
//    }



//    func resizeActionButtonBar() {
//        print("Resizing action buttons bar.")
//
//        entriesSearchButton.center.x -= 100
//    }



//    func resizeSearchBarElements() {
//        print("Resizing search bar view elements.")
//
//        let screenDimensions = getScreenDimensions()
//
//        let searchBarBoxDimensions = entriesSearchBarBox.bounds
//        let searchBarDimensions = entriesSearchBar.bounds
//        let cancelButtonDimensions = entriesSearchCancelButton.bounds
//
//        entriesSearchBarBox.bounds = CGRect(
//            x: searchBarBoxDimensions.origin.x,
//            y: searchBarBoxDimensions.origin.y,
//            width: screenDimensions.width,
//            height: searchBarDimensions.height + 20
//        )
//
//        print("Search bar width should be \(screenDimensions.width) - \(cancelButtonDimensions.width) - 20.")
//        entriesSearchBar.bounds = CGRect(
//            x: searchBarBoxDimensions.origin.x + 10,
//            y: searchBarBoxDimensions.origin.y + 10,
//            width: (screenDimensions.width - cancelButtonDimensions.width - 20),
//            height: searchBarDimensions.height
//        )
//
//        entriesSearchCancelButton.bounds = CGRect(
//            x: cancelButtonDimensions.origin.x,
//            y: cancelButtonDimensions.origin.y,
//            width: cancelButtonDimensions.width,
//            height: cancelButtonDimensions.height
//        )
//    }



//    func resizeNewEntryFormElements() {
//        print("Resizing new entry form view elements.")
//
//        let screenDimensions = getScreenDimensions()
//
//        // let entryFormDimensions = newEntryForm.bounds
//
//        print("Setting new entry form dimensions: \(screenDimensions.width), \(screenDimensions.height)")
//        newEntryForm.bounds = CGRect(
//            x: 0,
//            y: 0,
//            width: screenDimensions.width,
//            height: screenDimensions.height
//        )
//
//        print("Setting form element dimenstions: \(screenDimensions.width - 20), \(screenDimensions.height / 5)")
//        newEntryFormValueField.bounds = CGRect(
//            x: 10,
//            y: 10,
//            width: ceil(screenDimensions.width - 20),
//            height: ceil(screenDimensions.height / 5)
//        )
//
//        newEntryFormTagsField.bounds = CGRect(
//            x: newEntryFormValueField.bounds.origin.x,
//            y: newEntryFormValueField.bounds.origin.y + newEntryFormValueField.bounds.height + 20,
//            width: ceil(screenDimensions.width - 20),
//            height: ceil(screenDimensions.height / 5)
//        )
//
//        newEntryFormTagsField.text = "WTF TAGS"
//
//    }





    //
    // Default methods.
    //

    //    override func viewWillAppear(animated: Bool) {
    //        super.viewWillAppear(animated)
    //    }


    // Do any additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        super.viewDidLoad()

        self.entries = entriesStore.entriesArray()!

        entriesTable.delegate = self
        entriesTable.dataSource = self

        entriesTable.separatorStyle = UITableViewCellSeparatorStyle.None;

        entriesSearchBar.delegate = self

        // Is this necessary?
        // Reload the table
        // entriesTable.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
