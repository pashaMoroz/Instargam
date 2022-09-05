//
//  Message.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 25/08/2022.
//

import FirebaseAuth
import FirebaseFirestore

struct Message {
    let text: String
    let toId: String
    let fromId: String
    var timestamp: Timestamp
    let profileImageUrl: String
    let isFromCurrentUser: Bool
    let username: String
    
    var chatPartnerId: String { return isFromCurrentUser ? toId : fromId }
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.isFromCurrentUser = fromId == Auth.auth().currentUser?.uid
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}
