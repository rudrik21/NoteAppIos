//
//  utils.swift
//  NoteApp
//
//  Created by Rudrik Panchal on 2020-01-23.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import Foundation
import UIKit

//  MARK : SHOWS POPUP WITH 'CANCEL' ACTION
func showPopup(vc : UIViewController, title : String?, msg : String?, btnText : String?) {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: (btnText!.isEmpty ? "Cancel" : btnText), style: .cancel, handler: { (act) in
        alert.dismiss(animated: true, completion: nil)
    }))
    alert.actions[0].setValue(#colorLiteral(red: 0.127715386, green: 0.1686877555, blue: 0.2190790727, alpha: 0.9254236356), forKey: "titleTextColor")
    vc.present(alert, animated: true, completion: nil)
}

//  SERIALIZING NOTE DATA
func jsonTostring(notes: [Note]) -> String {
    var str = "[]"
    
    do {
        let data = try JSONEncoder().encode(notes)
        str = String(data: data, encoding: .utf8)!
//        print(str)
        return str
    } catch {}
    
    return str
}

func stringTojson(str: String) -> [Note] {
    var notes = [Note]()
    do {
        let decodedData : [Note] = try JSONDecoder().decode(Array<Note>.self, from: (str.data(using: .utf8))!)
        notes = decodedData
//        print(decodedData.last?.index)
        return notes
    } catch { }
    return notes
}
/*
 
do {
    let data = try JSONEncoder().encode(currentFolder?.notes)
    let str = String(data: data, encoding: .utf8)
    print(str)
    
    let decodedData = try JSONDecoder().decode(Array<Note>.self, from: (str?.data(using: .utf8))!)
    print(decodedData.last?.index)
} catch {
    print(error)
}
}
 
*/
