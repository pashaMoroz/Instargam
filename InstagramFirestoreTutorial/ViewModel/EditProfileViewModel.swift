//
//  EditProfileViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 21/08/2022.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    
    case fullname
    case username
    
    var description: String {
        switch self {
        case .username: return "Username"
        case .fullname: return "Name"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
        case .fullname: return user.fullname
        case .username: return user.username
        }
    }
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}


