//: Playground - noun: a place where people can play

// import UIKit
import Foundation

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


class Regex {
    
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


    
    //    static func match(string: String, _ pattern: String, options: NSRegularExpressionOptions = .AnchorsMatchLines) -> [String?]? {
    //        var matches = [String?]()
    //
    //        do {
    //            let regex = try NSRegularExpression.init(pattern: pattern, options: options)
    //            let nsstr = string as NSString
    //
    //            let groups = regex.matchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: nsstr.length))
    //            for group in groups {
    //                group.numberOfRanges
    ////                nsstr.substringWithRange(group.rangeAtIndex(0))
    ////                nsstr.substringWithRange(group.rangeAtIndex(1))
    ////                nsstr.substringWithRange(group.rangeAtIndex(2))
    ////                nsstr.substringWithRange(group.rangeAtIndex(3))
    //
    //                group.rangeAtIndex(0).length
    //                group.rangeAtIndex(1).length
    //                group.rangeAtIndex(2).length
    //                group.rangeAtIndex(3).length
    //
    //                for index in 0...(group.numberOfRanges - 1) {
    //                    let range = group.rangeAtIndex(index)
    //                    if range.length > 0 {
    //                        matches.append(nsstr.substringWithRange(group.rangeAtIndex(index)))
    //                    }
    //                    else {
    //                        matches.append(nil)
    //                    }
    //                }
    //            }
    //
    ////            regex.enumerateMatchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: nsstr.length), usingBlock: {
    ////                (result: NSTextCheckingResult?, flags, stop) -> Void in
    ////                if let result = result {
    ////                    for index in 0...(result.numberOfRanges - 1) {
    ////                        let part = nsstr.substringWithRange(result.rangeAtIndex(index))
    ////                        if part.characters.count > 0 {
    ////                            matches.append(part)
    ////                        }
    ////                    }
    ////                }
    ////            })
    //        }
    //
    //        catch let error as NSError {
    //            print("Error building URL regex:")
    //            print(error)
    //            return nil
    //        }
    //        
    //        return matches
    //    }

}


var str = "mailto://m.www.what.ever/abc-def/ghijklm?hi&ho+++"
//Regex.match(str, "^([a-z]+)://")
//Regex.match(str, "^(([-A-Z0-9a-z_]+):\\/\\/)")
Regex.match(str, "^(?:([-A-Z0-9a-z_]+):\\/\\/)?((?:[-A-Z0-9a-z_]+\\.){1,}[-A-Z0-9a-z_]{2,})(\\/[^ ]*)?$")
Regex.match("ftp://127.0.0.1", "^(?:([-A-Z0-9a-z_]+):\\/\\/)?((?:[0-9]+\\.){3}[0-9]+)(\\/[^ ]*)?$")

// var marches = str.extract("^(([A-Za-z]+):\\/\\/)?(([A-Za-z]+\\.){1,})[A-Za-z]{2,}")


