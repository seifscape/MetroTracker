//
//  MetroStationTableViewCell.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 12/31/18.
//  Copyright © 2018 District Meta Works, LLC. All rights reserved.
//

import UIKit

class MetroStationTableViewCell: UITableViewCell {
    @IBOutlet weak var lineColorOne:UIImageView?
    @IBOutlet weak var lineColorTwo:UIImageView?
    @IBOutlet weak var lineColorThree:UIImageView?
    @IBOutlet weak var lineColorFour:UIImageView?
    @IBOutlet var stationName:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
