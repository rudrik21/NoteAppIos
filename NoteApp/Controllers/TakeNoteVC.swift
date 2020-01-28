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
    
    @IBOutlet weak var record_brn: UIBarButtonItem!
    var imagePicker: UIImagePickerController!
    var alert : UIAlertController?
    var alert2 : UIAlertController?
    var delegate : NotesVC?
    var currentNote: Note?
    var newNote: Note?
    var manager: CLLocationManager?
    var userLocation: CLLocation?
    var SoundRecorder: AVAudioRecorder!
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var cvFiles: UICollectionView!
    
    @IBOutlet weak var txtNote: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        start()
        initLocation()
    }
    
    func start() {
        var navTitle: String?
        if let currentNote = currentNote{
            navTitle = String((currentNote.noteName.prefix(upTo: (currentNote.noteName.index((currentNote.noteName.startIndex), offsetBy: (currentNote.noteName.count)/2))))) + "....."
            newNote = currentNote
        }else{
            navTitle = "New Note"
            newNote = Note(noteName: "")
        }
        navBar.title = navTitle
        txtNote.becomeFirstResponder()
        txtNote.text = newNote?.noteName
        print("files", newNote?.strFiles)
        initCollectionView()
    }
    
    @IBAction func chooseImageFromPicker(_ sender: Any) {
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

    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage: UIImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        let res = saveImage(image: selectedImage)
        print("saved image: ", res!)
        selectedImage.accessibilityUserInputLabels = [res!]
        newNote?.strFiles.append(res!)
        cvFiles.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    private func saveImage(image: UIImage) -> String? {
        let fileName = "Image_\(getTimeStamp()).jpeg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
           try? imageData.write(to: fileURL, options: .atomic)
           return fileName // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }
    
    private func load(fileName: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showPopup(vc: self, title: "Save error", msg: error.localizedDescription, btnText: "Cancel")
        } else {
            if let url = URL(string: image.accessibilityUserInputLabels.first!) {
                let fileName = url.lastPathComponent
//                let fileType = url.pathExtension
                print("clicked image",fileName)
                newNote?.strFiles.append(fileName)
            }
            showPopup(vc: self, title: "Saved!", msg: "Your image has been saved to your photos.", btnText: "Okay")
            cvFiles.reloadData()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        startRecording()
       
        if record_brn.title == "Record" {
            SoundRecorder.record()
            record_brn.title = "Stop"
          
        } else {
            SoundRecorder.stop()
          record_brn.title = "Record"
            
        }
    }
    
    func startRecording() {
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("audio_\(getTimeStamp()).mp3")
        
            let recordSetting = [ AVFormatIDKey : kAudioFormatMPEGLayer3 ,
                            AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue,
                                     AVEncoderBitRateKey : 320000,
                                     AVNumberOfChannelsKey : 2,
                                     AVSampleRateKey : 44100.2 ] as [String : Any]
               do {
                       SoundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSetting)
                       SoundRecorder.delegate = self
                       SoundRecorder.prepareToRecord()
                       newNote?.strFiles.append("\(audioFilename)")
                        print("saving audio", newNote?.strFiles ?? [])
               } catch {
                   print(error)
               }
    }
    
    func initCollectionView() {
        cvFiles.delegate = self
        cvFiles.dataSource = self
        
        cvFiles.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        
        cvFiles.register(UINib(nibName: "AudioCell", bundle: nil), forCellWithReuseIdentifier: "AudioCell")
        
    }

    //  MARK: LOCATION
    func initLocation() {
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.requestWhenInUseAuthorization()
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
        if let new = newNote {
            if new.lat == 0.00 {
                self.newNote!.lat = (userLocation?.coordinate.latitude)!
            }
            if new.long == 0.00 {
                self.newNote!.long = (userLocation?.coordinate.longitude)!
            }
        }
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
                newNote!.noteName = txtNote.text
                if let oldNote = currentNote {
                    delegate?.currentFolder?.updateNote(newNote: newNote!, oldNote: oldNote)
                }else{
                    delegate?.currentFolder?.addNote(note: newNote!)
                }
            }
        }
        delegate?.updateTable()
    }

    func getTimeStamp() -> String {
        return (String(Date().timeIntervalSince1970)).replacingOccurrences(of: ".", with: "")
    }
    
    func pathToImage(path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }
}

extension TakeNoteVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = (self.view.frame.size.width - 12 * 3) / 3 //some width
            let height = width * 1.5 //ratio
        return CGSize(width: width, height: height)
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width: 20, height: 20);
//    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 3;
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newNote?.strFiles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        if !(newNote?.strFiles.isEmpty)! {
            let i = indexPath.row
            print("suffix: ", String((newNote?.strFiles[i].suffix(from: (newNote?.strFiles[i].firstIndex(of: "."))!))!))
            
            switch newNote?.strFiles[i].suffix(from: (newNote?.strFiles[i].firstIndex(of: "."))!) {
                
            case ".png", ".jpeg":
                print("is photo")
                if let cell : ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell{
                    let path = (newNote?.strFiles[indexPath.row])!
                    print("path: ", path)
                    cell.setImage(load(fileName: path))
                    return cell
                }
            
            case ".mp3", ".m4a":
                print("is audio")
                if let cell : AudioCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCell", for: indexPath) as? AudioCell{
                    
                    return cell
                }
                
            default:
                return UICollectionViewCell()
            }
        }
        return UICollectionViewCell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
           if let map = segue.destination as? MapVC {
                    
                   map.takeNoteVC = self
              
           }
    }
    
}
