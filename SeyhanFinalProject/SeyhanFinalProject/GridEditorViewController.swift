//
//  GridEditorViewController.swift
//  Lecture12
//
//  Created by Van Simmons on 7/31/19.
//  Copyright © 2019 ComputeCycles, LLC. All rights reserved.
//

import UIKit
typealias ConfigurationCallback = (Configuration) -> Void
class GridEditorViewController: UIViewController {

    @IBOutlet weak var gridView: GridView!
    var size: GridSize = (10,10)
    var config: Configuration! {
        didSet {
            let max = config.contents?.flatMap{ $0 }.max() ?? 5
            size = (max * 2, max * 2)
        }
    }
    var callback: ConfigurationCallback?
    var engine: Engine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var grid = Grid(size)
        config.contents?.forEach { grid.cellStates[$0[0]][$0[1]] = .alive }
        engine = Engine(grid: grid)
        gridView.dataSource = engine

        let c = Configuration(
            title: "SimulationViewControllerDefaultTitle",
            contents: grid.allPositions.filter { grid.cellStates[$0.row][$0.col].isAlive }.map { [$0.row, $0.col] }
        )
        let save = try! JSONEncoder().encode(c)
        UserDefaults.standard.set(save, forKey: "Configuration")
        
        guard let restore = UserDefaults.standard.value(forKey: "Configuration") as? Data else { return }
        let restoredConfig = try! JSONDecoder().decode(Configuration.self, from: restore)
        let restoredSize = restoredConfig.contents?.flatMap{ $0 }.max() ?? 5
        let restoredGridSize = (restoredSize * 2, restoredSize * 2)
        var restoredGrid = Grid(restoredGridSize)
        restoredConfig.contents?.forEach { restoredGrid.cellStates[$0[0]][$0[1]] = .alive }
    }
    
    @IBAction func save(_ sender: Any) {
        Engine.sharedEngineInstance.grid = engine.grid
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
