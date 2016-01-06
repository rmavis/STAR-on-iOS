//
//  Regex.swift
//  TapTest
//
//  Created by Richard Mavis on 1/5/16.
//  Copyright © 2016 Richard Mavis. All rights reserved.
//

import Foundation

class Regex {
    
    static func match(string: String, _ pattern: String, options: NSRegularExpressionOptions = .AnchorsMatchLines) -> [String] {
        var matches = [String]()
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: options) {
            let nsstr = string as NSString
            
            regex.enumerateMatchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: nsstr.length), usingBlock: {
                (result: NSTextCheckingResult?, flags, stop) -> Void in
                if let result = result {
                    for index in 0...(result.numberOfRanges - 1) {
                        matches.append(nsstr.substringWithRange(result.rangeAtIndex(index)))
                    }
                }
            })
        }
        
        return matches
    }
    
}
