//
//  CocktailCell.swift
//  CoreData_StoreFavourites
//
//  Created by Adsum MAC 1 on 21/10/21.
//

import UIKit

class CocktailCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var userMaterial: UILabel!
    @IBOutlet weak var descriptionOfProduct: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var favBTN: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
