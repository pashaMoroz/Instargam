//
//  CommentService.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 13/08/2022.
//

import FirebaseFirestore

struct CommentService {
    
    static func uploadComment(comment: String, postID: String, user: User, completion: @escaping(FirestoreCompletion)) {
        
        let data: [String: Any] = ["uid": user.uid,
                                   "comment": comment,
                                   "timestamp": Timestamp(date: Date()),
                                   "username": user.username,
                                   "profileImageUrl": user.profileImageUrl]
        
        COLLECTION_POSTS.document(postID).collection("comments").addDocument(data: data,
                                                                             completion: completion)
    }
    
    static func fetchComments(forPost postId: String, completion: @escaping([Comment]) -> Void) {
        var comments = [Comment]()
        let querry = COLLECTION_POSTS.document(postId).collection("comments").order(by: "timestamp", descending: true)
        
        querry.addSnapshotListener { snapshot, error in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    let comment = Comment(dictionary: data)
                    comments.append(comment)
                }
            })
            completion(comments)   
        }
    }
}

