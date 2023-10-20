import UIKit
import CoreData

class WriteNoteVC: UIViewController,
                   UITextViewDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var updateButton: UIBarButtonItem!
    @IBOutlet weak var noteTextView: UITextView!
    
    var chosenNote = ""
    var chosenNoteId : UUID?
    var saveButtonEnabled = false
    var uploadButtonEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customBackgroundView()
        
        saveButton.isEnabled = false
        updateButton.isEnabled = false
        noteTextView.delegate = self
        saveButtonEnabled = true
        uploadButtonEnabled = false
        
        getSavedNot()
        
        //Hide Keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: Save Note
    @IBAction func saveButtonClicked(_ sender: Any) {
        saveCoreData(alertTitle: "Saved!", dataMessage: "newData")
    }
    
    //MARK: Update Note
    @IBAction func updateButtonClicked(_ sender: Any) {
        saveCoreData(alertTitle: "Updated!", dataMessage: "uploadData")
    }
    
    
    //MARK: Get Title
    func getTitle() -> String {
        var title = ""
        if let text = noteTextView.text {
            let lines = text.split(separator: "\n")
            if let firstLine = lines.first {
                title = String(firstLine)
            }
        }
        return title
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = saveButtonEnabled
        updateButton.isEnabled = uploadButtonEnabled
    }
    
    func customBackgroundView() {
        backgroundView.layer.cornerRadius = backgroundView.frame.height / 16
    }
    
    //MARK: Alert
    func alert(alertTitle: String) -> UIAlertController {
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { UIAlertAction in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okButton)
        
        return alert
    }
    
    //MARK: Save Core Data
    func saveCoreData(alertTitle: String, dataMessage: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newNotes = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        newNotes.setValue(noteTextView.text, forKey: "note")
        newNotes.setValue(getTitle(), forKey: "title")
        newNotes.setValue(UUID(), forKey: "id")
        do {
            try context.save()
            self.present(alert(alertTitle: alertTitle), animated: true)
        } catch {
            print("Data is not Save!")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: dataMessage), object: nil)
    }
    
    //MARK: Get Saved Note
    func getSavedNot() {
        if chosenNote != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            let idString = chosenNoteId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let note = result.value(forKey: "note") as? String {
                            noteTextView.text = note
                            saveButton.isEnabled = false
                            saveButtonEnabled = false
                            uploadButtonEnabled = true
                        }
                    }
                }
            } catch {
                print("error")
            }
        }
    }
    
}
