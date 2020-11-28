//
//  WorkoutViewController.swift
//  FitBeats
//
//  Created by Dillon Shipley on 11/27/20.
//

import CoreData
import UIKit

class WorkoutTableViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var workouts = [Workout]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectoryURL)
        
        loadCategories()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return workouts.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = workouts[indexPath.row]
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // MARK: lab #15
            // PSEUDOCODE SOLUTION
            // fetch all of the items that have this
            // category as their parent
            // delete those items
            // then delete the category
            // write your code here to do this
            
            // we first want to delete the Category at indexPath.row from our context
            // then later... we want to save our context so the deletion persists
            context.delete(workouts[indexPath.row])
            workouts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // make the deletion persist
            saveCategories()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let category = workouts.remove(at: sourceIndexPath.row)
        workouts.insert(category, at: destinationIndexPath.row)
        tableView.reloadData()
    }

    
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Create New Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name of Category"
            alertTextField = textField
        }
        
        let action = UIAlertAction(title: "Create", style: .default) { (alertAction) in
            let text = alertTextField.text!
            // CREATE
            // make a Category using context
            let newCategory = Workout(context: self.context)
            newCategory.name = text
            self.workouts.append(newCategory)
            self.saveCategories()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if let identifier = segue.identifier, identifier == "ShowItemsSegue"  {
            
            guard let itemsTableVC = segue.destination as? ItemsTableViewController else {
                return
            }
        
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
                return
            }
            
            let category = workouts[selectedIndexPath.row]
            itemsTableVC.category = category
        }*/
    }
    
    func saveCategories() {
        // we need to save the context
        do {
            try context.save() // like a git commit
        }
        catch {
            print("Error saving categories \(error)")
        }
        tableView.reloadData()
    }
    
    // READ of CRUD
    func loadCategories() {
        // we need to "request" the categories from the database (using the persistent container's context
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        // when you execute a SQL SELECT statement, you usually filter the rows you want back in your query using a WHERE clause
        // to do this with core data, we use a "predicate" and attach it to our request
        // for categories, we want all rows in the category table, so we don't need to filter, but we will for items later...
        do {
            workouts = try context.fetch(request)
        }
        catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
    

}
