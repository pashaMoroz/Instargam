//
//  MessagingService.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 25/08/2022.
//

import FirebaseAuth
import FirebaseFirestore

struct MessagingService {
    
    
    static func fetchRecentMessages(completion: @escaping([Message]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGES.document(uid).collection("recent-messages").order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in
            guard let documentChanges = snapshot?.documentChanges else { return }
            let messages = documentChanges.map({ Message(dictionary: $0.document.data()) })
            completion(messages)
        }
    }
    
    static func fetchMessages(forUser user: User, completion: @escaping([Message]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var messages = [Message]()
        let query = COLLECTION_MESSAGES.document(currentUid).collection(user.uid).order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in
            guard let documentChanges = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            messages.append(contentsOf: documentChanges.map({ Message(dictionary: $0.document.data()) }))
            completion(messages)
        }
    }
    
    static func uploadMessage(_ message: String, to user: User, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        UserService.fetchUser(withUid: currentUid) { currentUser in
            
            
            let data = ["text": message,
                        "fromId": currentUid,
                        "toId": user.uid,
                        "timestamp": Timestamp(date: Date()),
                        "username": user.username,
                        "profileImageUrl": currentUser.profileImageUrl] as [String : Any]
            
            
            COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) { _ in
                COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data, completion: completion)
                COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.uid).setData(data)
                
                COLLECTION_MESSAGES.document(user.uid).collection("recent-messages").document(currentUid).setData(data)
            }
        }
    }
    
    static func deleteMessages(withUser user: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_MESSAGES.document(uid).collection(user.uid).getDocuments { snapshot, error in
            
            snapshot?.documents.forEach({ document in
                let id = document.documentID
                
                COLLECTION_MESSAGES.document(uid).collection(user.uid).document(id).delete()
            })
        }
        
        let ref = COLLECTION_MESSAGES.document(uid).collection("recent-messages").document(user.uid)
        ref.delete(completion: completion)
    }
}

