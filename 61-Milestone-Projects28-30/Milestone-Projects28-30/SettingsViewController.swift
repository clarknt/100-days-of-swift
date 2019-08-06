//
//  SettingsViewController.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-08-03.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

protocol SettingsDelegate {
    func settings(_ settings: SettingsViewController, didUpdateCards cards: String)
    
    func settings(_ settings: SettingsViewController, didUpdateGrid grid: Int, didUpdateGridElement gridElement: Int)
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var cards: [String]!
    
    let cardsDirectory = "Cards.bundle/"

    var delegate: SettingsDelegate?

    var currentCards: String!
    var currentGrid: Int!
    var currentGridElement: Int!

    @IBOutlet weak var cardsTable: UITableView!
    @IBOutlet weak var gridSizeTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard isParametersSet() else { fatalError("Parameters not provided") }

        navigationItem.largeTitleDisplayMode = .never
        title = "Settings"

        loadCards()
        
        cardsTable.delegate = self
        cardsTable.dataSource = self
        selectCurrentCard()
        
        gridSizeTable.delegate = self
        gridSizeTable.dataSource = self
        selectCurrentGrid()
    }

    func loadCards() {
        let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: cardsDirectory)!
        
        cards = [String]()
        
        for url in urls {
            cards.append(url.lastPathComponent)
        }
        
        cards.sort()
    }
    
    func selectCurrentCard() {
        guard let index = cards.firstIndex(of: currentCards) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        cardsTable.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        cardsTable.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    func selectCurrentGrid() {
        let indexPath = IndexPath(row: currentGridElement, section: currentGrid)
        gridSizeTable.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        gridSizeTable.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    func setParameters(currentCards: String, currentGrid: Int, currentGridElement: Int) {
        self.currentCards = currentCards
        self.currentGrid = currentGrid
        self.currentGridElement = currentGridElement
    }

    func isParametersSet() -> Bool {
        return currentCards != nil && currentGrid != nil && currentGridElement != nil
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == cardsTable {
            return 1
        }

        return grids.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == cardsTable {
            return ""
        }

        return "Cards: \(grids[section].numberOfElements)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cardsTable {
            return cards.count
        }

        return grids[section].combinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == cardsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            cell.textLabel?.text = cards[indexPath.row]
            
            return cell
        }

        let (gridSide1, gridSide2) = grids[indexPath.section].combinations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "\(gridSide1) x \(gridSide2)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cardsTable {
            delegate?.settings(self, didUpdateCards: cards[indexPath.row])
        }
        else {
            delegate?.settings(self, didUpdateGrid: indexPath.section, didUpdateGridElement: indexPath.row)
        }
    }
}
