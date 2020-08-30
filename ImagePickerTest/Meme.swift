//
//  Meme.swift
//  ImagePickerTest
//
//  Created by Daniel Soutar on 30/08/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation
import UIKit

// Simple data structure for modelling user data.
struct Meme {
    var topText: String?            // The text at the top of the meme.
    var botText: String?            // The text at the bottom of the meme.
    var image: UIImage?             // The background image used for the meme.
    var memedImage: UIImage?        // The meme as a rendered image.
}
