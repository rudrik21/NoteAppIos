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
    var newNote: Note?
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var cvFiles: UICollectionView!
    
    @IBOutlet weak var txtNote: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
        initCollectionView()
    }
    
    func start() {
        var navTitle: String?
        if let currentNote = currentNote{
            navTitle = String((currentNote.noteName.prefix(upTo: (currentNote.noteName.index((currentNote.noteName.startIndex), offsetBy: (currentNote.noteName.count)/2))))) + "....."
            newNote = currentNote
        }else{
            navTitle = "New Note"
        }
        navBar.title = navTitle
        txtNote.becomeFirstResponder()
        txtNote.text = newNote?.noteName
        
        newNote?.strFiles.append("abc.png")
        newNote?.strFiles.append("song.mp3")
    }
    
    func initCollectionView() {
        cvFiles.delegate = self
        cvFiles.dataSource = self
        
        cvFiles.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        cvFiles.register(UINib(nibName: "AudioCell", bundle: nil), forCellWithReuseIdentifier: "AudioCell")
        
    }

    /*
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if (delegate?.currentFolder) != nil{
            if !txtNote.text.isEmpty{
                if let oldNote = currentNote {
                    newNote!.noteName = txtNote.text
                    delegate?.currentFolder?.updateNote(newNote: newNote!, oldNote: oldNote)
                    
                }else{
                    newNote = Note(noteName: txtNote.text, strFiles: [])
                    delegate?.currentFolder?.addNote(note: newNote!)
                }
            }
        }
        delegate?.updateTable()
    }

}

extension TakeNoteVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = (self.view.frame.size.width - 12 * 3) / 3 //some width
            let height = width * 1.5 //ratio
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newNote?.strFiles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        if !(newNote?.strFiles.isEmpty)! {
            let i = indexPath.row
            
            if (newNote?.strFiles[i].hasSuffix(".png"))! {
                print("is photo")
                if let cell : ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell{
                    
                    return cell
                }
            }
            
            if (newNote?.strFiles[i].hasSuffix(".mp3"))! {
                print("is audio")
                if let cell : AudioCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCell", for: indexPath) as? AudioCell{
                    
                    return cell
                }
            }
        }
        return UICollectionViewCell()
    }
    
}
