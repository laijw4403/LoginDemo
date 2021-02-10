//
//  userHeaderTableViewCell.swift
//  LoginDemo
//
//  Created by Tommy on 2021/1/27.
//

import UIKit

class userHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
