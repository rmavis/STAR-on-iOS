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
    static func buildURL(value: String, action: String? = nil) -> (open: Bool, value: String) {
        // Reference: https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html
        
        var act: String? = nil
        var val: String? = nil

        // Phone numbers.
        if let _ = value.rangeOfString("^[0-9]+?[- .]?\\(?[0-9]{3}\\)?[- .]?[0-9]{3}[- .]?[0-9]{4}$", options: .RegularExpressionSearch) {
            act = (action == nil) ? "tel" : action!
            val = EntryAction.cleanPhoneNumber(value)
            return (true, "\(act!):\(val!)")
        }
        
        // Email addresses.
        else if let _ = value.rangeOfString("^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}$", options: .RegularExpressionSearch) {
            act = (action == nil) ? "mailto" : action!
            val = value
            return (true, "\(act!):\(val!)")
        }

        else {
            let parts = EntryAction.urlToParts(value)

            // URLs have domains.
            if let domain = parts.domain {
                if let action = action {
                    act = action
                    val = (parts.uri == nil) ? domain : "\(domain)\(parts.uri!)"
                }
                else {
                    act = (parts.scheme == nil) ? "http" : parts.scheme!
                    val = (parts.uri == nil) ? domain : "\(domain)\(parts.uri!)"
                }
                return (true, "\(act!)://\(val!)")
            }

            else {
                return (false, value)
            }
        }
    }
    
    

    static func cleanPhoneNumber(dirty: String) -> String {
        let ns_str = (dirty as NSString)
        
        let number = ns_str.stringByReplacingOccurrencesOfString(
            "[^0-9]",
            withString: "",
            options: .RegularExpressionSearch,
            range: NSMakeRange(0, ns_str.length)
        )
        
        return number
    }
    
    
    
    static func urlToParts(check: String) -> (scheme: String?, domain: String?, uri: String?) {
        var scheme: String? = nil
        var domain: String? = nil
        var uri: String? = nil
        
        let patterns = [
            // Ordinary URLs. ASCII only. Will need to expand this.  #HERE
            "^(?:([-A-Z0-9a-z_]+):\\/\\/)?((?:[-A-Z0-9a-z_]+\\.){1,}[-A-Z0-9a-z_]{2,})(\\/[^ ]*)?$",
            // IPv4 addresses. Will need to expand for IPv6.  #HERE
            "^(?:([-A-Z0-9a-z_]+):\\/\\/)?((?:[0-9]+\\.){3}[0-9]+)(\\/[^ ]*)?$"
        ]
        
        loop: for pattern in patterns {
            let groups = Regex.match(check, pattern)
            if !groups.isEmpty {
                // These will be strings or nil.
                scheme = groups[1]
                domain = groups[2]
                uri = groups[3]
                break loop
            }
        }
        
        return (scheme, domain, uri)
    }
    
}