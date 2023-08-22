//
//  SettingViewController.swift
//  Post-Prototype
//
//  Created by Terry Jason on 2023/8/8.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toVC", sender: nil)
        } catch {
            print(error.localizedDescription)
        }
    }

}



