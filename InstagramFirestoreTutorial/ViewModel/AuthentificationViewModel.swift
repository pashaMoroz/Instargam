//
//  AuthentificationViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 26/07/2022.
//

import UIKit

protocol FormViewModel {
    func updateForm()
}

protocol AuthentificationViewModel {
    var formIsValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
    var buttonTitleColor: UIColor { get }
}

struct LoginViewModel: AuthentificationViewModel {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false 
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? .systemPurple : .systemPurple.withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
}

struct RegistrationViewModel: AuthentificationViewModel {
    
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
        && fullname?.isEmpty == false && username?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? .systemPurple : .systemPurple.withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
}

struct ResetPasswordViewModel: AuthentificationViewModel {
    
    var email: String?
    
    var formIsValid: Bool { return email?.isEmpty == false}
    
    var buttonBackgroundColor: UIColor {
         formIsValid ? .systemPurple : .systemPurple.withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
}
