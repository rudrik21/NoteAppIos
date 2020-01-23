//
//  utils.swift
//  Rudrik_c0757521_Note_p1
//
//  Created by MacStudent on 2019-11-11.
//  Copyright © 2019 MacStudent. All rights reserved.
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
