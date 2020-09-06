//
//  MemeTableViewController.swift
//  MemeMe2.0
//
//  Created by Daniel Soutar on 06/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import UIKit

class MemeTableViewCell : UITableViewCell {
    @IBOutlet weak var memePreview: UIImageView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var botText: UILabel!
}

class MemeTableViewController: UITableViewController {

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
        editorController.reloader = self.tableView.reloadData
        present(editorController, animated: true, completion: nil)
    }
    // MARK: - View-related Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Preserve selection between presentations.
        self.clearsSelectionOnViewWillAppear = false
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table View Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableViewCell", for: indexPath) as! MemeTableViewCell

        // Configure the cell...
        cell.imageView?.image = memes[indexPath.row].image
        cell.topText?.text = memes[indexPath.row].topText
        cell.botText?.text = memes[indexPath.row].botText

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = self.storyboard?.instantiateViewController(withIdentifier: "SentMemeDetailViewController") as! SentMemeDetailViewController
        detail.meme = memes[indexPath.row]

        self.navigationController?.pushViewController(detail, animated: true)
    }

}
