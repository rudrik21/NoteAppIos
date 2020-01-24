//
//  NoteData.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-23.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import Foundation
import CoreData

@objc
public class FolderData: NSManagedObject{
    @NSManaged var folderName: String
    @NSManaged var folderIndex: Int32
    @NSManaged var strNotes: String
    
    var folder: Folder{
        get{
            return Folder(folderName: self.folderName, index: Int(self.folderIndex), notes: stringTojson(str: strNotes))
        }
        
        set{
            self.folderName = newValue.folderName
            self.folderIndex = Int32(newValue.index)
            self.strNotes = jsonTostring(notes: newValue.notes)
        }
    }
}
