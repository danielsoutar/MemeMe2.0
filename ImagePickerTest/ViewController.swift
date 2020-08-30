//
//  ViewController.swift
//  ImagePickerTest
//
//  Created by Daniel Soutar on 29/08/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import UIKit

struct MediaType {
    var mediaType: UIImagePickerController.SourceType = .camera
    var identifier: String = ""
}

class ViewController: UIViewController,
                      UINavigationControllerDelegate,
                      UIPopoverPresentationControllerDelegate {
    
    // MARK: - Outlets

    // Navigation bar
    @IBOutlet weak var navbar: UINavigationBar!
    
    // Top text field
    @IBOutlet weak var topTextField: UITextField!
    
    // Image view
    @IBOutlet weak var imagePicker: UIImageView!
    
    // Bottom text field
    @IBOutlet weak var bottomTextField: UITextField!
    
    // Toolbar
    @IBOutlet weak var toolbar: UIToolbar!
    
    // Buttons on Toolbar
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    // MARK: - Constants
    
    let DEFAULT_TOP_TEXT = "TOP"
    let DEFAULT_BOT_TEXT = "BOTTOM"
    
    // MARK: - Variables
    
    var meme: Meme?
    
    // MARK: - Switch for determining when to enable sharing
    
    var sharingEnabled = false
    
    // MARK: - Switch for determining when to shift the View
    
    var bottomSwitchIsEditing = false
    
    // MARK: - Appear/Load methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureTextFields()

        navbar.topItem?.leftBarButtonItem
            = UIBarButtonItem(barButtonSystemItem: .action,
                              target: self,
                              action: #selector(shareTapped))
        navbar.topItem?.rightBarButtonItem
            = UIBarButtonItem(title: "Cancel",
                              style: .plain,
                              target: self,
                              action: #selector(cancelTapped))
        
        // Disable sharing until an image is chosen.
        navbar.topItem?.leftBarButtonItem?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Disable the camera button if no camera
        // available.
        self.cameraButton.isEnabled
            = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // Subscribe to keyboard notifications
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // We do this before this ViewController is deallocated from
        // memory - as that would lead to a broken observer otherwise.
        // That would be better put in a `deinit` method. But it also
        // makes sense, since there is no value in manipulating the
        // view when this ViewController is not visible.
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Navigation Bar Button delegates
    
    // Share the meme generated.
    @objc func shareTapped() {
        let newMeme = Meme(topText: topTextField.text,
                           botText: bottomTextField.text,
                           image: imagePicker.image,
                           memedImage: generateMeme())
        
        // For future improvement, on iPad this must be a popover, and on iPhone, modal.
        let ac = UIActivityViewController(activityItems: [newMeme],
                                          applicationActivities: nil)
        ac.completionWithItemsHandler = { (type,completed,items,error) in
            self.meme = newMeme
            ac.dismiss(animated: true, completion: nil)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            ac.modalPresentationStyle = .popover
            
            // Configure secretly-created popovercontroller - here we are
            // specifying how to position the popover with the anchor and
            // direction to pop out, as well as setting the delegate property.
            let ppc = ac.popoverPresentationController
            // The little triangle pointing to the button pressed should be
            // up, or equivalently the popover should be below the button.
            ppc?.permittedArrowDirections = .up
            ppc?.delegate = self
            ppc?.barButtonItem = navbar.topItem?.leftBarButtonItem
        }
        // Now present it.
        present(ac, animated: true, completion: nil)
    }
    
    // Cancel the meme generated. Resets the text fields and image picker.
    // Also disables sharing again, as no image is present.
    @objc func cancelTapped() {
        configureTextFields()
        self.imagePicker.image = nil
        navbar.topItem?.leftBarButtonItem?.isEnabled = false
    }
    
    // MARK: - Meme Generation and Storage
    
    func generateMeme() -> UIImage {
        // Hide toolbar
        toolbar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar
        toolbar.isHidden = false
        
        return memedImage
    }
    
    
    // MARK: - Keyboard-View manipulation
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if self.bottomSwitchIsEditing {
            self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        if let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            return keyboardSize.cgRectValue.height
        } else {
            print("This should never print - calling getKeyboardHeight(_:) without a valid userInfo dictionary.")
            return 0.0
        }
    }
    
    // MARK: - (Un)Subscribing to NSNotifications for Keyboard
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    // MARK: - Setting up an ImagePicker
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        pickImage(for: [MediaType(mediaType: .camera, identifier: "Camera")],
                  from: sender)
    }
    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        pickImage(for: [MediaType(mediaType: .photoLibrary, identifier: "Photo Library"),
                        MediaType(mediaType: .savedPhotosAlbum, identifier: "Saved Photos Album")],
                  from: sender)
    }
    
}
