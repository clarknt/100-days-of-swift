//
//  ViewController.swift
//  Project30-Challenge2
//

import UIKit

class ViewController: UITableViewController {

    var flagsHD = [String]()
    var flagsSD = [String]()

    // project 30 challenge 2
    var flagsCache = [UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Country flags"
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix(getFlagPrefix(type: .HD)) {
                flagsHD.append(item)
            } else if item.hasPrefix(getFlagPrefix(type: .SD)) {
                flagsSD.append(item)
                // project 30 challenge 2
                flagsCache.append(nil)
            }
        }
        
        // sort in ascending name order
        flagsHD = sortFlags(flags: flagsHD, type: .HD)
        flagsSD = sortFlags(flags: flagsSD, type: .SD)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flagsHD.count
    }
    var counter = 0
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flag", for: indexPath) as! FlagCell
        
        cell.flagTextLabel?.text = getTextForFlag(flagName: flagsSD[indexPath.row], type: .SD)
        
        // project 30 challenge 2
        if flagsCache[indexPath.row] == nil {
            // use UIImage(contentsOfFile:) instead of UIImage(named:) to not use cache
            guard let path = Bundle.main.path(forResource: flagsSD[indexPath.row], ofType: nil) else { return cell }
            guard let image = UIImage(contentsOfFile: path) else { return cell }

            let renderRect = CGRect(origin: .zero, size: CGSize(width: 60, height: 40))
            let renderer = UIGraphicsImageRenderer(size: renderRect.size)
            flagsCache[indexPath.row] = renderer.image { ctx in
                image.draw(in: renderRect)
            }
        }
        
        let renderedImage = flagsCache[indexPath.row]!

        // image already has correct dimensions, just center it
        cell.flagImageView?.contentMode = .center
        
        cell.flagImageView?.image = renderedImage
        cell.flagImageView?.layer.borderColor = UIColor.black.cgColor
        cell.flagImageView?.layer.borderWidth = 0.1
        cell.flagImageView?.layer.cornerRadius = 5
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "FlagViewController") as? FlagViewController {
            vc.countryNumber = indexPath.row
            vc.flagsHD = flagsHD
            navigationController?.pushViewController(vc, animated: true)
        }        
    }
}

