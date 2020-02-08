//
//  ViewController.swift
//  Milestone-Projects1-3
//

import UIKit

class ViewController: UITableViewController {

    var flagsHD = [String]()
    var flagsSD = [String]()

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
            }
        }
        
        // sort in ascending name order
        flagsHD = sortFlags(flags: flagsHD, type: .HD)
        flagsSD = sortFlags(flags: flagsSD, type: .SD)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flagsHD.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flag", for: indexPath) as! FlagCell
        
        cell.flagTextLabel?.text = getTextForFlag(flagName: flagsSD[indexPath.row], type: .SD)
        
        cell.flagImageView?.image = UIImage(named: flagsSD[indexPath.row])
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

