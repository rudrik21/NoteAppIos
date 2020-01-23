//
//  Note.swift
//  Rudrik_c0757521_Note_p1
//
//  Created by MacStudent on 2019-11-07.
//  Copyright © 2019 MacStudent. All rights reserved.
//

import Foundation

struct Note : CustomStringConvertible {
    var noteName : String
    var index : Int?
    var description: String{
        return noteName
    }
}
