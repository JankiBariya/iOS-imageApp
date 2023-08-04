//
//  TableViewCell.swift
//  imageApp
//
//  Created by PMCLAP1240 on 07/02/23.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    // properties
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var photographerLabel: UILabel!
    @IBOutlet weak var altTextLabel: UILabel!
    
    

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
