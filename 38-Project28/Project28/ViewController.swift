//
//  ViewController.swift
//  Project28
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var secret: UITextView!
    
    // challenge 1
    var doneButton: UIBarButtonItem!
    
    // challenge 2
    let passwordKey = "password"
    var passwordButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        // challenge 1
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveSecretMessage))
        passwordButton = UIBarButtonItem(title: "Password", style: .plain, target: self, action: #selector(setPassword))

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // from the documentation: posted when the app is no longer active and loses focus
        // i.e. app is put to background or user switches to multitasking
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, authenticationError) in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    }
                    else {
                        // example of error type checking
                        // if let error = authenticationError as? LAError { /* compare error.code with LAError.* */ }
                        
                        // challenge 2
                        self?.failedBiometricAuthentication(context: context)
                    }
                }
            }
        }
        else {
            // biometry unavailable
            
            // challenge 2
            useFallbackAuthentication()
        }
    }

    // challenge 2
    func failedBiometricAuthentication(context: LAContext) {
        if !hasPassword() {
            // don't want a wrong fingerprint or face to trigger password creation
            var biometryType: String
            switch context.biometryType {
            case .faceID:
                biometryType = "Face ID"
            case .touchID:
                biometryType = "Touch ID"
            case .none:
                return; // ; added as a workaround to https://bugs.swift.org/browse/SR-9920
            @unknown default:
                biometryType = "Biometry"
            }
            showErrorMessage(title: "Authentication failed", message: "To use password authentication, first authenticate using \(biometryType) then set a password, or disable \(biometryType)")
        }
        else {
            useFallbackAuthentication()
        }
    }
    
    // challenge 2
    func useFallbackAuthentication() {
        if hasPassword() {
            authenticateWithPassword()
        }
        else {
            setPassword()
        }
    }
    
    // challenge 2
    func hasPassword() -> Bool {
        return KeychainWrapper.standard.hasValue(forKey: passwordKey)
    }
    
    // challenge 2
    func authenticateWithPassword() {
        let ac = UIAlertController(title: "Password authentication", message: nil, preferredStyle: .alert)
        
        ac.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] action in
            guard let password = self?.getField(ac: ac, field: 0) else { return }
            
            if let passwordKey = self?.passwordKey {
                if let storedPassword = KeychainWrapper.standard.string(forKey: passwordKey) {
                    if password == storedPassword {
                        self?.unlockSecretMessage()
                        return
                    }
                }
            }
            
            // authentication error
            self?.showErrorMessage(title: "Authentication failed", message: "You could not be verified; please try again.")
        })
        
        present(ac, animated: true)
    }
    
    // challenge 2
    func showErrorMessage(title: String, message: String? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    // challenge 2
    @objc func setPassword() {
        let ac = UIAlertController(title: "Set password", message: "Password can be used to authenticate", preferredStyle: .alert)
        
        ac.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        
        ac.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Confirm password"
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] action in
            guard let password = self?.checkSetPasswordFields(ac: ac) else { return }
            
            if let passwordKey = self?.passwordKey {
                KeychainWrapper.standard.set(password, forKey: passwordKey)
            }
        })
        
        present(ac, animated: true)
    }
    
    // challenge 2
    func checkSetPasswordFields(ac: UIAlertController?) -> String? {
        guard let password1 = getField(ac: ac, field: 0) else {
            setPasswordError(title: "Missing password")
            return nil
        }
        
        guard let password2 = getField(ac: ac, field: 1) else {
            setPasswordError(title: "Missing password confirmation")
            return nil
        }
        
        guard password1 == password2 else {
            setPasswordError(title: "Passwords don't match")
            return nil
        }
        
        return password1
    }
    
    // challenge 2
    func getField(ac: UIAlertController?, field: Int) -> String? {
        guard let text = ac?.textFields?[field].text else {
            return nil
        }
        
        guard !text.isEmpty else {
            return nil
        }
        
        return text
    }
    
    // challenge 2
    func setPasswordError(title: String) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] action in
            self?.setPassword()
        })
        
        present(ac, animated: true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        }
        else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff"
        
        // challenge 1
        navigationItem.rightBarButtonItem = doneButton

        // challenge 2
        navigationItem.leftBarButtonItem = passwordButton
        
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            secret.text = text
        }
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        
        secret.resignFirstResponder() // stop the textView from being active
        secret.isHidden = true
        
        // challenge 1
        navigationItem.rightBarButtonItem = nil
        
        // challenge 2
        navigationItem.leftBarButtonItem = nil
        
        title = "Nothing to see here"
    }
}

