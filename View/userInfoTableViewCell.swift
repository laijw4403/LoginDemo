//
//  userInfoTableViewCell.swift
//  LoginDemo
//
//  Created by Tommy on 2021/1/27.
//

import UIKit

class userInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var userInfoImageView: UIImageView!
    @IBOutlet weak var userInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
