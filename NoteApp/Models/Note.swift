//
//  Note.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-23.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import Foundation

struct Note : Codable, CustomStringConvertible {
    var noteName : String
    var index : Int?
    var description: String{
        return noteName
    }
    
}
