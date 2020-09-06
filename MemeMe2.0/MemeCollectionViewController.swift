//
//  MemeCollectionViewController.swift
//  MemeMe2.0
//
//  Created by Daniel Soutar on 06/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import UIKit

class MemeCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var memePreview: UIImageView!
}

class MemeCollectionViewController: UICollectionViewController {

    // MARK: - Outlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    // MARK: - Computed Memes Property

    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    // MARK: - Adding a Meme/Opening the Editor
    
    @IBAction func addMeme(_ sender: Any) {
        let editorController = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        // Pass the reloadData() method as a closure to the editor, to be called on completion.
        editorController.reloader = self.collectionView.reloadData
        present(editorController, animated: true, completion: nil)
    }
    
    // MARK: - View-related Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }

    // MARK: - Collection View Methods

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell

        // Configure the cell
        cell.memePreview?.image = memes[indexPath.row].image

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = self.storyboard?.instantiateViewController(withIdentifier: "SentMemeDetailViewController") as! SentMemeDetailViewController
        detail.meme = memes[indexPath.row]

        self.navigationController?.pushViewController(detail, animated: true)
    }

}
