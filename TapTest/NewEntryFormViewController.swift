//
//  NewEntryFormViewController.swift
//  TapTest
//
//  Created by Richard Mavis on 10/3/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

// Custom Class drop down list shows only those custom classes which are subclasses of currently selected object's class.
// From: http://stackoverflow.com/questions/29705534/xcode-6-interface-builder-does-not-show-custom-class

import UIKit

class NewEntryFormViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var viewFrame: UIView!

    @IBOutlet weak var newEntryForm: UIView!

    @IBOutlet weak var newEntryFormValueField: UITextView!
    @IBOutlet weak var newEntryFormTagsField: UITextView!

    @IBOutlet weak var newEntryFormButtonsBox: UIView!
    @IBOutlet weak var newEntryFormSaveButton: UIButton!
    @IBOutlet weak var newEntryFormCancelButton: UIButton!




    @IBAction func saveNewEntryFromForm() {
        print("Need to save new entry!")

        let newEntryValue = newEntryFormValueField.text
        let newEntryTags = newEntryFormTagsField.text

        print("New values: \(newEntryValue) & \(newEntryTags)")
    }





    //
    // UITextViewDelegate methods.
    // These methods occur in order of calling.
    //

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        print("Text view should begin editing?")
        return true
    }


    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        print("Text view should end editing?")
        return true
    }


    func textViewDidChange(textView: UITextView) {
        print("Text view did change!")
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        print("Replacing text! \(text)")

        if (text == "\n") {
            print("newline")
            textView.resignFirstResponder()
            return false
        }
        else {
            return true
        }
    }





    override func viewDidLoad() {
        super.viewDidLoad()

        print("Loading new entry form view controller!")

        newEntryFormValueField.delegate = self
        newEntryFormTagsField.delegate = self
    }


    //    required init?(coder decoder: NSCoder) {
    //        super.init(coder: decoder)
    //    }

}