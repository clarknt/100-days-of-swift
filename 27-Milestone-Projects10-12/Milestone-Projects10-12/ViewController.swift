//
//  ViewController.swift
//  Milestone-Projects10-12
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var pictures = [Picture]()
    var popping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPicture))
        self.tableView.rowHeight = 100
        
        DispatchQueue.global().async { [weak self] in
            self?.pictures = Utils.loadPictures()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // coming back from DetailViewController, caption might have been changed
        if popping {
            tableView.reloadData()
        }
        popping = false
    }
    
    @objc func addPicture() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let ac = UIAlertController(title: "Source", message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "Photos", style: .default, handler: { [weak self] _ in
                self?.showPicker(fromCamera: false)
            }))
            ac.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
                self?.showPicker(fromCamera: true)
            }))
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(ac, animated: true)
        }
        else {
            showPicker(fromCamera: false)
        }
    }

    func showPicker(fromCamera: Bool) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        if fromCamera {
            picker.sourceType = .camera
        }
        present(picker, animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        DispatchQueue.global().async { [weak self] in
            let imageName = UUID().uuidString
            
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: Utils.getImageURL(for: imageName))
            }

            DispatchQueue.main.async {
                self?.dismiss(animated: true)

                let ac = UIAlertController(title: "Caption?", message: "Enter a caption for this image", preferredStyle: .alert)
                ac.addTextField()
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac] _ in
                    guard let caption = ac?.textFields?[0].text else { return }
                    self?.savePicture(imageName: imageName, caption: caption)
                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

                self?.present(ac, animated: true)
            }
        }
    }

    func savePicture(imageName: String, caption: String) {
        let picture = Picture(imageName: imageName, caption: caption)
        pictures.append(picture)
        
        DispatchQueue.global().async { [weak self] in
            if let pictures = self?.pictures {
                Utils.savePictures(pictures: pictures)
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        
        if let cell = cell as? PictureCell {
            cell.captionLabel?.text = pictures[indexPath.row].caption
            let path = Utils.getImageURL(for: pictures[indexPath.row].imageName)
            cell.pictureView?.image = UIImage(contentsOfFile: path.path)
            cell.pictureView?.layer.borderColor = UIColor.black.cgColor
            cell.pictureView?.layer.borderWidth = 0.1
            cell.pictureView?.layer.cornerRadius = 5
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            detailViewController.pictures = pictures
            detailViewController.currentPicture = indexPath.row
            popping = true
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    // swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            pictures.remove(at: indexPath.row)
            
            DispatchQueue.global().async { [weak self] in
                if let pictures = self?.pictures {
                    Utils.savePictures(pictures: pictures)
                }
                
                DispatchQueue.main.async {
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}

