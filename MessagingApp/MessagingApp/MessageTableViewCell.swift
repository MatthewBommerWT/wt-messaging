//
//  MessageTableViewCell.swift
//  MessagingApp
//
//  Created by Matt Bommer on 3/16/21.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    let messageLabel = UILabel()
    let messageBackgroundView = UIView()
    
    let messageMarginConstant: CGFloat = 20.0
    let messagePaddingConstant: CGFloat = 10.0
    let maxMessageWidth = UIScreen.main.bounds.width * 0.65
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(message: Message, authoredByCurrentUser: Bool) {
        messageLabel.text = message.message
        messageLabel.sizeToFit()
        setup(authoredByCurrentUser)
    }
    
    private func setup(_ authoredByCurrentUser: Bool) {
        addSubview(messageBackgroundView)
        addSubview(messageLabel)
        
        messageBackgroundView.layer.cornerRadius = 5
        messageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let messageWidth = messageLabel.frame.width < maxMessageWidth ? messageLabel.frame.width : maxMessageWidth
        
        var constraints = [messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: messageMarginConstant),
                           messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -messageMarginConstant),
                           messageLabel.widthAnchor.constraint(equalToConstant: messageWidth),
                           
                           messageBackgroundView.leadingAnchor.constraint(equalTo:  messageLabel.leadingAnchor, constant: -messagePaddingConstant),
                           messageBackgroundView.topAnchor.constraint(equalTo:  messageLabel.topAnchor, constant: -messagePaddingConstant),
                           messageBackgroundView.bottomAnchor.constraint(equalTo:  messageLabel.bottomAnchor, constant: messagePaddingConstant),
                           messageBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: messagePaddingConstant),]
        
        if authoredByCurrentUser {
            messageBackgroundView.backgroundColor = .systemGreen
            constraints.append(messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -messageMarginConstant))
        }else {
            messageBackgroundView.backgroundColor = .lightGray
            constraints.append(messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: messageMarginConstant))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
