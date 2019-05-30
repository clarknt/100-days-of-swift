//
//  DetailViewController.swift
//  project18-Challenges1-2
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: String?
    
    // challenge 3
    var position: (position: Int, total: Int)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // project 18 challenge 2
        assert(selectedImage != nil, "No image provided")
        
        // challenge 3
        guard let position = position else {
            print("No position provided")
            return
        }
        title = selectedImage! + " - \(position.position)/\(position.total)"

        navigationItem.largeTitleDisplayMode = .never
        
        imageView.image = UIImage(named: selectedImage!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
