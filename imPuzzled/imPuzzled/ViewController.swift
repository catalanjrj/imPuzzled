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
    
    var settings: [(name: String, value: Int32)] = []
    var capabilities: [[String : AnyObject]]!

}


class ViewController: UITableViewController,NSFetchedResultsControllerDelegate,APIDataDelegate {
    
    @IBOutlet var newGameButton: UIBarButtonItem!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var apidata: APIData!
    var gameOption: gameOptions!
    var currentGame: Game!
    
    
    //
    //  get the capabilities of this game from the api
    //
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        newGameButton.enabled = false
        
        gameOption = gameOptions()
        gameOption.settings += [(name: "Width", value: 20)]
        gameOption.settings += [(name: "Heigth", value: 20)]
        gameOption.settings += [(name: "Words", value: 10)]
        gameOption.settings += [(name: "Min Length", value: 4)]
        gameOption.settings += [(name: "Max Length", value: 8)]
        
        let url = "polar-savannah-54119.herokuapp.com/capabilities"
        apidata = APIData(request: url, delegate: self)
        
    }
    
    
    //
    //  back from the api so build the gameoptions struct
    //
    func gotAPIData(apidata: APIData) {
        
        if apidata.dictionary != nil {
            gameOption.capabilities = apidata.dictionary as! [[String : AnyObject]]
            for index in 0...gameOption.capabilities.count-1 {
                gameOption.capabilities[index]["used"] = false
                newGameButton.enabled = true
            }
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
    //  restart game for selected row
    //
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.currentGame = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Game
            performSegueWithIdentifier("showPlayGame", sender: self)
        }
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
        if segue.identifier == "showNewGame" {
            //let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let dvc = segue.destinationViewController as! NewGameViewController
            dvc.gameOption = self.gameOption
            dvc.managedObjectContext = self.managedObjectContext
        }
        
        else if segue.identifier == "showPlayGame" {
            let dvc = segue.destinationViewController as! PlayGameTabViewController
            dvc.game = self.currentGame
        }

        
    }
    
    //
    //  unwind
    //
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
       
        if segue.identifier == "unwindNewGame" {
            let dvc = segue.sourceViewController as! NewGameViewController
            if dvc.game != nil {
                let game = dvc.game
                self.managedObjectContext?.insertObject(game!)
                game?.doSave()
                game?.startGame(gameReady)
            }
        }
    }
    
    
    //
    //  the game is ready to play
    //
    func gameReady(game: Game){
    
        currentGame = game
        performSegueWithIdentifier("showPlayGame", sender: self)
    
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
