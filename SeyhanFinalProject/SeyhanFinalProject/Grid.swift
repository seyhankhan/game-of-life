//
//  Grid.swift
//  Lecture07
//
//  Created by Van Simmons on 7/10/19.
//  Copyright © 2019 ComputeCycles, LLC. All rights reserved.
//
import Foundation

typealias Position     = (row: Int, col: Int)
typealias Offset       = (offsetRow: Int, offsetCol: Int)
typealias GridSize     = (rows: Int, cols: Int)
typealias GridPosition = (position: Position, size: GridSize)

enum GridError: Error {
    case mismatch
}

enum CellState {
    case empty, alive, born, died
    
    var isAlive: Bool {
        switch self {
        case .born, .alive: return true
        case .died, .empty: return false
        }
    }
}

// map any value (positive or negative into the interval [0, size-1]
func norm(_ val: Int, to size: Int) -> Int { return ((val % size) + size) % size }

func +(_ p: GridPosition, _ o: Offset) -> Position {
    return (norm(p.position.row + o.offsetRow, to: p.size.rows),
            norm(p.position.col + o.offsetCol, to: p.size.cols))
}

fileprivate let offsets: [Offset] = [
    (offsetRow: -1, offsetCol: -1), (offsetRow: -1, offsetCol: 0), (offsetRow: -1, offsetCol: 1),
    (offsetRow:  0, offsetCol: -1),                                (offsetRow:  0, offsetCol: 1),
    (offsetRow:  1, offsetCol: -1), (offsetRow:  1, offsetCol: 0), (offsetRow:  1, offsetCol: 1)
]


struct Grid: GridDataSource {
    let size: GridSize
    var cellStates: [[CellState]]
    
    init(_ size: GridSize = (10, 10), _ cellInitializer: (Int, Int) -> CellState = { _,_ in .empty } ) {
        self.size = size
        cellStates = (0 ..< size.rows).map { row in (0 ..< size.cols).map { col in cellInitializer(row, col) } }
    }
    
    func neighbors(of position: Position) -> [Position] {
        return offsets.map { (position, size) + $0 }
    }
    
    func livingNeighbors(of position: Position) -> [Position] {
        return neighbors(of: position).filter { cellStates[$0.row][$0.col].isAlive }
    }
    
    func nextState(of position: Position) -> CellState {
        let currentlyAlive = cellStates[position.row][position.col].isAlive
        switch livingNeighbors(of: position).count {
        case 3,
             2 where currentlyAlive: return currentlyAlive ? .alive : .born
        default: return currentlyAlive ? .died : .empty
        }
    }
    
    var next: Grid { return Grid(size) { nextState(of: ($0, $1)) } }
}

extension Grid {
    var allPositions: [Position] {
        return (0 ..< size.rows).flatMap { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
    }
    
    var living:    [Position] { return allPositions.filter { cellStates[$0.row][$0.col].isAlive   } }
    var notLiving: [Position] { return allPositions.filter { !cellStates[$0.row][$0.col].isAlive  } }
    var alive:     [Position] { return allPositions.filter { cellStates[$0.row][$0.col] == .alive } }
    var born:      [Position] { return allPositions.filter { cellStates[$0.row][$0.col] == .born  } }
    var died:      [Position] { return allPositions.filter { cellStates[$0.row][$0.col] == .died  } }
    var empty:     [Position] { return allPositions.filter { cellStates[$0.row][$0.col] == .empty } }
}

extension Grid: Hashable {
    static func == (lhs: Grid, rhs: Grid) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        return try! withUnsafeBytes(of: self) { Result<Void,Never>.success(hasher.combine(bytes: $0)) }.get()
    }
}

protocol EngineDelegate {
    func engine(didUpdate: Engine) -> Void
//    func engine(didUpdateTimerFired: Engine) -> Void
}

let EngineNoticationName = Notification.Name(rawValue: "EngineUpdate")

class Engine: GridDataSource {
    static var sharedEngineInstance = Engine()
    
    var grid: Grid {
        didSet {
            delegate?.engine(didUpdate: self)
        }
    }
    var timer: Timer?
    var delegate: EngineDelegate?
//    var timerFired: ((Engine) -> Void)? {
//        didSet {
//            delegate?.engine(didUpdateTimerFired: self)
//        }
//    }
//    var refreshPeriod: Double = 0.0 {
//        didSet {
//            timer?.invalidate()
//            if refreshPeriod > 0.0 {
//                timer = Timer.scheduledTimer(
//                    withTimeInterval: refreshPeriod,
//                    repeats: true) { (t) in
//                        self.grid = self.grid.next
//                        // self.timerFired?(self)
//                        //self.delegate?.engine(didUpdate: self)
//                        let nc = NotificationCenter.default
//                        let info = ["engine": self]
//                        nc.post(name: EngineNoticationName, object: nil, userInfo:info)
//                }
//            } else {
//                timer = nil
//            }
//        }
//    }
    
    init(grid: Grid = Grid() ) {
        self.grid = grid
    }
    
    var size: GridSize { return grid.size }
    var allPositions: [Position] { return grid.allPositions }
    var cellStates: [[CellState]] {
        get { return grid.cellStates }
        set { grid.cellStates = newValue }
    }
}
