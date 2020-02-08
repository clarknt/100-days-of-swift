//
//  DetailViewController.swift
//  Milestone-Projects10-12
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var pictures: [Picture]!
    var currentPicture: Int!
    var picture: Picture!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard pictures != nil && currentPicture != nil else {
            navigationController?.popViewController(animated: true)
            return
        }

        picture = pictures[currentPicture]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Caption", style: .plain, target: self, action: #selector(editTapped))
        
        title = picture.caption
        let path = Utils.getImageURL(for: picture.imageName)
        imageView.image = UIImage(contentsOfFile: path.path)
    }
    
    @objc func editTapped() {
        let ac = UIAlertController(title: "Edit caption", message: "Enter new caption", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
            if let newCaption = ac?.textFields?[0].text {
                self?.picture.caption = newCaption

                DispatchQueue.global().async {
                    if let pictures = self?.pictures {
                        Utils.savePictures(pictures: pictures)
                    }
                    
                    DispatchQueue.main.async {
                        self?.title = self?.picture.caption
                    }
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}
