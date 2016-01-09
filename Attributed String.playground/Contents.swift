//: Playground - noun: a place where people can play

import UIKit

// var str = "Hello, playground"


func highlightMatch(string: String, pattern: String) -> NSMutableAttributedString {
    let nsstr = string as NSString
    let attrstr = NSMutableAttributedString(string: string)

    let match = nsstr.rangeOfString(pattern, options: .RegularExpressionSearch)
    let font = UIFont.init(name: "GillSans", size: 12)
    let bgcolor = UIColor.yellowColor()
    let fgcolor = UIColor.blueColor()

    attrstr.addAttribute(NSFontAttributeName, value: font!, range: match)
    attrstr.addAttribute(NSBackgroundColorAttributeName, value: bgcolor, range: match)
    attrstr.addAttribute(NSForegroundColorAttributeName, value: fgcolor, range: match)
    
    return attrstr
}

highlightMatch("Well hi howdy", pattern: "hi")
highlightMatch("Well hi howdy", pattern: "howdy")
