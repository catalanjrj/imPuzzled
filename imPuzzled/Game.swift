//
//  Game.swift
//  imPuzzled
//
//  Created by Tom Williamson on 5/17/16.
//  Copyright © 2016 Steve Graff. All rights reserved.
//

import Foundation
import CoreData


class Game: NSManagedObject,APIDataDelegate {
    
    private var gameReady: ((Game) -> Void)!
    private var options: gameOptions!
    var apidata: APIData!
    
    //
    //  build a new game
    //
    func buildGame(options: gameOptions) {
        
        self.options = options
        
        width = findSetting("Width")
        width = findSetting("Height")
        width = findSetting("Words")
        width = findSetting("Min Length")
        width = findSetting("Max Length")
        
    }
    
    //
    //  find setting value 
    //
    func findSetting(name: String) -> Int32 {
        
        for setting in options.settings {
            if setting.name == name {
                return setting.value
            }
        }
        return 0
    }
    
    
    //
    //  start a new game
    //
    func startGame(whenReady: ((Game) -> Void)) {
        
        gameReady = whenReady
        let url = "polar-savannah-54119.herokuapp.com/capabilities"
        apidata = APIData(request: url, delegate: self)
        
    }
    
    //
    //  back from the api so build the game
    //
    func gotAPIData(apidata: APIData) {
        
        if apidata.dictionary != nil {
            
            let curdate = NSDate().timeIntervalSince1970
            started = curdate
            lastUsed = curdate
            
            charactersAttr = []
            characters = []
            
            let char = "xxcat" +
                "hixxx" +
                "abcde" +
                "xxgod" +
                "cbyex"
            
            width = 5
            height = 5
            characters = Array(char.characters.map { String($0) })
            charactersAttr = [String](count: char.characters.count, repeatedValue: " ")
            
            var words = [[String: AnyObject]]()
            words += [["word":"cat", "found": false]]
            words += [["word":"hi", "found": false]]
            words += [["word":"dog", "found": false]]
            words += [["word":"bye", "found": false]]
            self.words = words
            doSave()
            
            gameReady(self)
            
        }
    }

    
    
    //
    //  save this game
    //
    func doSave() {
        
        if self.managedObjectContext!.hasChanges {
            do {
                try managedObjectContext!.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}
