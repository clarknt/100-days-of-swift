//
//  LoadViewController.swift
//  Extension
//

import UIKit

// challenge 3
protocol LoaderDelegate {
    func loader(_ loader: LoaderViewController, didSelect script: String)
    
    // bonus: allow deleting scripts
    func loader(_ loader: LoaderViewController, didUpdate scripts: [UserScript])
}

class LoaderViewController: UITableViewController {

    var savedScriptsByName: [UserScript]!
    var savedScriptsByNameKey: String!
    
    var delegate: LoaderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard savedScriptsByName != nil && savedScriptsByNameKey != nil else {
            print("Parameters not set")
            navigationController?.popViewController(animated: true)
            return
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedScriptsByName.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Script", for: indexPath)
        cell.textLabel?.text = savedScriptsByName[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.loader(self, didSelect: savedScriptsByName[indexPath.row].script)
        navigationController?.popViewController(animated: true)
    }
    
    // bonus: add swipe to delete row functionnality
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedScriptsByName.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            delegate?.loader(self, didUpdate: self.savedScriptsByName)
            performSelector(inBackground: #selector(saveScriptsByName), with: nil)
        }
    }
    
    // bonus: add swipe to delete row functionnality
    // meant for background thread
    @objc func saveScriptsByName() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(savedScriptsByName) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(savedData, forKey: savedScriptsByNameKey)
        }
    }

}
