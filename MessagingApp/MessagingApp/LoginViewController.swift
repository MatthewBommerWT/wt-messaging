//
//  LoginViewController.swift
//  MessagingApp
//
//  Created by Matt Bommer on 3/19/21.
//

import UIKit

fileprivate let segueIdentifier = "messageSegue"

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        guard userNameTextField.hasText, let userName = userNameTextField.text else {
            return
        }
        userDefaults.set(userName, forKey: "username")
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }

}
