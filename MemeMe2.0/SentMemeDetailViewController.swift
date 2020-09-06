//
//  SentMemeDetailViewController.swift
//  MemeMe2.0
//
//  Created by Daniel Soutar on 06/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import UIKit

class SentMemeDetailViewController: UIViewController {
    
    // Image view
    @IBOutlet weak var memeView: UIImageView!
    
    // Meme var
    var meme: Meme!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.memeView!.image = self.meme.memedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

}
