//
//  Regex.swift
//  TapTest
//
//  Created by Richard Mavis on 1/5/16.
//  Copyright © 2016 Richard Mavis. All rights reserved.
//

import Foundation

class Regex {


    static let phoneNumberPattern = "^[0-9]+?[- .]?\\(?[0-9]{3}\\)?[- .]?[0-9]{3}[- .]?[0-9]{4}$"
    static let emailAddressPattern = "^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}$"
    // Ordinary URLs. ASCII only. Will need to expand this.  #HERE
    static let urlMatchingPattern = "^(?:([-A-Z0-9a-z_]+):\\/\\/)?((?:[-A-Z0-9a-z_]+\\.){1,}[-A-Z0-9a-z_]{2,})(\\/[^ ]*)?$"
    // IPv4 addresses. Will need to expand for IPv6.  #HERE
    static let ipv4MatchingPattern = "^(?:([-A-Z0-9a-z_]+):\\/\\/)?((?:[0-9]+\\.){3}[0-9]+)(\\/[^ ]*)?$"



    // Pass this a string, a match pattern, and optionally any match options.
    // It will return an array of matches according to the match pattern.
    // Capture groups that do not match will be `nil` in the returned array.
    static func match(string: String, _ pattern: String, options: NSRegularExpressionOptions = .AnchorsMatchLines) -> [String?] {
        var matches = [String?]()

        do {
            let nsstr = string as NSString
            let regex = try NSRegularExpression(pattern: pattern, options: options)

            regex.enumerateMatchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: nsstr.length), usingBlock: {
                (result: NSTextCheckingResult?, flags, stop) -> Void in
                if let result = result {
                    for index in 0...(result.numberOfRanges - 1) {
                        let range = result.rangeAtIndex(index)
                        if range.length > 0 {
                            matches.append(nsstr.substringWithRange(range))
                        }
                        else {
                            matches.append(nil)
                        }
                    }
                }
            })
        }

        catch let error as NSError {
            print("Error building regex to match:\n\(error)")
        }
        
        return matches
    }



    static func numbersOnly(string: String) -> String {
        let nsstr = string as NSString

        let numbers = nsstr.stringByReplacingOccurrencesOfString(
            "[^0-9]",
            withString: "",
            options: .RegularExpressionSearch,
            range: NSMakeRange(0, nsstr.length)
        )

        return numbers
    }



    static func urlParts(check: String) -> (scheme: String?, domain: String?, uri: String?) {
        var scheme: String? = nil
        var domain: String? = nil
        var uri: String? = nil

        let patterns = [
            Regex.urlMatchingPattern,
            Regex.ipv4MatchingPattern
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




//
// This is from https://github.com/hayashikun/Regex/blob/master/Regex/Regex.swift
//
//extension String {
//    func extract(pattern: String, options: NSRegularExpressionOptions = .AnchorsMatchLines) -> [[String]] {
//        var allMatches = [[String]]()
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
//            return []
//        }
//        let nsStr = self as NSString
//        regex.enumerateMatchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: nsStr.length)) {
//            (result: NSTextCheckingResult?, flags, ptr) -> Void in
//            if let result = result {
//                var matches = [String]()
//                for index in 0...result.numberOfRanges - 1 {
//                    let range = result.rangeAtIndex(index)
//                    matches.append(nsStr.substringWithRange(range))
//                }
//                allMatches.append(matches)
//            }
//        }
//        return allMatches
//    }
//}