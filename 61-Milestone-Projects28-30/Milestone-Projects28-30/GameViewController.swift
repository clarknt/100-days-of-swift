//
//  ViewController.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-07-23.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class GameViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SettingsDelegate {
    var cards = [Card]()
    var flippedCards = [(position: Int, card: Card)]()
    var removeFlippedCardsTask: DispatchWorkItem!
    var backImageSize: CGSize!
    var cardSize: CardSize!
    
    var grids = Grids()
    var currentGrid = 4
    var currentGridElement = 1
    
    let cardsDirectory = "Cards.bundle/"
    var currentCards = "LastGuardian"

    var currentCardSizeValid = false
    var currentCardSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Match Pairs"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New game", style: .plain, target: self, action: #selector(newGame))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsTapped))

        // some iPads don't automatically refresh the collection view when rotated
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main, using: didRotate)
        
        let (n1, n2) = grids.grids[currentGrid].combinations[currentGridElement]
        // values will be overriden later
        cardSize = CardSize(imageSize: CGSize(width: 50, height: 50), gridSide1: n1, gridSide2: n2)
        
        newGame()
    }
    
    @objc func newGame() {
        let (n1, n2) = grids.grids[currentGrid].combinations[currentGridElement]

        guard (n1 * n2) % 2 == 0 else {
            fatalError("Odd number of cards")
        }
        
        cardSize.gridSide1 = n1
        cardSize.gridSide2 = n2

        cards = [Card]()
        resetFlippedCards()
        
        loadCards()

        currentCardSizeValid = false
        collectionView.reloadData()
    }
    
    func resetFlippedCards() {
        removeFlippedCardsTask?.cancel()

        removeFlippedCardsTask = DispatchWorkItem { [weak self] in
            self?.flippedCards.removeAll(keepingCapacity: true)
        }

        flippedCards.removeAll(keepingCapacity: true)
    }
    
    @objc func settingsTapped() {
        if let settings = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            settings.setParameters(currentCards: currentCards, currentGrid: currentGrid, currentGridElement: currentGridElement)
            settings.delegate = self
            navigationController?.pushViewController(settings, animated: true)
        }
    }
    
    func loadCards() {
        var backImage: String? = nil
        var frontImages = [String]()

        let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: cardsDirectory + currentCards)!
        
        for url in urls {
            // convention: unique names to avoid caching issue
            // and starting with 1 for sorting
            if url.lastPathComponent.starts(with: "1\(currentCards)_back.") {
                backImage = url.path
            }
            else {
                frontImages.append(url.path)
            }
        }
        
        // get image size
        guard backImage != nil else { fatalError("No back image found") }
        guard let size = UIImage(named: backImage!)?.size else { fatalError("Cannot get image size") }
        cardSize.imageSize = size

        let (n1, n2) = grids.grids[currentGrid].combinations[currentGridElement]
        let cardsNumber = n1 * n2
        
        // more images than required grid
        while frontImages.count > cardsNumber / 2 {
            frontImages.remove(at: Int.random(in: 0..<frontImages.count))
        }
        // not enough images to fill grid
        while frontImages.count < cardsNumber / 2 {
            frontImages.append(frontImages[Int.random(in: 0..<frontImages.count)])
        }
        
        // duplicate all images to make pairs
        frontImages += frontImages
        // shuffle images
        frontImages.shuffle()

        for i in 0..<cardsNumber {
            cards.append(Card(frontImage: frontImages[i], backImage: backImage!))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        guard let cell = dequeuedCell as? CardCell else { return dequeuedCell }

        cell.set(card: cards[indexPath.row])

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return }

        guard flippedCards.count < 2 else { return }
        guard cards[indexPath.row].state == .back else { return }

        cards[indexPath.row].state = .front
        cell.animateFlipTo(state: .front)
        flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))
        
        if flippedCards.count == 2 {
            if flippedCards[0].card.frontImage == flippedCards[1].card.frontImage {
                matchingCards()
            }
            else {
                unmatchingCards()
            }
        }
    }
    
    func matchingCards() {
        for (position, card) in flippedCards {
            card.state = .matched

            let indexPath = IndexPath(item: position, section: 0);
            if let cell = collectionView.cellForItem(at: indexPath) as? CardCell {
                cell.animateMatch()
            }
        }
        flippedCards.removeAll(keepingCapacity: true)
        
        checkCompletion()
    }
    
    func checkCompletion() {
        for card in cards {
            if card.state != .matched && card.state != .complete {
                return
            }
        }
        
        // all cards complete
        for card in cards {
            card.state = .complete
        }
        
        animateCompletion()
    }
    
    func animateCompletion() {
        var delay: TimeInterval = 0

        for i in 0..<cards.count {
            let indexPath = IndexPath(item: i, section: 0);
            if let cell = collectionView.cellForItem(at: indexPath) as? CardCell {
                cell.animateCompleteGame(delay: delay)
            }

            // 50ms to start animating each card with a delay
            delay += 0.05
        }
    }
    
    func unmatchingCards() {
        for (position, card) in flippedCards {
            if card.state == .front {
                card.state = .back
                
                let indexPath = IndexPath(item: position, section: 0);
                if let cell = collectionView.cellForItem(at: indexPath) as? CardCell {
                    // give the player 1 second to look at the cards
                    cell.animateFlipTo(state: .back, delay: 1)
                }
            }
        }
        // wait for card to turn back before allowing the player to select another one
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: removeFlippedCardsTask)
    }
    
    func didRotate(_: Notification) -> Void {
        currentCardSizeValid = false
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentCardSizeValid {
            return currentCardSize
        }
        
        currentCardSize = cardSize.getCardSize(collectionView: collectionView)
        currentCardSizeValid = true
        return currentCardSize
    }
    
    func settings(_ settings: SettingsViewController, didUpdateCards cards: String) {
        currentCards = cards
        newGame()
    }
    
    func settings(_ settings: SettingsViewController, didUpdateGrid grid: Int, didUpdateGridElement gridElement: Int) {
        currentGrid = grid
        currentGridElement = gridElement
        newGame()
    }
}
