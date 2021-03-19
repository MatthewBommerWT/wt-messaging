//
//  UserDisplayTableViewController.swift
//  MessagingApp
//
//  Created by Matt Bommer on 3/19/21.
//

import UIKit

class UserDisplayTableViewController: UITableViewController {

    var users: [String]?
    var delegate: MessagePreviewTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func inject(_ listOfUserNames: [String], handler: MessagePreviewTableViewController) {
        self.users = listOfUserNames
        self.delegate = handler
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let userList = users else {
            return 0
        }
        return userList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = users?[indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userList = users else {
            return
        }
        self.dismiss(animated: false, completion: nil)
        self.delegate?.newConversation(user: userList[indexPath.item])
    }


}
