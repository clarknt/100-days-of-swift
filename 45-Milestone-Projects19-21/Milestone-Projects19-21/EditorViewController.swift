//
//  DetailViewController.swift
//  Milestone-Projects19-21
//

import UIKit

protocol EditorDelegate {
    // for structural modifications (addition/deletion)
    func editor(_ editor: EditorViewController, didUpdate notes: [Note])
}

class EditorViewController: UIViewController {

    // MARK: - variables
    
    @IBOutlet var textView: UITextView!
    
    var notes: [Note]!
    var noteIndex: Int!
    var delegate: EditorDelegate?
   
    // used for comparison before saving
    var originalText: String!
    
    var shareButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    
    // MARK: - init and deinit
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard isParametersSet() else {
            print("Parameters not provided")
            navigationController?.popViewController(animated: true)
            return
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        if let backgroundImage = UIImage(named: "white_wall") {
            // this will tile the image
            view.backgroundColor = UIColor(patternImage: backgroundImage)
        }

        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        // done button is shown only when keyboard is displayed
        navigationItem.rightBarButtonItems = [shareButton]
        Styling.setNavigationBarColors(for: navigationController)

        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let new = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newTapped))
        toolbarItems = [deleteButton, space, new]
        navigationController?.isToolbarHidden = false
        Styling.setToolbarColors(for: navigationController)

        textView.text = notes[noteIndex].text
        originalText = notes[noteIndex].text
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // only case where it can be nil is if there are no remaining notes after a deletion
        guard noteIndex != nil else { return }

        saveNote()
    }

    func setParameters(notes: [Note], noteIndex: Int) {
        self.notes = notes
        self.noteIndex = noteIndex
    }
    
    func isParametersSet() -> Bool {
        return notes != nil && noteIndex != nil
    }
    
    // MARK: - actions
    
    @objc func shareTapped() {
        // mimic notes app
        hideKeyboard()
        saveNote()
        
        let vc = UIActivityViewController(activityItems: [notes[noteIndex].text], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = shareButton
        present(vc, animated: true)
    }
    
    @objc func deleteTapped() {
        // the notes application does not ask for confirmation, but moves deleted notes to a "Recently deleted" folder
        // folders are not implemented here, so a confirmation is asked instead
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.barButtonItem = deleteButton
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteNote()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func newTapped() {
        // save current note
        saveNote()
        
        // create new note
        notes.append(Note(text: "", modificationDate: Date()))
        notifyDelegateDidUpdate(notes: notes)

        noteIndex = notes.count - 1
        textView.text = ""
        originalText = ""
        
        saveNote(newNote: true)
    }
    
    @objc func doneTapped() {
        hideKeyboard()
    }
    
    // MARK: - deletion
    
    func deleteNote() {
        notes.remove(at: noteIndex)
        notifyDelegateDidUpdate(notes: notes)

        DispatchQueue.global().async { [weak self] in
            if let notes = self?.notes {
                Storage.save(notes: notes)
            }
            
            DispatchQueue.main.async {
                self?.updateGuiAfterDeletion()
            }
        }
    }
    
    // mimic the notes application behavior
    func updateGuiAfterDeletion() {

        // if there's an older note: display it
        if noteIndex < notes.count {
            textView.text = notes[noteIndex].text
            return
        }
            
        // if there's a newer note: display it
        if notes.count > 0 {
            noteIndex = notes.count - 1
            textView.text = notes[noteIndex].text
            return
        }
            
        // this was the last note: invalidate the index and return to the main menu
        noteIndex = nil
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - saving
    
    func saveNote(newNote: Bool = false) {
        // save only if text has changed, or if it's a new note
        if textView.text != originalText || newNote {
            originalText = textView.text
            notes[noteIndex].text = textView.text
            notes[noteIndex].modificationDate = Date()
            
            DispatchQueue.global().async { [weak self] in
                if let notes = self?.notes {
                    Storage.save(notes: notes)
                }
            }
        }
    }

    // MARK: - utils
    
    func notifyDelegateDidUpdate(notes: [Note]) {
        if let delegate = delegate {
            delegate.editor(self, didUpdate: notes)
        }
    }
    
    func hideKeyboard() {
        textView.endEditing(true)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
            navigationItem.rightBarButtonItems = [shareButton]
            saveNote() // save each time keyboard is hidden
        }
        else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            navigationItem.rightBarButtonItems = [doneButton, shareButton] // buttons appear in reverse order
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
        
    }
}
