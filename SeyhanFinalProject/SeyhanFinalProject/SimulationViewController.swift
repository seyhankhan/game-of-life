//
//  SecondViewController.swift
//  Lecture12
//
//  Created by Van Simmons on 7/31/19.
//  Copyright © 2019 ComputeCycles, LLC. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridDataSource, UITextFieldDelegate, EngineDelegate {
    var engine = Engine.sharedEngineInstance
    
    var size: GridSize { return engine.grid.size }
    var allPositions: [Position] { return engine.grid.allPositions }
    var cellStates: [[CellState]] {
        get { return engine.grid.cellStates }
        set { engine.grid.cellStates = newValue }
    }
    
    func engine(didUpdate: Engine) {
        self.gridView.setNeedsDisplay()
    }
    
    
    @IBOutlet weak var Step: UIButton!
    @IBOutlet weak var Minus: UIButton!
    @IBOutlet weak var Plus: UIButton!
    @IBOutlet weak var gridView: GridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gridView.dataSource = self
//        engine.timerFired = { engine in
//            self.gridView.setNeedsDisplay()
//        }
        engine.delegate = self
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(engine(notified:)), name: EngineNoticationName, object: nil)
        
//        engine.refreshPeriod = 0.0
    }
    
    @objc func engine(notified: Notification) {
        gridView.setNeedsDisplay()
    }
    
    @IBAction func step(_ sender: Any) {
        engine.grid = engine.grid.next
        gridView.setNeedsDisplay()
    }
    
    @IBAction func plus(_ sender: Any) {
        Minus.isEnabled = true
        let size = (rows: engine.size.rows + 1, cols: engine.size.cols + 1)
        engine.grid = Grid(size)
        gridView.setNeedsDisplay()
        if engine.size.rows >= 20 {
            Plus.isEnabled = false
        }
    }
    
    @IBAction func minus(_ sender: Any) {
        Plus.isEnabled = true
        let size = (rows: engine.size.rows - 1, cols: engine.size.cols - 1)
        engine.grid = Grid(size)
        gridView.setNeedsDisplay()
        if engine.size.rows <= 6 {
            Minus.isEnabled = false
        }
    }


}

