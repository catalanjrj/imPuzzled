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
        
        let tbvc = self.tabBarController as! PlayGameTabViewController
        game = tbvc.game
        
        buildLabels()

        
    }

    //
    //  build all the labels for the game
    //
    func buildLabels() {
        
        let chars = game.characters as! [String]
        var index = 0;
        
        let sidePadding = 40.0
        let topPadding = 80.0
        let swidth = Double(self.view.frame.size.width)
        let gwidth = Double(game.width)
        let size = (swidth - sidePadding * 2) / gwidth
        
        for row:Int in 0...game.height-1 {
            for col:Int in 0...game.width-1 {
                let label = UILabel(frame: CGRectMake(CGFloat(Double(col) * size + sidePadding),
                    CGFloat(Double(row) * size + topPadding),
                    30, 30))
                label.userInteractionEnabled = true
                label.text = chars[index]
                label.tag = index
                label.textAlignment = .Center
                label.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.1)
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
                    if (secondLabel == nil || label.textColor == availColor)
                    && label.textColor != wordColor {
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
        
        let attr:[String] = game.charactersAttr as! [String]
        for label in labels {
            if attr[label.tag] == "X" {
                label.textColor = wordColor
                label.font = UIFont.boldSystemFontOfSize(16.0)
            }
            else {
                label.textColor = unselectedColor
            }
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
            
            //
            //  find top of diag
            //
            var point = fPoint
            repeat {
                if point - diagDif < 0 {break}
                point -= diagDif
                if rowCol(point).col == 0 {break}
                if rowCol(point).col == game.width - 1 {break}
            } while true
          
            //
            //  mark each label on the diag
            //
            var marks = 0
            while point < labels.count {
                let label = labels[point]
                if label.textColor == unselectedColor {
                    label.textColor = availColor
                    marks += 1
                }
                if marks > 1 {
                    if rowCol(point).col == 0 {break}
                    if rowCol(point).col == game.width-1 {break}
                }
                point += diagDif
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
        
        //
        //  build word from selected labels
        //
        var pickedWord = ""
        for label in labels {
            if label.textColor == selectedColor {
                pickedWord += label.text!
            }
        }
        
        //
        //  see if word is in list of available words
        //
        
        var words:[[String: AnyObject]] = game.words as! [[String: AnyObject]]
        
        //
        // try and find word in the dictionary
        //
        for var word in words {
            if let fword:String = word["word"] as? String {
                if fword == pickedWord || fword == String(pickedWord.characters.reverse()) {
                    
                    for index in 0...words.count-1 {
                        if words[index]["word"] as? String == fword {
                            words[index]["found"] = true as Bool
                        }
                    }
        
                    game.foundWordCount += 1
                    
                    //
                    //  mark each selected cell as used
                    //
                    var attr:[String] = game.charactersAttr as! [String]
                    for label in labels {
                        if label.textColor == selectedColor {
                            attr[label.tag] = "X"
                            shakeAnimation(label)
                        }
                    }
                    game.charactersAttr = attr
                    game.words = words

                    resetGrid()
                    
                    game.doSave()
                    
                    break
                }
            }
        }
        
    }
    
    //
    //  create a shake gesture
    //
    func shakeAnimation (label: UILabel) {
        
        let shake = CABasicAnimation(keyPath:"position")
        shake.duration = 0.1
        shake.repeatCount = 5
        shake.autoreverses = true
        shake.fromValue = NSValue(CGPoint:CGPointMake(label.center.x - 5, label.center.y))
        shake.toValue = NSValue(CGPoint:CGPointMake(label.center.x + 5, label.center.y))
        label.layer.addAnimation(shake, forKey: "position")
        
    }
    
    
    //
    //  user rotated so we need to redraw the screen
    //
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
     
        view.subviews.forEach { $0.removeFromSuperview() }
        
        buildLabels()
        
    }

}
