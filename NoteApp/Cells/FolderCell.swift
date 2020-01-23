//
//  FolderCell.swift
//  Rudrik_c0757521_Note_p1
//
//  Created by MacStudent on 2019-11-07.
//  Copyright © 2019 MacStudent. All rights reserved.
//

import UIKit

class FolderCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = #colorLiteral(red: 0.6439564258, green: 0.8479013801, blue: 0.9977299744, alpha: 1)
        self.backgroundColor = #colorLiteral(red: 0.6439564258, green: 0.8479013801, blue: 0.9977299744, alpha: 1)
        self.tintColor = #colorLiteral(red: 0.127715386, green: 0.1686877555, blue: 0.2190790727, alpha: 0.9254236356)
        self.accessoryView?.backgroundColor = #colorLiteral(red: 0.6439564258, green: 0.8479013801, blue: 0.9977299744, alpha: 1)
    }
     
    /*
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    */
    
}
