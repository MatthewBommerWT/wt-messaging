//
//  MessageCoordinator.swift
//  MessagingApp
//
//  Created by Matt Bommer on 3/15/21.
//

import Foundation
import Firebase
import FirebaseFirestore


enum CollectionNames: String {
    case users
}

enum RealTimeRoot: String {
    case messages
}

protocol MessageTransfer: class {
    func sendMessage(_ message: String, to receivingUser: String)
    func createConversation(_ message: String, with receivingUser: String) -> Conversation
    func getUserName() -> String
}

class MessageCoordinator: MessageTransfer {
    
    private let realtimeRef = Database.database().reference()
    private let cloudRef = Firestore.firestore()
    private var userName: String
    private var userCollectionRef: CollectionReference
    private var realTimeRoot: DatabaseReference
    
    init(userName: String) {
        self.userName = userName
        self.userCollectionRef = cloudRef.collection(CollectionNames.users.rawValue)
        self.realTimeRoot = realtimeRef.child(RealTimeRoot.messages.rawValue)
        
        userCollectionRef.document(userName).getDocument(completion: { (document, _) in
            guard let doc = document, doc.exists else {
                self.createUserDocument()
                return
            }
        })
    }
    
    func makeFirestoreListner(completionHandler: @escaping (User) -> Void) {
        cloudRef.collection("users").document(userName).addSnapshotListener { (documentSnapshot: DocumentSnapshot?, error: Error?) in
            guard let document = documentSnapshot else {
                print("Error occurred while trying to write data to \(String(describing: error))")
                return
            }
            guard let documentData = document.data() else {
                print("There was no document data")
                return
            }
            let decoder = JSONDecoder()
            if let data = try? JSONSerialization.data(withJSONObject: documentData, options: []) {
                guard let user = try? decoder.decode(User.self, from: data) else {
                    print("No user data was found")
                    return
                }
                completionHandler(user)
            }
        }
    }
    
    func makeRealTimeDatabaseListner(conversationIdentifier: String, completionHandler: @escaping (Message) -> Void) {
        realTimeRoot.child(conversationIdentifier).observe(.childAdded) { (dataSnapshot) in
            guard let snapshotValue = dataSnapshot.value else {
                print("There was no data to be found")
                return
            }
            
            let decoder = JSONDecoder()
            if let data = try? JSONSerialization.data(withJSONObject: snapshotValue, options: []) {
                guard let message = try? decoder.decode(Message.self, from: data) else {
                    print("The message was nil")
                    return
                }
                completionHandler(message)
            }
        }
    }
    
    func sendMessage(_ message: String, to universalIdentifier: String) {
        let timeOfMessage = Int(Date().timeIntervalSince1970)
        
        let data = ["author": userName, "message": message, "timestamp": timeOfMessage] as [String : Any]
        realTimeRoot.child(universalIdentifier).updateChildValues([String(timeOfMessage): data])
    }
    
    func createConversation(_ message: String, with receivingUser: String) -> Conversation {
        guard let key = realTimeRoot.childByAutoId().key else {
            fatalError("Something is terribly wrong")
        }
        sendMessage(message, to: key)
        
        let batch = cloudRef.batch()
        batch.updateData(["conversations.\(receivingUser)": key], forDocument: userCollectionRef.document(userName))
        batch.updateData(["conversations.\(userName)": key], forDocument: userCollectionRef.document(receivingUser))
        batch.commit()

        return Conversation(identifier: key, participant: receivingUser)
    }
    
    func getUserName() -> String {
        return userName
    }
    
    private func createUserDocument() {
        userCollectionRef.document(userName)
            .setData([
                "conversations": Dictionary<String, String>()
            ])
    }
    
}
