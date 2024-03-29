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
    
    @IBOutlet weak var record_btn: UIBarButtonItem!
    var imagePicker: UIImagePickerController!
    var alert : UIAlertController?
    var alert2 : UIAlertController?
    var delegate : NotesVC?
    var currentNote: Note?
    var newNote: Note?
    var manager: CLLocationManager?
    var userLocation: CLLocation?
    
    var audioPlayer: AVAudioPlayer?
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
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
            newNote = Note(noteName: "", timeStamp: getTimeStamp())
        }
        navBar.title = navTitle
        txtNote.becomeFirstResponder()
        txtNote.text = newNote?.noteName
        print("files", newNote?.strFiles)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(releaseFocus))
        navigationController?.navigationBar.addGestureRecognizer(tap)
        initCollectionView()
        
    }
    
    @objc func releaseFocus() {
            txtNote.resignFirstResponder()
    }
    
    func initCollectionView() {
        cvFiles.delegate = self
        cvFiles.dataSource = self
        
        cvFiles.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        
        cvFiles.register(UINib(nibName: "AudioCell", bundle: nil), forCellWithReuseIdentifier: "AudioCell")
    }
    
    //  MARK: IMAGEs
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
    
    //  RECORDING
    @IBAction func recordAudio(_ sender: Any) {
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.recordTapped()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
//    func loadRecordingUI() {
//        recordButton = UIButton(frame: CGRect(x: view.frame.maxX - 100, y: 64, width: 128, height: 64))
//        recordButton.setTitle("Tap to Record", for: .normal)
//        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
//        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
//        view.addSubview(recordButton)
//    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("audio\(getTimeStamp()).m4a")
        recordingSession.accessibilityLabel = audioFilename.lastPathComponent

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        print("Recording finished..")
        newNote?.strFiles.append(recordingSession.accessibilityLabel!)
        cvFiles.reloadData()
        audioRecorder = nil
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
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

//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 3;
//    }
//
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 1;
//    }
    
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
                    cell.setAudio(player: AVAudioPlayer(), fileURL: getDocumentsDirectory().appendingPathComponent((newNote?.strFiles[indexPath.row])!))
                    
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
