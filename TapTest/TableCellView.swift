//
//  TableCellView.swift
//  TapTest
//
//  Created by Richard Mavis on 9/29/15.
//  Copyright © 2015 Richard Mavis. All rights reserved.
//

import UIKit

class TableCellView: UITableViewCell {

    @IBOutlet weak var entryValueDisplay: UILabel!
    @IBOutlet weak var entryTagsDisplay: UILabel!


    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

}
