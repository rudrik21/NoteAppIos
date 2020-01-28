//
//  FoldersVC.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-23.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import UIKit
import CoreData

class FoldersVC: UIViewController, UISearchResultsUpdating {

    @IBOutlet weak var tvFolders: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    var search: UISearchController?
    var filteredFolders: [Folder] = []
    
    //  MARK: viewDidLoad
        override func viewDidLoad() {
            super.viewDidLoad()
            start()

        }
        
        //  MARK: INITIALIZATION
        func start() {
            tvFolders.delegate = self
            tvFolders.dataSource = self
            tvFolders.backgroundColor = #colorLiteral(red: 0.127715386, green: 0.1686877555, blue: 0.2190790727, alpha: 0.9254236356)
            tvFolders.rowHeight = 50
            
            search = UISearchController(searchResultsController: nil)
            search?.searchResultsUpdater = self
            search?.obscuresBackgroundDuringPresentation = false
            search?.searchBar.placeholder = "Search..."
            navigationItem.searchController = search
            
            search?.searchBar.text = ""
            filteredFolders = Folder.folders
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(releaseFocus))
            navigationController?.navigationBar.addGestureRecognizer(tap)
        }
    
        @objc func releaseFocus() {
            resignFirstResponder()
        }
    
        func updateSearchResults(for searchController: UISearchController) {
               guard let text = searchController.searchBar.text else { return }
            if text.isEmpty {
                filteredFolders = Folder.folders
                tvFolders.reloadData()
            }else{
                var res = [Folder]()
                Folder.folders.forEach { (f) in
                    var counter = 0
                    f.notes.forEach { (n) in
                        if n.noteName.contains(text){
                            counter += 1
                        }
                    }
                    if counter > 0{
                        res.append(f)
                    }
                }
                filteredFolders = res
                tvFolders.reloadData()
            }
        }
    
        //  MARK: ON CREATE NEW FOLDER
        @IBAction func onAddNewFolder(_ sender: UIBarButtonItem) {
            createNewFolder(title: "New Folder", "Enter a name for this folder.")
        }
        
        //  MARK: WHILE CREATING NEW FOLDER
        func createNewFolder(title : String, _ msg : String? = nil) {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addTextField { (txt) in
                txt.placeholder = "Name"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (act) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Add Item", style: .default, handler: { (act) in
                if let name = alert.textFields?.first?.text{
                    if !name.isEmpty{
                        if (Folder.folders.filter { (f) -> Bool in
                            f.folderName == name
                        }.isEmpty) {
                            Folder.folders.append(Folder(folderName: name, index: Folder.folders.count))
                            self.search?.searchBar.text = ""
                            self.filteredFolders = Folder.folders
                        }else{
                            showPopup(vc: self, title: "Name Taken", msg: "Please choose a different name", btnText: "OK")
                        }
                        
                        self.tvFolders.reloadData()
                    }
                }
            }))
            
            alert.actions[0].setValue(UIColor.red, forKey: "titleTextColor")
            alert.actions[1].setValue(#colorLiteral(red: 0.127715386, green: 0.1686877555, blue: 0.2190790727, alpha: 0.9254236356), forKey: "titleTextColor")
            present(alert, animated: true, completion: nil)
        }
        
        //  MARK : ON MOVING TABLE ROWS
        @IBAction func onEditTV(_ sender: UIBarButtonItem) {
            tvFolders.isEditing = (sender.title == "Edit" ? true : false)
            sender.title = ((sender.title == "Edit") ? "Done" : "Edit")
        }
        
        
        // MARK: - Navigation

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let cell : FolderCell = sender as? FolderCell {
//                let folder = Folder.folders.filter { (f) -> Bool in
//                    f.folderName == cell.textLabel?.text
//                }.first
                
                if let notesVC = segue.destination as? NotesVC {
                        notesVC.delegate = self
                    notesVC.currentFolder = Folder.folders[tvFolders.indexPath(for: cell)!.row]
                }
            }
        }
        
        func updateTable() {
            tvFolders.reloadData()
        }
    }

        //  MARK: - TABLE VIEW DELEGATE & DATASOURCES
    extension FoldersVC : UITableViewDelegate, UITableViewDataSource{
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredFolders.count
        }
            
        //  MARK: Cells
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell") as? FolderCell {
                let folder : Folder = filteredFolders[indexPath.row]
                
                if indexPath.section == 0{
                    cell.textLabel?.text = folder.folderName
                    cell.detailTextLabel?.text = String(folder.notes.count)
                }
                
                return cell
            }
            
            return UITableViewCell()
        }
        
        //  MARK: ON MOVE ROW
        func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            return (filteredFolders.count == Folder.folders.count) ? true : false
        }
        
        func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            let temp = Folder.folders[sourceIndexPath.row]
            let i = sourceIndexPath.row  // SourceFolder index
            
            //  interchange folders
            Folder.folders[sourceIndexPath.row] = Folder.folders[destinationIndexPath.row]
            Folder.folders[destinationIndexPath.row] = temp

            //  interchange indexes
            Folder.folders[sourceIndexPath.row].index = i
            Folder.folders[destinationIndexPath.row].index = destinationIndexPath.row
            
            self.tvFolders.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        }
        
        //  MARK: ON DELETE ROW
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        //  MARK: Swipe to delete
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { (act, v, _) in
                if indexPath.section == 0{
                    Folder.folders.remove(at: indexPath.row)
                    self.filteredFolders = Folder.folders
                    //   print(Folder.folders)
                }
                            
                tableView.reloadData()
            }
            delete.backgroundColor = #colorLiteral(red: 0.127715386, green: 0.1686877555, blue: 0.2190790727, alpha: 0.9254236356)
            return UISwipeActionsConfiguration(actions: [delete])
        }
        
        //  MARK: Editing style
        func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
            return false
        }
        
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return .none
        }
        
    }
