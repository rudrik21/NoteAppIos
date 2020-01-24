//
//  Folder.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-23.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import Foundation

struct Folder : CustomStringConvertible {
    var folderName : String
    var index: Int
    var notes : [Note] = []
    
    static var folders : [Folder] = []
    
    var description: String{
        return "\(folderName)"
    }
}

extension Folder{
    mutating func addNote(note : Note) {
        notes.append(note)
        updateCurrent()
    }
    
    mutating func updateNote(note: Note, index : Int) {
        let i = self.notes.filter { (n) -> Bool in
            n.index == note.index
            }.first?.index
        self.notes[i!] = note
        updateCurrent()
    }
    
    mutating func moveNote(notes: [Note], toFolder: Folder) {
        notes.forEach { (note) in
            Folder.folders[toFolder.index].notes.append(Note(noteName: note.noteName, index: Folder.folders[toFolder.index].notes.count))
        }
        
        for n in notes{
            self.removeNote(note: n)
        }
        Folder.folders[self.index] = self
    }
    
    mutating func removeNote(note: Note) {
        self.notes.removeAll { (n) -> Bool in
//            print("\(n.index) == \(note.index)")
            return n.index == note.index
        }
        updateCurrent()
    }

    func updateCurrent() {
        Folder.folders[self.index] = self
    }
}
