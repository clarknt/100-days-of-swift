//
//  ViewController.swift
//  Milestone-Projects19-21
//

import UIKit

class MainViewController: UITableViewController, EditorDelegate {
    // MARK: - variables
    
    var notes = [Note]()
    
    var selectedCellView: UIView!

    // navigation items
    var editButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    // toolbar items
    var spacerButton: UIBarButtonItem!
    var notesCountButton: UIBarButtonItem!
    var newNoteButton: UIBarButtonItem!
    var deleteAllButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!

    // MARK: - init
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true

        if let backgroundImage = UIImage(named: "white_wall") {
            // this will tile the image
            tableView.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        
        // navigationBar
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(enterEditingMode))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditingMode))
        navigationItem.rightBarButtonItems = [editButton]
        Styling.setNavigationBarColors(for: navigationController)

        // toolbar
        newNoteButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNote))
        spacerButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        notesCountButton = UIBarButtonItem(title: "\(notes.count) Notes", style: .plain, target: nil, action: nil)
        notesCountButton.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11),
            NSAttributedString.Key.foregroundColor : UIColor.darkText
            ], for: .normal)
        toolbarItems = [spacerButton, notesCountButton, spacerButton, newNoteButton]
        navigationController?.isToolbarHidden = false
        Styling.setToolbarColors(for: navigationController)
        
        deleteAllButton = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteAllTapped))
        deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteTapped))

        // cell selection color
        selectedCellView = UIView()
        selectedCellView.backgroundColor = UIColor.orange.withAlphaComponent(0.2)
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        reloadDataFromStorage()
    }

    override func viewWillAppear(_ animated: Bool) {
        sortNotes()
        updateData()
    }

    // MARK: - utils
    
    func reloadDataFromStorage() {
        DispatchQueue.global().async { [weak self] in
            self?.notes = Storage.load()
            self?.sortNotes()
            
            DispatchQueue.main.async {
                self?.updateData()
            }
        }
    }
    
    func updateData() {
        tableView.reloadData()
        updateNotesCount()
    }
    
    func sortNotes() {
        notes.sort(by: { $0.modificationDate >= $1.modificationDate })
    }
    
    func updateNotesCount() {
        notesCountButton.title = "\(notes.count) Notes"
    }

    // MARK: - tableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)

        if let cell = cell as? NoteCell {
            let note = notes[indexPath.row]
            let split = note.text.split(separator: "\n", maxSplits: 2, omittingEmptySubsequences: true)
            
            cell.titleLabel.text = getTitleText(split: split)
            cell.subtitleLabel.text = getSubtitleText(split: split)
            cell.dateLabel.text = formatDate(from: note.modificationDate)

            setCellColors(for: cell)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            
            DispatchQueue.global().async { [weak self] in
                if let notes = self?.notes {
                    Storage.save(notes: notes)
                }
                
                DispatchQueue.main.async {
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.updateNotesCount()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            toolbarItems = [spacerButton, deleteButton]
        }
        else {
            openDetailViewController(noteIndex: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            if tableView.indexPathsForSelectedRows == nil || tableView.indexPathsForSelectedRows!.isEmpty {
                toolbarItems = [spacerButton, deleteAllButton]
            }
        }
    }
    
    // MARK: - cell content
    
    func getTitleText(split: [Substring]) -> String {
        if split.count >= 1 {
            return String(split[0])
        }
        
        return "New Note"
    }
    
    func getSubtitleText(split: [Substring]) -> String {
        if split.count >= 2 {
            return String(split[1])
        }
        
        return "No additional text"
    }
    
    func formatDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        // date is today: return time only
        if Calendar.current.isDateInToday(date) {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: date)
        }
        
        // date is yesterday: return a fixed string
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        
        // date not today: return date
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    func setCellColors(for cell: UITableViewCell) {
        // can reuse the same view for single selection
        cell.selectedBackgroundView = selectedCellView
        
        // must create a new view each time for multiple selection
        let multipleSelectedCellView = UIView()
        multipleSelectedCellView.backgroundColor = UIColor.orange.withAlphaComponent(0.2)
        cell.multipleSelectionBackgroundView = multipleSelectedCellView
        
        // orange check marks in editing mode
        cell.tintColor = .orange
    }
    
    // MARK: - actions
    
    func openDetailViewController(noteIndex: Int) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? EditorViewController {
            vc.setParameters(notes: notes, noteIndex: noteIndex)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func createNote() {
        notes.append(Note(text: "", modificationDate: Date()))
        DispatchQueue.global().async { [weak self] in
            if let notes = self?.notes {
                Storage.save(notes: notes)
                
                DispatchQueue.main.async {
                    self?.openDetailViewController(noteIndex: notes.count - 1)
                }
            }
        }
    }
    
    // MARK: - tableView editing mode

    @objc func enterEditingMode() {
        navigationItem.rightBarButtonItems = [cancelButton]
        toolbarItems = [spacerButton, deleteAllButton]
        setEditing(true, animated: true)
    }
    
    @objc func cancelEditingMode() {
        navigationItem.rightBarButtonItems = [editButton]
        toolbarItems = [spacerButton, notesCountButton, spacerButton, newNoteButton]
        setEditing(false, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        //tableView.reloadData()
    }
    
    @objc func deleteAllTapped() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.barButtonItem = deleteAllButton
        ac.addAction(UIAlertAction(title: "Delete All", style: .destructive, handler: { [weak self] _ in
            self?.deleteAll()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func deleteAll() {
        notes = [Note]()
        DispatchQueue.global().async { [weak self] in
            if let notes = self?.notes {
                Storage.save(notes: notes)
            }
            
            DispatchQueue.main.async {
                self?.updateData()
                self?.cancelEditingMode()
            }
        }
    }
    
    @objc func deleteTapped() {
        // the notes application does not ask for confirmation, but moves deleted notes to a "Recently deleted" folder
        // folders are not implemented here, so a confirmation is asked instead
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.barButtonItem = deleteButton
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            if let selectedRows = self?.tableView.indexPathsForSelectedRows {
                self?.deleteNotes(rows: selectedRows)
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func deleteNotes(rows: [IndexPath]) {
        for path in rows {
            notes.remove(at: path.row)
        }
        
        DispatchQueue.global().async { [weak self] in
            if let notes = self?.notes {
                Storage.save(notes: notes)
            }
            
            DispatchQueue.main.async {
                self?.updateData()
                self?.cancelEditingMode()
            }
        }
    }

    // MARK: - editor delegate
    
    func editor(_ editor: EditorViewController, didUpdate notes: [Note]) {
        self.notes = notes
    }
}

