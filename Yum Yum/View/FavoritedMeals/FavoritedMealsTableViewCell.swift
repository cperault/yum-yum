//
//  FavoritedMealsTableViewCell.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/15/21.
//

import UIKit

class FavoritedMealsTableViewCell: UITableViewCell {
    @IBOutlet var favoritedMealName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
