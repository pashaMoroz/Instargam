//
//  UserSerice.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 30/07/2022.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

typealias FirestoreCompletion = (Error?) -> Void

struct UserService {
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchUser(withUsername username: String, completion: @escaping(User?) -> Void) {
        COLLECTION_USERS.whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            guard let document = snapshot?.documents.first else {
                completion(nil)
                return
            }
            let user = User(dictionary: document.data())
            completion(user)
        }
    }
    
    private static func fetchUsers(fromCollection collection: CollectionReference, completion: @escaping([User]) -> Void) {
        var users = [User]()

        collection.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            documents.forEach({ fetchUser(withUid: $0.documentID) { user in
                users.append(user)
                completion(users)
            } })
        }
    }
    
    static func fetchUsers(forConfig config: UserFilterConfig, completion: @escaping([User]) -> Void) {
        switch config {
        case .followers(let uid):
            let ref = COLLECTION_FOLLOWERS.document(uid).collection("user-followers")
            fetchUsers(fromCollection: ref, completion: completion)
            
        case .following(let uid):
            let ref = COLLECTION_FOLLOWING.document(uid).collection("user-following")
            fetchUsers(fromCollection: ref, completion: completion)
            
        case .likes(let postId):
            let ref = COLLECTION_POSTS.document(postId).collection("post-likes")
            fetchUsers(fromCollection: ref, completion: completion)
            
        case .all, .messages:
            COLLECTION_USERS.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                
                let users = snapshot.documents.map({ User(dictionary: $0.data()) })
                completion(users)
            }
        }
    }
    
    static func follow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).setData([:]) { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).setData([:], completion: completion)
        }
    }
    
    static func unfollow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).delete { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).delete(completion: completion)
        }
    }
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { snapshot, error in
            guard let isFollowed = snapshot?.exists else { return }
            completion(isFollowed)
        }
    }
    
    static func fetchUserStats(uid: String, competion: @escaping(UserStats) -> Void) {
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
            let followers = snapshot?.documents.count ?? 0
            
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, _ in
                let following = snapshot?.documents.count ?? 0
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { snapshot, _ in
                    let posts = snapshot?.documents.count ?? 0
                    competion(UserStats(followers: followers, following: following, posts: posts))
                }
                
            }
        }
    }
    
    static func saveUserData(user: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = ["email": user.email,
                                   "fullname": user.fullname,
                                   "profileImageUrl": user.profileImageUrl,
                                   "uid": uid,
                                   "username": user.username]
        
        COLLECTION_USERS.document(uid).setData(data, completion: completion)
    }
    
    static func updateProfileImage(forUser user: User, image: UIImage, completion: @escaping(String?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Storage.storage().reference(forURL: user.profileImageUrl).delete(completion: nil)
        
        ImageUploader.uploadImage(image: image) { profileImageUrl in
            let data = ["profileImageUrl": profileImageUrl]
            
            COLLECTION_USERS.document(uid).updateData(data) { error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                // Update image in POSTS
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid).getDocuments { snapshot, error in
                    guard let documents = snapshot?.documents else { return }
                    let data = ["ownerImageUrl": profileImageUrl]
                    documents.forEach({ COLLECTION_POSTS.document($0.documentID).updateData(data) })
                }

                // Update image in NOTIFICATION
                COLLECTION_NOTIFICATION.getDocuments { snapshot, error in
                    
                    guard let snapshot = snapshot else { return }
                    
                    let documentsID = snapshot.documents.map({ $0.documentID })
                    
                    documentsID.forEach { id in
                        let query = COLLECTION_NOTIFICATION.document(id).collection("user-notifications").whereField("uid", isEqualTo: user.uid)
                        query.getDocuments { snapshot, error in
                            guard let documents = snapshot?.documents else { return }
                            let data = ["userProfileImageUrl": profileImageUrl]
                            documents.forEach { document in
                                COLLECTION_NOTIFICATION.document(id).collection("user-notifications").document(document.documentID).updateData(data)
                            }
                        }
                    }
                }
                
                // Update image in COMMENTS
                
                COLLECTION_POSTS.getDocuments { snapshot, error in
                    
                    guard let snapshot = snapshot else { return }
                    
                    let documentsID = snapshot.documents.map({$0.documentID})
                        
                    documentsID.forEach { id in
                        
                        let query = COLLECTION_POSTS.document(id).collection("comments").whereField("uid", isEqualTo: user.uid)
                        
                        query.getDocuments { snapshot, error in
                            guard let documents = snapshot?.documents else { return }
                            let data = ["profileImageUrl": profileImageUrl]
                            documents.forEach { document in
                                
                                COLLECTION_POSTS.document(id).collection("comments").document(document.documentID).updateData(data)
                            }
                        }
                    }
                }
                
                
                
                // need to update profile image url in messages
                
                completion(profileImageUrl, nil)
            }
        }
    }
}


