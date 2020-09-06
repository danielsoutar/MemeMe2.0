//
//  ImagePickerDelegate.swift
//  ImagePickerTest
//
//  Created by Daniel Soutar on 30/08/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation
import UIKit

extension MemeEditorViewController: UIImagePickerControllerDelegate {
    
    // MARK: - Logging Function for Media Types Available
    
    func printAvailableMediaTypes(for type: UIImagePickerController.SourceType, with identifier: String) {
        let mediaTypes = UIImagePickerController.availableMediaTypes(for: type)
        
        // Should really be cast to an empty collection rather than nil...
        if let mediaTypes = mediaTypes {
            for type in mediaTypes {
                print(identifier + ": " + type)
            }
        }
    }
    
    // MARK: - Image Selection Function for iPad/iPhone

    func pickImage(for mediaTypes: [MediaType], from sender: Any) {
        var mediaTypesAreAvailable = false
        for mediaType in mediaTypes {
            mediaTypesAreAvailable = mediaTypesAreAvailable || UIImagePickerController.isSourceTypeAvailable(mediaType.mediaType)
        }
        
        let usePopover = UIDevice.current.userInterfaceIdiom == .pad && !UIImagePickerController.isSourceTypeAvailable(.camera)
        
        if mediaTypesAreAvailable {
            for mediaType in mediaTypes {
                printAvailableMediaTypes(for: mediaType.mediaType, with: mediaType.identifier)
            }
            
            let uiImagePicker = UIImagePickerController()
            uiImagePicker.delegate = self
            // Set the source type to be the first of the media types available.
            // This could be improved, but in practice this works with the camera/album buttons.
            uiImagePicker.sourceType = mediaTypes[0].mediaType
            
            if usePopover {
                // Stupidly, a PopoverPresentationController cannot be created by you. Instead
                // you create a UIImagePickerController and iOS for some reason creates the popover
                // controller behind the scenes after you set the presentation style as .popover.
                uiImagePicker.view.backgroundColor = .white
                uiImagePicker.modalPresentationStyle = .popover
                
                // Configure the secretly-created popovercontroller - here we are
                // specifying how to position the popover with the anchor and direction to pop
                // out, as well as setting the delegate property.
                let ppc = uiImagePicker.popoverPresentationController
                // The little triangle pointing to the button pressed should be down,
                // or equivalently the popover should be above the button.
                ppc?.permittedArrowDirections = .down
                ppc?.delegate = self
                ppc?.barButtonItem = (sender as! UIBarButtonItem)
                
                // The code below is WRONG
                // let uiPopover = UIPopoverPresentationController()
                // uiPopover.delegate = self
                // present(uiPopover, animated: true, completion: nil)
            }
            // Now present it.
            present(uiImagePicker, animated: true, completion: nil)
        } else {
            // Concatenate the available media types into a useful error string.
            // Specifically, the below closure is used to acquire each identifier
            // in the mediaTypes array, and then joined with commas.
            var mediaTypesListString
                = String(JoinedSequence(base: mediaTypes.map{ $0.identifier },
                                        separator: ","))
            // Add plural or singular contingent on size of media types array.
            mediaTypesListString = mediaTypes.count > 1 ?
                "the " + mediaTypesListString + " are" :
                "the " + mediaTypesListString + " is"
            
            // Add the alert - although nothing we can do, so no action.
            let alert = UIAlertController(title: "Unable to open Media",
                                          message: "Unfortunately \(mediaTypesListString) not available.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                                   comment: "Default action"),
                                          style: .default,
                                          handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Implement the UIImagePickerControllerDelegate Protocol
 
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePicker.image = image
            // Enable sharing as an image is now available.
            sharingEnabled = true
            navbar.topItem?.leftBarButtonItem?.isEnabled = sharingEnabled
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // Not sure what else would need adding here?
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
