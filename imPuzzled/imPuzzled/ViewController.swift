//
//  ViewController.swift
//  imPuzzled
//
//  Created by Steve Graff on 5/17/16.
//  Copyright © 2016 Steve Graff. All rights reserved.
//

import UIKit
import CoreData

struct gameOptions {
    
    var width: Int32 = 20
    var height: Int32 = 20
    var words: Int32 = 10
    var minLength: Int32 = 4
    var maxLength: Int32 = 8
    var capabilities = [String]()
    
}


class ViewController: UITableViewController,NSFetchedResultsControllerDelegate,APIDataDelegate {
    
    @IBOutlet var newGameButton: UIBarButtonItem!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var apidata: APIData!
    var gameOption: gameOptions!
    
    
    //
    //  get the capabilities of this game from the api
    //
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        gameOption = gameOptions()
        
        let url = "polar-savannah-54119.herokuapp.com/capabilities"
        apidata = APIData(request: url, delegate: self)
    }
    
    
    //
    //  back from the api so build the gameoptions struct
    //
    func gotAPIData(apidata: APIData) {
        
        if apidata.dictionary != nil {
            var newDesc = [String]()
            for item in (apidata.dictionary as? NSArray)! {
                if let dict = item as? Dictionary<String, AnyObject> {
                    if let name = dict["name"] {
                        newDesc.append(name as! String)
                        newGameButton.enabled = true
                    }
                }
            }
            gameOption.capabilities = newDesc
        }
    }
    
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    
    //
    //  one row for each object
    //
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    
    //
    //  build cell for each row
    //
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        self.configureCell(cell, withObject: object)
        return cell
        
    }
    
    //
    //  allow cell to be edited
    //
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        return true
        
    }
    
    //
    //  table editing action
    //
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    
    //
    //  configure the cell
    //
    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        
        let game = object as! Game
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        let date = NSDate(timeIntervalSince1970:game.lastUsed)
        
        cell.textLabel!.text = formatter.stringFromDate(date)
        
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //
        //  show new game controller
        //
        if  segue.identifier == "showNewGame" {
            //let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let dvc = segue.destinationViewController as! NewGameViewController
            dvc.gameOption = self.gameOption
            dvc.managedObjectContext = self.managedObjectContext
        }
        
    }
    
    // MARK: - Fetched results controller
    
    //
    //  build a fetched result controller
    //
    var fetchedResultsController: NSFetchedResultsController {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Game", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "lastUsed", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            abort()
        }
        
        return _fetchedResultsController!
        
    }
    
    
    //
    // start editing
    //
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.tableView.beginUpdates()
        
    }
    
    
    
    //
    //  object changed
    //
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
            
        }
    }
    
    
    //
    //  object changed
    //
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! NSManagedObject)
        case .Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
        
    }
    
    
    //
    //  ending managed object updates
    //
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.tableView.endUpdates()
        
    }


    
}
