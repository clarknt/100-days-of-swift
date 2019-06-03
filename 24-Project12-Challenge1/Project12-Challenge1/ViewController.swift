//
//  ViewController.swift
//  Project12-Challenge1
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [String]()
    var picturesViewCount = [String: Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // project 3 challenge 2
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

        // project 9 challenge 1
        performSelector(inBackground: #selector(loadPictures), with: nil)
        
        // project 12 challenge 1
        let userDefaults = UserDefaults.standard
        picturesViewCount = userDefaults.object(forKey: "ViewCount") as? [String: Int] ?? [String: Int]()
    }
    
    @objc func loadPictures() {
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
        
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        cell.detailTextLabel?.text = "Views: \(picturesViewCount[pictures[indexPath.row], default: 0])"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]

            // challenge 3
            vc.position = (position: indexPath.row + 1, total: pictures.count)

            // project 12 challenge 1
            picturesViewCount[pictures[indexPath.row], default: 0] += 1

            DispatchQueue.global().async { [weak self] in
                self?.saveViewCount()

                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(vc, animated: true)
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    // project 3 challenge 2
    @objc func shareTapped() {
        var items: [Any] = ["This app is great, you should try it!"]
        if let url = URL(string: "https://www.hackingwithswift.com/100/16") {
            items.append(url)
        }
        
        let vc = UIActivityViewController(activityItems: items, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func saveViewCount() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(picturesViewCount, forKey: "ViewCount")
    }
}
