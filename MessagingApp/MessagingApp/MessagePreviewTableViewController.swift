//
//  MessagePreviewTableViewController.swift
//  MessagingApp
//
//  Created by Matt Bommer on 3/12/21.
//

import UIKit
import Firebase

fileprivate let reuseIdentifier = "conversationCell"

class MessagePreviewTableViewController: UITableViewController {
    
    let messageCoordinator = MessageCoordinator(userName: UserDefaults.standard.string(forKey: "username")!)
    var conversations: [Conversation] = []
    lazy var dataSource: DataSource = makeDataSource()
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Conversation>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Conversation>
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(choosePartner))
        
        messageCoordinator.makeFirestoreListner { (userData: User) in
            self.conversations = userData.conversations.map { (key: String, value: String) -> Conversation in
                Conversation(identifier: value, participant: key)
            }
            self.applySnapshot()
        }
    }
    
    func makeDataSource() -> DataSource {
        dataSource = DataSource(tableView: self.tableView, cellProvider: { (tableView, indexPath, preview) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            cell?.textLabel?.text = self.conversations[indexPath.item].participant
            return cell
        })
        return dataSource
    }
    
    // MARK: NSDiffableDataSourceSnapshot
    func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(conversations)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @objc
    func choosePartner() {
        messageCoordinator.getUsers { users in
            let UserDisplay = self.makeDisplayViewController()
            UserDisplay.inject(users, handler: self)
            self.navigationController?.present(UserDisplay, animated: true, completion: nil)
        }
        
    }
    
    func newConversation(user: String) {
        let viewController = makeMessageViewController()
        viewController.inject(handler: messageCoordinator, receiver: user)
        navigationController?.pushViewController(viewController, animated: false)
    }
    
    func makeMessageViewController() -> MessageViewController {
        let bundle = Bundle(for: MessageViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        return storyboard.instantiateViewController(identifier: "MessageViewController") as! MessageViewController
    }
    
    func makeDisplayViewController() -> UserDisplayTableViewController {
        let bundle = Bundle(for: UserDisplayTableViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        return storyboard.instantiateViewController(identifier: "UserDisplay") as! UserDisplayTableViewController
    }
}
extension MessagePreviewTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = makeMessageViewController()
        let conversation = conversations[indexPath.item]
        viewController.inject(handler: messageCoordinator, conversation: conversation)
        
        messageCoordinator.makeRealTimeDatabaseListner(conversationIdentifier: conversation.identifier) { (message: Message) in
            viewController.messages.append(message)
            viewController.applySnapshot()
        }
        navigationController?.pushViewController(viewController, animated: false)
    }
    
}
