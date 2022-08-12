//
//  ProfileCell.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 30/07/2022.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    // MARK:  Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    private let postImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "venom-7")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds =  true
        return iv
    }()
    
    // MARK:  Lificycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        postImageView.sd_setImage(with: viewModel.imageUrl)
    }
}