//
//  TakeNoteVC.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-23.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import UIKit

class TakeNoteVC: UIViewController {

    var delegate : NotesVC?
    var currentNote: Note?
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var txtNote: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var navTitle: String?
        if (currentNote?.noteName) != nil{
            navTitle = String((currentNote?.noteName.prefix(upTo: (currentNote?.noteName.index((currentNote?.noteName.startIndex)!, offsetBy: (currentNote?.noteName.count)!/2))!))!) + "....."
        }else{
            navTitle = "New Note"
        }
        navBar.title = navTitle
        txtNote.becomeFirstResponder()
        txtNote.text = currentNote?.noteName
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if let currentFolder = delegate?.currentFolder{
            if !txtNote.text.isEmpty{
                if let note = currentNote {
                    if currentFolder.notes.contains(where: { (n) -> Bool in
                        n.index == note.index
                    }){
                        currentNote!.noteName = txtNote.text
                        delegate?.currentFolder?.updateNote(note: currentNote!, index: currentNote!.index!)
                    }
                }else{
                    let index = delegate?.currentFolder?.notes.count
                    delegate?.currentFolder?.addNote(note: Note(noteName: txtNote.text, index: index))
                }
            }
        }
        delegate?.updateTable()
    }

}
