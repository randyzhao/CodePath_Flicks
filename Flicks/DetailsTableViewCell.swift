//
//  DetailsTableViewCell.swift
//  Flicks
//
//  Created by randy_zhao on 5/19/16.
//  Copyright © 2016 randy_zhao. All rights reserved.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(name: String, value: String) {
        let mutableString = NSMutableAttributedString(string: "\(name): \(value)")
        mutableString.addAttribute(
            NSForegroundColorAttributeName,
            value: UIColor.grayColor(),
            range: NSRange(location: name.characters.count + 2, length: value.characters.count)
        )
        contentLabel.attributedText = mutableString
    }
}
