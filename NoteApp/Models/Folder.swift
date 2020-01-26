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
        self.notes.append(note)
        updateCurrent()
    }
    
    mutating func updateNote(newNote: Note, oldNote: Note) {
//        let i = self.notes.filter { (n) -> Bool in
//            n.index == note.index
//            }.first?.index
//        self.notes[i!] = note
        self.notes.remove(at: notes.firstIndex(of: oldNote)!)
        self.notes.append(newNote)
        updateCurrent()
    }
    
    mutating func moveNote(notes: [Note], toFolder: Folder) {
        
        for n in notes{
            self.removeNote(notes: [n])
            Folder.folders[toFolder.index].notes.append(n)
        }
        
        Folder.folders[self.index] = self
    }
    
    mutating func removeNote(notes: [Note]) {
        self.notes.forEach { (n) in
            self.notes.remove(at: self.notes.firstIndex(of: n)!)
        }
        updateCurrent()
    }

    func updateCurrent() {
        Folder.folders[self.index] = self
    }
}
