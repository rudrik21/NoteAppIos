//
//  Note.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-23.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import Foundation

struct Note : Codable, Equatable, CustomStringConvertible {
    var noteName : String
    var strFiles: [String] = []
    var lat: Double = 0.00
    var long: Double = 0.00
    
    var description: String{
        return "Note: \(noteName), lat: \(lat ), long: \(long )"
    }
    
}
