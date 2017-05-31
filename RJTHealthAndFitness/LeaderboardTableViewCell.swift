//
//  LeaderboardTableViewCell.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/29/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func thumbDown(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func thumbUp(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
