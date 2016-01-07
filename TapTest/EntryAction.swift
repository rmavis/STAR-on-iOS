//
//  EntryAction.swift
//  TapTest
//
//  Created by Richard Mavis on 12/29/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation


class EntryAction {

    
    // Pass this an entry's value and, optionally, the URL scheme.
    // If the URL scheme is nil, then the default will be used.
    // This will allow the user to select the action for each value, which the UI
    // should allow them to do on a long tap of the table cell.  #HERE
    static func buildActionableURL(value: String, action: String? = nil) -> String? {
        // Reference: https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html

        // Phone numbers.
        if let _ = value.rangeOfString(Regex.phoneNumberPattern, options: .RegularExpressionSearch) {
            let act = (action == nil) ? "tel" : action!
            return EntryAction.prefixWithScheme(act, value: Regex.numbersOnly(value))
        }
        
        // Email addresses.
        else if let _ = value.rangeOfString(Regex.emailAddressPattern, options: .RegularExpressionSearch) {
            let act = (action == nil) ? "mailto" : action!
            return EntryAction.prefixWithScheme(act, value: value)
        }

        else {
            // URLs or nil.
            let parts = Regex.urlParts(value)

            // If there is no domain, then it is not a URL.
            if parts.domain == nil {
                return nil
            }
            else {
                // If there is no action...
                if action == nil {
                    // ...and no scheme, then add the scheme.
                    if parts.scheme == nil {
                        return EntryAction.prefixWithScheme("http", value: value)
                    }
                    // ...but there is a scheme, then the URL is fine as-is.
                    else {
                        return value
                    }
                }

                // If the action is given...
                else {
                    // ...and it is the same as the scheme, then there's no need to add it.
                    if parts.scheme == action {
                        return value
                    }
                    // ...but it's different than the scheme, then add it.
                    else {
                        return EntryAction.prefixWithScheme(action!, value: value)
                    }
                }
            }
        }
    }



    // There will need to be handlers for each permissible action.  #HERE
    static func prefixWithScheme(action: String, value: String) -> String {
        if action == "tel" {
            return "tel:\(value)"
        }
        else if action == "mailto" {
            return "mailto:\(value)"
        }
        else {
            return "\(action)://\(value)"
        }
    }
    
}