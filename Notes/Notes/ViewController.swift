import UIKit
import CoreData

class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource {
    
    @IBOutlet weak var notesTableView: UITableView!
    var titleArray = [String]()
    var idArray = [UUID]()
    var noteArray = [String]()
    var selectedNote = ""
    var selectedNoteId : UUID?
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        //Hide Back Button
        navigationItem.setHidesBackButton(true, animated: true)
        
        getData()
        setData()
    }
    
    //MARK: Reset TableView
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setData), name: NSNotification.Name(rawValue: "uploadData"), object: nil)
    }
    
    //MARK: Get Data
    @objc func getData() {
        
        titleArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    if let note = result.value(forKey: "note") as? String {
                        self.noteArray.append(note)
                    }
                }
                self.notesTableView.reloadData()
            }
        } catch {
            print("error")
        }
    }
    
    //MARK: Set Data
    @objc func setData() {
        if selectedNote != "" {
            let idString = selectedNoteId!.uuidString
            deleteData(rowValue: selectedRow, idString: idString)
            getData()
        }
    }
    
    //MARK: Segue to WriteNoteVC
    @IBAction func newNoteButtonClicked(_ sender: Any) {
        selectedNote = ""
        performSegue(withIdentifier: "toWriteNoteVC", sender: nil)
    }
    
    //MARK: TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    //MARK: Cell View
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesTableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        cell.cellLabel.text = titleArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = noteArray[indexPath.row]
        selectedNoteId = idArray[indexPath.row]
        selectedRow = indexPath.row
        performSegue(withIdentifier: "toWriteNoteVC", sender: nil)
    }
    
    //MARK: Delete Data From Table View
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let idString = idArray[indexPath.row].uuidString
        
        if editingStyle == .delete {
            deleteData(rowValue: indexPath.row, idString: idString)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWriteNoteVC" {
            let destinationVC = segue.destination as! WriteNoteVC
            destinationVC.chosenNote = selectedNote
            destinationVC.chosenNoteId = selectedNoteId
        }
    }
    
    //MARK: Delete Data
    func deleteData(rowValue: Int, idString: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        if id == idArray[rowValue] {
                            context.delete(result)
                            titleArray.remove(at: rowValue)
                            idArray.remove(at: rowValue)
                            self.notesTableView.reloadData()
                            
                            do {
                                try context.save()
                            } catch {
                                print("error")
                            }
                            break
                        }
                    }
                }
            }
        } catch {
            print("error")
        }
    }
    
}

