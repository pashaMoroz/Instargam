//
//  Constants.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 30/07/2022.
//

import FirebaseFirestore

let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_NOTIFICATION = Firestore.firestore().collection("notifications")
let COLLECTION_MESSAGES = Firestore.firestore().collection("messages")
let COLLECTION_HASHTAGS = Firestore.firestore().collection("hashtags")
