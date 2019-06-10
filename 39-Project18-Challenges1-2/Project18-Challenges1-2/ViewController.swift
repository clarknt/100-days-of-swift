//
//  ViewController.swift
//  project18-Challenges1-2
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let fm = FileManager.default
        
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        
        // challenge 2
        pictures.sort()
        
        
        print("Pictures: \(pictures)")
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // project 18 challenge 1
        //if let vc = storyboard?.instantiateViewController(withIdentifier: "Bad") as? DetailViewController {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            // comment the next line to test project 18 challenge 2
            vc.selectedImage = pictures[indexPath.row]

            // challenge 3
            vc.position = (position: indexPath.row + 1, total: pictures.count)

            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
