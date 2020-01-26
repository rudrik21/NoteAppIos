//
//  ListFoldersVC.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-23.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import UIKit

class ListFoldersVC: UIViewController {

    //  MARK: VARIABLES
    var delegate : NotesVC?
    var sourceFolder : Folder?
    var selectedNotes: [Note]?
    
    @IBOutlet weak var tvListFolders: UITableView!
    
    override func viewDidLoad() {
        start()
    }
    
    func start() {
        tvListFolders.delegate = self
        tvListFolders.dataSource = self
        tvListFolders.backgroundColor = #colorLiteral(red: 0.127715386, green: 0.1686877555, blue: 0.2190790727, alpha: 0.9254236356)
        tvListFolders.rowHeight = 50
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
    
extension ListFoldersVC : UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print(Folder.folders.count)
            return Folder.folders.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell") as? FolderCell {
                    let folder : Folder = Folder.folders[indexPath.row]
                print("ListFOlder Cell: ", folder.folderName)
                    cell.textLabel?.text = folder.folderName
                    cell.detailTextLabel?.text = String(folder.notes.count)
                    return cell
                }
            
            return UITableViewCell()
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if !selectedNotes!.isEmpty{
                let toFolder = Folder.folders[indexPath.row]
                let alert = UIAlertController(title: "Move to \(toFolder.folderName)", message: "Are you sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Move", style: .default, handler: { (act) in
                    self.sourceFolder?.moveNote(notes: self.selectedNotes!, toFolder: Folder.folders[indexPath.row])
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.updateTable()
                }))
            
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (act) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                alert.actions[1].setValue(#colorLiteral(red: 0.127715386, green: 0.1686877555, blue: 0.2190790727, alpha: 0.9254236356), forKey: "titleTextColor")
                alert.actions[1].setValue(UIColor.red, forKey: "titleTextColor")
                
                present(alert, animated: true, completion: nil)
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


