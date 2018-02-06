//
//  CustomTableViewCell.swift
//  PocketFriend
//
//  Created by Manish Parihar on 09/12/16.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
@IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
