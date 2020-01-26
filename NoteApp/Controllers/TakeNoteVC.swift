//
//  TakeNoteVC.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-23.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class TakeNoteVC: UIViewController, CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate{
   // @IBOutlet weak var imageTake: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var alert : UIAlertController?
    var alert2 : UIAlertController?
    var delegate : NotesVC?
    var currentNote: Note?
    var newNote: Note?
    var manager: CLLocationManager?
    var userLocation: CLLocation?
    var SoundRecorder: AVAudioRecorder!
     var fileName : String = "audioFile.m4a"
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var cvFiles: UICollectionView!
    
    @IBOutlet weak var txtNote: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newNote?.strFiles = ["ru","ko"]
        print(newNote?.strFiles)
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        start()
        initCollectionView()
        initLocation()
        
    }
    @IBAction func takeImage(_ sender: Any) {
        alert = UIAlertController(title: "Do want to add media?", message: "Choose any of them.", preferredStyle: .actionSheet)

        alert!.addAction(UIAlertAction(title: "Open Gallary", style: .default, handler: { (addImage) in
        
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
                    
        }))

       alert!.addAction(UIAlertAction(title: "Open Camera", style: .default, handler: { (addImage2) in

        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
             self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }else{
            self.alert2 = UIAlertController(title: "Sorry We are unable to open camera", message: "Choose from gallary.", preferredStyle: .alert)
            self.alert2!.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(self.alert2!, animated: true)
     }
        
       }))
       self.present(alert!, animated: true)
        
    }
  

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        print(imagePath)
        newNote?.strFiles.append("\(imagePath)")
        print("okokokok")
        print(newNote?.strFiles)
        //dismiss(animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
        let recordSetting = [ AVFormatIDKey : kAudioFormatAppleLossless ,
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey : 320000,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.2 ] as [String : Any]
        do {
            SoundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSetting)
            SoundRecorder.delegate = self
            SoundRecorder.prepareToRecord()
            newNote?.strFiles.append("\(audioFilename)")
            print("okokokok")
            print(newNote?.strFiles)
        } catch {
            print(error)
        }
        
    }
    
    
    
    func start() {
        newNote?.strFiles = ["",""]
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
        
        print("me")
        print(newNote?.strFiles)
    }
    
    func initCollectionView() {
        cvFiles.delegate = self
        cvFiles.dataSource = self
        
        cvFiles.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        cvFiles.register(UINib(nibName: "AudioCell", bundle: nil), forCellWithReuseIdentifier: "AudioCell")
        
    }

    func initLocation() {
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.requestWhenInUseAuthorization()
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
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
                    newNote?.lat = userLocation?.coordinate.latitude
                    newNote?.long = userLocation?.coordinate.longitude
                    delegate?.currentFolder?.updateNote(newNote: newNote!, oldNote: oldNote)
                    
                }else{
                    newNote = Note(noteName: txtNote.text, strFiles: [])
                    newNote?.lat = userLocation?.coordinate.latitude
                    newNote?.long = userLocation?.coordinate.longitude
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
                       if let map = segue.destination as? MapVC {
                               map.delegate = self
                          
                       }
    }
    
}
