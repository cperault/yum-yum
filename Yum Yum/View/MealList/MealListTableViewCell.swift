//
//  MealListTableViewCell.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/10/21.
//

import UIKit

class MealListTableViewCell: UITableViewCell {
    @IBOutlet var mealNameLabel: UILabel!
    var meal: Meal?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
