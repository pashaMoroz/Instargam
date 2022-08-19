//
//  NotoficationService.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 15/08/2022.
//

import FirebaseAuth
import FirebaseFirestore

struct NotificationService {
    static func uploadNotification(toUid uid: String,
                                   fromUser: User,
                                   type: NotificationType,
                                   post: Post? = nil) {
        guard let currectUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currectUid else { return }
        
        let docRef = COLLECTION_NOTIFICATION.document(uid).collection("user-notifications").document()
        
        var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                   "uid": fromUser.uid,
                                   "type": type.rawValue,
                                   "id": docRef.documentID,
                                   "userProfileImageUrl": fromUser.profileImageUrl,
                                   "userName": fromUser.username]
        
        if let post = post {
            data["postId"] = post.postId
            data["postImageUrl"] = post.imageUrl
        }
        
       docRef.setData(data)
    }
    
    static func fetchNotification(completion: @escaping([Notification]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query =  COLLECTION_NOTIFICATION.document(uid).collection("user-notifications").order(by: "timestamp", descending: true)
        
        query.getDocuments { snapshot, _ in
            
            guard let documents = snapshot?.documents else { return }
            let notification = documents.map{(Notification(dictionary: $0.data()))}
            completion(notification)
        }
    }
}
