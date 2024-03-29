//
//  Note.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-23.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import Foundation

struct Note : Codable, Equatable, CustomStringConvertible {
    
    static func ==(lhs: Note, rhs: Note) -> Bool {
        return lhs.noteName == rhs.noteName && lhs.timeStamp == rhs.timeStamp
    }
    
    var noteName : String
    var strFiles: [String] = []
    var lat: Double = 0.00
    var long: Double = 0.00
    var timeStamp: String?
    
    var description: String{
        return "Note: \(noteName), lat: \(lat), long: \(long )"
    }
    
}
