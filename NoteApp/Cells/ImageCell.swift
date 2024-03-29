//
//  ImageCell.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-25.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func setImage(_ image: UIImage?) {
        if let img : UIImage = image {
            imageView.image = img
            
        }
    }

}
