//
//  MessangerPreviewTableViewCell.swift
//  MessagingApp
//
//  Created by Matt Bommer on 3/12/21.
//

import UIKit

class MessangerPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var messagePreview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(_ messageData: MessageMetaData){
        userName.text = messageData.name
        messagePreview.text = messageData.preview
    }
    
}
