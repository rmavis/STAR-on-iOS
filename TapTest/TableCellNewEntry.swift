//
//  TableCellNewEntry.swift
//  TapTest
//
//  Created by Richard Mavis on 9/29/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import UIKit

class TableCellNewEntry: UITableViewCell {

    @IBOutlet weak var entryValueField: UIView!
    @IBOutlet weak var entryTagsField: UITextView!

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
}
