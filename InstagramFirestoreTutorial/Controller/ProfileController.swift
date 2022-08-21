//
//  ProfileController.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 06/07/2022.
//

import UIKit

protocol UpdateUserStatsDelegate: AnyObject {
    func updateUserStats(_ controller: ProfileController)
}

class ProfileController: UICollectionViewController {
    
    private let cellIdentifier = "ProfileCell"
    private let headerIdentifier = "ProfileHeader"
    
    // MARK:  Properties
    
    private var user: User
    private var posts = [Post]()
    
    weak var delegate: UpdateUserStatsDelegate?
    
    // MARK:  Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        checkIfuserIsFollowed()
        fetchUserStats()
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserStats()
    }
    
    // MARK:  API
    
    func checkIfuserIsFollowed() {
        UserSerice.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserSerice.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    func fetchPosts() {
        PostService.fetchPosts(forUser: user.uid) { post in
            self.posts = post
            self.collectionView.reloadData()
        }
    }
    
    // MARK:  Helpers
    
    func configureCollectionView() {
        navigationItem.title = user.username
        collectionView.backgroundColor = .white
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
    }
    
}

// MARK:  UIcollectionViewDataSourse
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        cell.viewModel = PostViewModel(post: posts[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        
        header.delegate = self
        
        header.viewModel = ProfileHeaderViewModel(user: user)
        
        return header
    }
}

// MARK:  UIcollectionViewDelegate
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.post = posts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}


// MARK:  UIcollectionViewDelegateFlowLayout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let with = (view.frame.width - 2) / 3
        return CGSize(width: with, height: with)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 240)
    }
}

extension ProfileController: ProfileHeaderDelegate {
        
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User) {
        
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        if user.isCurrentUser {
            print("DEBUG: Show edit profile here..")
        } else if user.isFollowed {
            UserSerice.unfollow(uid: user.uid) { error in
                self.user.isFollowed = false
                self.fetchUserStats()
                self.collectionView.reloadData()
                
                PostService.updateUserFeedAfterFollowing(user: user, didFollow: false)

            }
        } else {
            UserSerice.follow(uid: user.uid) { error in
                self.user.isFollowed = true
                self.fetchUserStats()
                self.collectionView.reloadData()
                
                NotificationService.uploadNotification(toUid: user.uid,
                                                       fromUser: currentUser,
                                                       type: .follow)
                
                PostService.updateUserFeedAfterFollowing(user: user, didFollow: true)
            }
        }
        
        delegate?.updateUserStats(self)
    }
}

extension ProfileController: UpdateUserStatsDelegate {
    
    func updateUserStats(_ controller: ProfileController) {
       
        fetchUserStats()
        collectionView.reloadData()
        
    }
}
