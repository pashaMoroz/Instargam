//
//  LoginController.swift
//  InstagramFirestoreTutorial
//
//  Created by Admin on 21/07/2022.
//

import UIKit

protocol AuthentificationDelegate: AnyObject {
    func authentificationDidComplete()
}

class LoginController: UIViewController {
    
    // MARK:  Properties
    
    private var viewModel = LoginViewModel()
    weak var delegate: AuthentificationDelegate?
    
    private let iconImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let passwordTextFeild: UITextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.67), for: .normal)
        button.backgroundColor = .systemPurple.withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedtitle(firstPart: "Forgot you password?", secondPart: "Get help signing in.")
        button.addTarget(self, action: #selector(handleShowResetPassword), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedtitle(firstPart: "Don't have an account?", secondPart: "Sign Up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    
    // MARK:  Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurUI()
        configureNotificationObservers()
    }
    
    // MARK:  Actions
    
    @objc func handleShowResetPassword() {
        let controller = ResetPasswordController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogin() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextFeild.text else { return }
        
        AuthService.logUserIn(withEmail: email, password: password) { results, error in
            if let error = error {
                self.showMessage(withTitle: "Error", message: error.localizedDescription)
                print("DEBUG: Failed to log user in \(error.localizedDescription)")
                return
            }
            self.delegate?.authentificationDidComplete()
        }
    }
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        controller.delegate = delegate 
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func texDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        
        updateForm()
    }
    
    // MARK:  Helpers
    
    func configurUI() {
        configureGradientLayer()
        navigationController?.navigationBar.isHidden = true
        
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextFeild, loginButton, forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(texDidChange), for: .editingChanged)
        passwordTextFeild.addTarget(self, action: #selector(texDidChange), for: .editingChanged)
    }
}

// MARK:   FormViewModel

extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        loginButton.isEnabled = viewModel.formIsValid
    }
}

// MARK:   ResetPasswordControllerDelegate
extension LoginController: ResetPasswordControllerDelegate {
    func controllerDidSendResetPasswordLink(_ controller: ResetPasswordController) {
        navigationController?.popViewController(animated: true)
        showMessage(withTitle: "Success", message: "We sent a link to your email to reset your password")
    }
}
