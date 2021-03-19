//
//  MessageViewController.swift
//  MessagingApp
//
//  Created by Matt Bommer on 3/15/21.
//

import UIKit

fileprivate let reuseIdentifier = "messageCell"

enum Section {
    case main
    case preview
}

class MessageViewController: UIViewController {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    var messages: [Message] = []
    
    weak var handler: MessageTransfer?
    var conversation: Conversation?
    
    lazy var dataSource: DataSource = makeDataSource()
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Message>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Message>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func inject(handler: MessageTransfer) {
        self.handler = handler
    }
    
    func inject(handler: MessageTransfer, conversation: Conversation) {
        self.handler = handler
        self.conversation = conversation
    }
    
    func setup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        view.addGestureRecognizer(tap)
        
        messageTableView.register(MessageTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        setupTextField()
    }
    
    // MARK: UITextField
    func setupTextField() {
        let sendButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        sendButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        
        sendButton.addTarget(self, action: #selector(readTextField), for: .touchUpInside)
        
        let sendImage = UIImage(systemName: "paperplane")
        let pressedSendImage = UIImage(systemName: "paperplane.fill")
        
        sendButton.setImage(sendImage, for: .normal)
        sendButton.setImage(pressedSendImage, for: .selected)
        
        messageTextField.rightView = sendButton
        messageTextField.rightViewMode = .always
    }
    
    @objc func readTextField() {
        guard messageTextField.hasText, let messageText = messageTextField.text else {
            return
        }
        messageTextField.text = ""
        
        guard let id = conversation?.identifier else {
            self.conversation = handler?.createConversation(messageText, with: "matt")
            return
        }
        handler?.sendMessage(messageText, to: id)
    }
    
    // MARK: UITableViewDiffableDataSource
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: messageTableView) { (tableView, indexPath, message) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageTableViewCell
            cell.configure(message: message, authoredByCurrentUser: message.author == self.handler!.getUserName())
            return cell
        }
        return dataSource
    }
    
    // MARK: NSDiffableDataSourceSnapshot
    func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(messages)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    
    // MARK: Keyboard Selectors
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        bottomConstraint.constant = -keyboardSize.height + (view.safeAreaInsets.bottom * 0.9)
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = 0
    }
    
    @objc func hideKeyboardOnTap() {
        if messageTextField.isFirstResponder {
            messageTextField.resignFirstResponder()
        }
    }
    
}

