//
//  EntryAction.swift
//  TapTest
//
//  Created by Richard Mavis on 12/29/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import Foundation


//
// This is from https://github.com/hayashikun/Regex/blob/master/Regex/Regex.swift
//
extension String {
    func extract(pattern: String, options: NSRegularExpressionOptions = .AnchorsMatchLines) -> [[String]] {
        var allMatches = [[String]]()
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return []
        }
        let nsStr = self as NSString
        regex.enumerateMatchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: nsStr.length)) {
            (result: NSTextCheckingResult?, flags, ptr) -> Void in
            if let result = result {
                var matches = [String]()
                for index in 0...result.numberOfRanges - 1 {
                    let range = result.rangeAtIndex(index)
                    matches.append(nsStr.substringWithRange(range))
                }
                allMatches.append(matches)
            }
        }
        return allMatches
    }
}


class EntryAction {

    
    // Pass this an entry's value and, optionally, the URL scheme.
    // If the URL scheme is nil, then the default will be used.
    // This will allow the user to select the action for each value, which the UI
    // should allow them to do on a long tap of the table cell.  #HERE
    static func buildURL(value: String, action: String? = nil) -> (open: Bool, value: String) {
        // Reference: https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html
        
        let act: String
        let val: String
        
        // Phone numbers.
        if let _ = value.rangeOfString("^[0-9]+?[- .]?\\(?[0-9]{3}\\)?[- .]?[0-9]{3}[- .]?[0-9]{4}$", options: .RegularExpressionSearch) {
            act = (action == nil) ? "tel" : action!
            val = EntryAction.cleanPhoneNumber(value)
        }
        
        // Email addresses.
        else if let _ = value.rangeOfString("^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}$", options: .RegularExpressionSearch) {
            act = (action == nil) ? "mailto" : action!
            val = value
        }
        
        // URLs.
        else if let urlMatch = EntryAction.checkURL(value) {
            if let scheme = urlMatch.scheme {
                act = (action == nil) ? scheme : action!
            }
            else {
                act = (action == nil) ? "http://" : action!
            }
            val = value
        }

        else {
            act = "copy"
            val = value
        }
        
        if act == "copy" {
            return (false, val)
        }
        else {
            return (true, "\(act)://\(val)")
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
    
    
    
    // This function is horribly written.  #HERE
    static func checkURL(check: String) -> (matches: Bool, scheme: String?)? {
        do {
            let charPattern = "^([a-z]+://)?([0-9a-z.-]+\\.){1,}[a-z]{2,}(\\/[^ ]*)?$"
            let charRegex = try NSRegularExpression.init(pattern: charPattern, options: .CaseInsensitive)
            
            if charRegex.numberOfMatchesInString(check, options: .Anchored, range: NSMakeRange(0, (check as NSString).length)) > 0 {
                let scheme = check.extract("^([a-z]+://)")
                if scheme.isEmpty {
                    return (true, nil)
                }
                else {
                    return (true, scheme[0][0])
                }
            }
            
            else {
                let ipPattern = "^([a-z]+://)?([0-9]+\\.){3}[0-9]+\\/[^ ]+$"
                let ipRegex = try NSRegularExpression.init(pattern: ipPattern, options: .CaseInsensitive)
                    
                if ipRegex.numberOfMatchesInString(check, options: .Anchored, range: NSMakeRange(0, (check as NSString).length)) > 0 {
                    let scheme = check.extract("^([a-z]+://)")
                    if scheme.isEmpty {
                        return (true, nil)
                    }
                    else {
                        return (true, scheme[0][0])
                    }
                }
                    
                else {
                    return nil
                }
            }
        }
        
        catch let error as NSError {
            print("Error building URL regex:")
            print(error)
            return nil
        }
    }
    
}