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

    @IBOutlet weak var newEntryFormViewBounder: UIView!

    @IBOutlet weak var formButtonsBox: UIView!
    @IBOutlet weak var formSaveButton: UIButton!
    @IBOutlet weak var formCancelButton: UIButton!

    @IBOutlet weak var entryFormBorder: UIView!

    @IBOutlet weak var newEntryFormScrollContainer: UIScrollView!

    @IBOutlet weak var newEntryForm: UIView!
    @IBOutlet weak var formValueField: UITextView!
    @IBOutlet weak var formTagsField: UITextView!

    let valueFieldPlaceholder = "Enter new text here."
    let tagsFieldPlaceholder = "Separate tags with linebreaks or commas."

    @IBOutlet weak var viewBounderBottomConstraint: NSLayoutConstraint!
    
    var currentKeyboardHeight:CGFloat = 0.0



    @IBAction func dismissKeyboard() {
        print("Need to dismiss keyboard!")

        if formValueField.isFirstResponder() {
            formValueField.resignFirstResponder()
        }
        else if formTagsField.isFirstResponder() {
            formTagsField.resignFirstResponder()
        }
        else {
            print("WTF is the first responder?")
        }
    }

    

    @IBAction func saveNewEntryFromForm() {
        print("Need to save new entry!")

        let newEntryValue = formValueField.text
        let newEntryTags = formTagsField.text

        print("New values: \(newEntryValue) & \(newEntryTags)")
    }
    
    
    
    func getFormFieldPlaceholder(formField: UITextView) -> String? {
        if (formField == formValueField) {
            return valueFieldPlaceholder
        }
            
        else if (formField == formTagsField) {
            return tagsFieldPlaceholder
        }
            
        else {
            return nil
        }
    }





    //
    // UITextViewDelegate methods.
    // These methods occur in order of calling.
    //

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        print("Text view should begin editing?")
        
        if getFormFieldPlaceholder(textView) == textView.text {
            textView.text = ""
        }
        
        return true
    }


    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        print("Text view should end editing?")
        
        if textView.text == "" {
            textView.text = getFormFieldPlaceholder(textView)
        }

        return true
    }


    func textViewDidChange(textView: UITextView) {
        print("Text view did change!")
    }

    // If newlines can separate tags, then this makes no sense.
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //        if (textView == formTagsField) {
        //            print("Replacing text! \(text)")
        //
        //            if (text == "\n") {
        //                print("newline")
        //                textView.resignFirstResponder()
        //                return false
        //            }
        //            else {
        //                return true
        //            }
        //        }
        //        
        //        else {
        //            return true
        //        }
        
        return true
    }



/*
    Loading new entry form view controller!
    Text view should begin editing?
    [Main VC] Keyboard will show!
    [New Entry Form VC] Keyboard will show!
*/

    func keyboardWillShow(notification: NSNotification) {
        print("[New Entry VC] Keyboard will show!")

        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);

            newEntryFormScrollContainer.contentInset = contentInsets
            newEntryFormScrollContainer.scrollIndicatorInsets = contentInsets
        }

        //        // If active text field is hidden by keyboard, scroll it so it's visible
        //        // Your app might not need or want this behavior.
        //        CGRect aRect = self.view.frame;
        //        aRect.size.height -= kbSize.height;
        //        if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        //            [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
        //        }
    }

    func keyboardWillHide(notification: NSNotification) {
        print("Keyboard will hide!")

        let contentInsets = UIEdgeInsetsZero
        newEntryFormScrollContainer.contentInset = contentInsets
        newEntryFormScrollContainer.scrollIndicatorInsets = contentInsets
    }






    override func viewDidLoad() {
        super.viewDidLoad()

        print("Loading new entry form view controller!")

        formValueField.delegate = self
        formTagsField.delegate = self
        
        formValueField.text = self.valueFieldPlaceholder
        formTagsField.text = self.tagsFieldPlaceholder

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

    }


    //    required init?(coder decoder: NSCoder) {
    //        super.init(coder: decoder)
    //    }

}