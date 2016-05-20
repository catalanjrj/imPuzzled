//
//  PlayGameViewController.swift
//  imPuzzled
//
//  Created by Tom Williamson on 5/18/16.
//  Copyright © 2016 Steve Graff. All rights reserved.
//

import UIKit

class PlayGameViewController: UIViewController {
    
    
    @IBOutlet var recognizer: UIPanGestureRecognizer!
    
    var game: Game!
    
    private var lastLabel: UILabel? = nil
    private var firstLabel: UILabel? = nil
    private var secondLabel: UILabel? = nil
    
    private var labels: [UILabel] = []
    
    private let selectedColor = UIColor.redColor()
    private let unselectedColor = UIColor.blackColor()
    private let availColor = UIColor.greenColor()
    private let wordColor = UIColor.blueColor()

    //
    //  build game screen
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildLabels()

        
    }

    //
    //  build all the labels for the game
    //
    func buildLabels() {
        
        let chars = game.characters as! [String]
        var index = 0;
        
        for row:Int in 0...game.height-1 {
            for col:Int in 0...game.width-1 {
                let label = UILabel(frame: CGRectMake(CGFloat(col * 30) + 40, CGFloat(row * 30) + 80,
                    20, 20))
                label.userInteractionEnabled = true
                label.text = chars[index]
                label.tag = index
                view.addSubview(label)
                labels += [label]
                index += 1
            }
        }
        self.resetGrid()
    }
    
    //
    //  detect a user pan on the screen
    //
    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        
        let tapPoint = recognizer.locationInView(view)
        
        //
        //  start of pan
        //
        //  clear word and reset all labels
        //
        if recognizer.state == .Began {
            
            self.resetGrid()
        }
       
        //
        //  record character that is panned
        //
        if recognizer.state == .Changed {
            if let label = view.hitTest(tapPoint, withEvent: nil) as? UILabel {
                if lastLabel != label {
                    lastLabel = label
                    
                    //
                    //  look for first and second pan so we can see 
                    //  the pan direction
                    //
                    if firstLabel == nil {firstLabel = label}
                    else if secondLabel == nil {
                        secondLabel = label
                        self.calcDirection((firstLabel?.tag)!, sPoint: (secondLabel?.tag)!)
                    }
                    
                    //
                    //  change the selected label color if we dont have 
                    //  two points yet or if the label is ok to select
                    //  (only good labels have a green color)
                    //
                    if secondLabel == nil || label.textColor == availColor {
                        label.textColor = selectedColor
                    }
                }
            }
        }
      
        //
        //  end of pan
        //
        //  process word
        //
        if recognizer.state == .Ended {
          processWord()
        }
    }
    
    //
    //  reset the grid
    //
    func resetGrid() {
        
        lastLabel = nil
        firstLabel = nil
        secondLabel = nil
        
        for label in labels {
            label.textColor = unselectedColor
        }
    }

    //
    //  mark cells in right direction with different color
    //
    func calcDirection(fPoint: Int, sPoint: Int) {
        
        //
        //  see if the two points are on the same row
        //
        //print("points \(fPoint)-\(sPoint)")
        if rowCol(fPoint).row == rowCol(sPoint).row {
            let row = rowCol(fPoint).row
            //print("row \(row)")
            for label in labels {
                if rowCol(label.tag).row == row && label.textColor == unselectedColor {
                    label.textColor = availColor
                }
            }
        }
        
        
        //
        //  see if two points are on the same column
        //
        else if rowCol(fPoint).col == rowCol(sPoint).col {
            let col = rowCol(fPoint).col
            //print("col \(col)")
            for label in labels {
                if rowCol(label.tag).col == col && label.textColor == unselectedColor {
                    label.textColor = availColor
                }
            }
        }

        //
        //  see if the two points are on a diagonal
        //
        else {
            
            let diagDif = abs(fPoint - sPoint)
            print(diagDif)
            
            //
            //  find top of diag
            //
            var point = fPoint
            repeat {
                if point - diagDif < 0 {break}
                if rowCol(point).col == 0 {break}
                if rowCol(point).col == game.width - 1 {break}
                point -= diagDif
            } while true
         
            //
            //  mark each label on the diag
            //
            while point < labels.count {
                let label = labels[point]
                if label.textColor == unselectedColor {
                    label.textColor = availColor
                }
                point += diagDif
                if rowCol(point).col == 0 {point = labels.count}
            }
        }

        
    }
    
    func rowCol(point: Int) -> (row: Int, col: Int) {
        
        let width = Int(game.width)
        let ret = (point / width, point % width)
        
        //print("\(point) +++ \(ret)")
        
        return ret
        
    }
    
    //
    //  see if the selected labels make up a word we know about
    //
    func processWord() {
        
        
        
    }

}
