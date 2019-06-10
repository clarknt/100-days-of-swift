//
//  LoadViewController.swift
//  Extension
//

import UIKit

// challenge 3
protocol ScriptLoaderDelegate {
    func setScriptToLoad(script: String)
    
    // bonus: allow deleting scripts
    func updateUserScripts(scripts: [UserScript])
}

class LoadViewController: UITableViewController {

    var savedScriptsByName: [UserScript]!
    var savedScriptsByNameKey: String!
    
    var scriptLoaderDelegate: ScriptLoaderDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard savedScriptsByName != nil
            && savedScriptsByNameKey != nil
            && scriptLoaderDelegate != nil else {
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
        scriptLoaderDelegate.setScriptToLoad(script: savedScriptsByName[indexPath.row].script)
        navigationController?.popViewController(animated: true)
    }
    
    // bonus: add swipe to delete row functionnality
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedScriptsByName.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            self.scriptLoaderDelegate.updateUserScripts(scripts: self.savedScriptsByName)
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
