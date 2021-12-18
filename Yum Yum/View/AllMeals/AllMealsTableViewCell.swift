//
//  AllMealsTableViewCell.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/11/21.
//

import UIKit

class AllMealsTableViewCell: UITableViewCell {
    
    @IBOutlet var mealNameLabel: UILabel!
    var meal: Meal?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
