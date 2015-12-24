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
    
    @IBOutlet weak var formButtonsBox: UIView!
    @IBOutlet weak var formSaveButton: UIButton!
    @IBOutlet weak var formCancelButton: UIButton!
    
    @IBOutlet weak var entryFormBorder: UIView!
    
    @IBOutlet weak var newEntryFormScrollFrame: UIView!
    @IBOutlet weak var newEntryFormScrollContainer: UIScrollView!
    
    @IBOutlet weak var newEntryForm: UIView!
    @IBOutlet weak var formValueField: UITextView!
    @IBOutlet weak var formTagsField: UITextView!
    
    let valueFieldPlaceholder = "Enter new text here."
    let tagsFieldPlaceholder = "Separate tags with linebreaks or commas.\nOnly one of each tag is needed."
    
    let validElementColor = UIColor.whiteColor()
    let invalidElementColor = UIColor.lightGrayColor()
    
    var showingPlaceholder = [UITextView: Bool]()
    var fieldIsValid = [UITextView: Bool]()

    
    
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
    
    

    
    
    //
    // These methods deal with the form validation.
    //
    
    
    func validateFormFields() {
        for field in [formValueField, formTagsField] {
            validateFormField(field)
        }
    }
    
    
    
    func validateFormField(field: UITextView) {
        // The SAVE button validity state mirrors that of the value field.
        if field == formValueField {
            let state = getValidStateColor(isValueFieldValid)

            if state.valid != fieldIsValid[field] {
                setTextFieldColor(field, color: state.color)
                formSaveButton.enabled = state.valid
                fieldIsValid[field] = state.valid
            }
        }

        // Because the tags are optional.
        else if field == formTagsField {
            let state = getValidStateColor(isTagsFieldFilled)

            if state.valid != fieldIsValid[field] {
                setTextFieldColor(field, color: state.color)
                fieldIsValid[field] = state.valid
            }
        }
            
        else {
            print("Don't know how to validate this field...")
        }
    }
    
    
    
    func getValidStateColor(validator: () -> Bool) -> (valid: Bool, color: UIColor) {
        let isValid = validator()
        let color = (isValid == true) ? validElementColor : invalidElementColor
        
        return (isValid, color)
    }

    
    
    // The value field must not be its placeholder or empty.
    func isValueFieldValid() -> Bool {
        if (showingPlaceholder[formValueField] == true) || (formValueField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "") {
            return false
        }
        else {
            return true
        }
    }
    
    
    
    // The tags field is optional, so this returns true if its value will be saved.
    func isTagsFieldFilled() -> Bool {
        if (showingPlaceholder[formTagsField] == true) || (formTagsField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "") {
            return false
        }
        else {
            return true
        }
    }
    
    
    
    func setTextFieldColor(field: UITextView, color: UIColor) {
        field.layer.borderColor = color.CGColor
        field.textColor = color
    }
    

    
    // This function is connected to the SAVE button.
    // If the form field are invalid, then the button will be the inactive color,
    // so it's okay if this function silently does nothing.
    @IBAction func saveNewEntryFromForm() {
        print("Need to save new entry!")
        
        // The value field is required.
        if isValueFieldValid() == true {
            // The tags are optional but, if present, must be an array.
            var tags: [String] = []
            if showingPlaceholder[formTagsField] == false {
                tags = EntryTags.stringToCleanArray(formTagsField.text)
            }
            
            let entry = Entry(value: formValueField.text, tags: tags)
            
            if StoreManager.saveEntryToFile(entry) == true {
                print("Saved new entry to store!")
                print("New entry value: \(entry.value.string)")
                print("New entry tags: \(entry.tags.join(", "))")
                print("New entry metadata: \(entry.metadata.join(", "))")
            }
            else {
                print("Failed to save new entry to store : (")
            }
        }
            
        else {
            print("This form has an invalid Value.")
        }
    }
    
    
    
    
    
    //
    // These methods deal with the field placeholders.
    //

    
    func getFormFieldPlaceholder(field: UITextView) -> String? {
        if (field == formValueField) {
            return valueFieldPlaceholder
        }
            
        else if (field == formTagsField) {
            return tagsFieldPlaceholder
        }
            
        else {
            return nil
        }
    }
    
    
    
    // This runs when the view appears.
    func setFormInitialState() {
        // These only need to be set once.
        // Changing the `enabled` state will change the button's color.
        formSaveButton.setTitleColor(validElementColor, forState: .Normal)
        formSaveButton.setTitleColor(invalidElementColor, forState: .Disabled)
        
        formValueField.text = valueFieldPlaceholder
        formTagsField.text = tagsFieldPlaceholder

        // These booleans are set so that they can be checked,
        // rather than checking against the placeholder string.
        showingPlaceholder[formValueField] = true
        showingPlaceholder[formTagsField] = true
        
        // These are set to true
        // 1. to initialize the keys in the dictionary,
        // 2. but they are actually invalid,
        // 3. so the validator will flag them as invalid and color the fields appropriately.
        fieldIsValid[formValueField] = true
        fieldIsValid[formTagsField] = true
        validateFormFields()
    }
    
    
    
    
    
    //
    // UITextViewDelegate methods.
    // These methods occur in order of calling.
    //
    
    
    // This fires just before the text field gains focus.
    // The form fields will be colored correctly before this is called for the first time.
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        // print("Text view should begin editing? '\(textView.text)'")
        
        if showingPlaceholder[textView] == true {
            textView.selectedRange = NSMakeRange(0, 0)
        }
        
        return true
    }
    
    
    
    // This fires before the field's value changes. Every keystroke.
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // print("Should change text in range? Replacement text: '\(text)'")
        
        if text.characters.count > 0 {
            if showingPlaceholder[textView] == true {
                showingPlaceholder[textView] = false
                textView.text = ""
            }
        }
        
        else if text.characters.count == 0 {
            print("Entering 0 characters!")
        }
        
        else {
            print("Entering negative characters?!?!?!")
        }

        return true
    }
    
    

    //    func textViewDidBeginEditing(textView: UITextView) {
    //        print("Text field did begin editing")
    //    }

    
    
    // This fires after the field's value changes. Every keystroke.
    func textViewDidChange(textView: UITextView) {
        // print("Text view did change '\(textView.text!)'")
        
        if textView.text == "" {
            showingPlaceholder[textView] = true
            textView.text = getFormFieldPlaceholder(textView)
        }
        else {
            showingPlaceholder[textView] = false
        }
        
        validateFormField(textView)
    }
    
    
    
    // This fires when the selection or cursor position changes.
    func textViewDidChangeSelection(textView: UITextView) {
        // print("Text view selection did change!")
        
        if showingPlaceholder[textView] == true {
            textView.selectedRange = NSMakeRange(0, 0)
        }
    }
    
    
    
    // This fires when the field loses focus.
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        // print("Text view should end editing? '\(textView.text)'")
        
        if textView.text == "" {
            textView.text = getFormFieldPlaceholder(textView)
            showingPlaceholder[textView] = true
        }
        
        return true
    }
    
    
    
    
    
    //
    // These functions are related to the keyboard's appearance
    // and disappearance. Mostly to resize the views.
    //
    
    
    // This should fire only once: the event observer will be removed.
    func keyboardWillShow(notification: NSNotification) {
        // print("[New Entry VC] Keyboard will show!")
        
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
            
            newEntryFormScrollContainer.contentInset = contentInsets
            newEntryFormScrollContainer.scrollIndicatorInsets = contentInsets
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    // This should never be fired.
    func keyboardWillHide(notification: NSNotification) {
        // print("Keyboard will hide!")
        
        let contentInsets = UIEdgeInsetsZero
        newEntryFormScrollContainer.contentInset = contentInsets
        newEntryFormScrollContainer.scrollIndicatorInsets = contentInsets
    }
    
    
    
    
    
    //
    // These functions are related to the view's loading,
    // appearance, and disappearance.
    //
    //
    
    
    // The view does not need to load every time it appears.
    // Functions that should run every time should be put in `viewWillAppear`.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print("Loading new entry form view controller!")

        for field in [formValueField, formTagsField] {
            field.layer.borderWidth = 1
            field.delegate = self
        }

        setFormInitialState()
    }
    
    
    
    // This is called every time the view appears.
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // print("[Form VC] View will appear")
        
        // validateFormFields()

        // This event listener is added so the view can be adjusted according to the
        // keyboard size. After the keyboard appears, the listener will be removed.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // This will fire `textViewShouldBeginEditing` with `formValueField` as the parameter.
        // It will also fire `keyboardWillShow`, which will adjust the view's scrollable area.
        formValueField.becomeFirstResponder()
    }
    
    
    
    // This is called every time the view disappears.
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // print("[Form VC] View will disappear")
        
        // This doesn't need to occur since it has already been removed.
        // NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}