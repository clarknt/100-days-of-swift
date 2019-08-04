//
//  ViewController.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-07-23.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class GameViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var cards = [Card]()
    var flippedCards = [(position: Int, card: Card)]()
    var removeFlippedCardsTask: DispatchWorkItem!
    var backImageSize: CGSize!
    var cardSize: CardSize!
    
    var combinations = [
        (1, 4),  (2, 2),  //   4
        (1, 6),  (2, 3),  //   6
        (1, 8),  (2, 4),  //   8
        (1, 10), (2, 5),  //  10
        (2, 6),  (3, 4),  //  12
        (2, 7),           //  14
        (2, 8),  (4, 4),  //  16
        (2, 9),  (3, 6),  //  18
        (2, 10), (4, 5),  //  20
        (3, 8),  (4, 6),  //  24
        (4, 7),           //  28
        (3, 10), (6, 5),  //  30
        (4, 8),           //  32
        (4, 9),  (6, 6),  //  36
        (4, 10), (5, 8),  //  40
        (6, 7),           //  42
        (6, 8),           //  48
        (5, 10),          //  50
        (6, 9),  (7, 8),  //  54
        (6, 10),          //  60
        (8, 8),           //  64
        (7, 10),          //  70
        (8, 9),           //  72
        (8, 10),          //  80
        (9, 10),          //  90
        (10, 10)          // 100
    ]
    var currentCombination = 0
    
    var gridSide1 = 3
    var gridSide2 = 4
    
    let cardsDirectory = "Cards.bundle/"
    var currentCards = "LastGuardian"

//    var combinationButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Match Pairs"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New game", style: .plain, target: self, action: #selector(newGame))

//        combinationButtonItem = UIBarButtonItem(title: "\(gridSide1), \(gridSide2)", style: .plain, target: self, action: #selector(settings))
//        navigationItem.rightBarButtonItem = combinationButtonItem

        // some iPads don't automatically refresh the collection view when rotated
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main, using: didRotate)
        
        // values will be overriden later
        cardSize = CardSize(imageSize: CGSize(width: 50, height: 50), gridSide1: gridSide1, gridSide2: gridSide2)
        
        newGame()
    }

    @objc func newGame() {
        guard (gridSide1 * gridSide2) % 2 == 0 else {
            fatalError("Odd number of cards")
        }
        
        cards = [Card]()
        resetFlippedCards()
        
        loadCards()

        collectionView.reloadData()
    }
    
    func resetFlippedCards() {
        removeFlippedCardsTask?.cancel()

        removeFlippedCardsTask = DispatchWorkItem { [weak self] in
            self?.flippedCards.removeAll(keepingCapacity: true)
        }

        flippedCards.removeAll(keepingCapacity: true)
    }
    
//    @objc func settings() {
//        currentCombination += 1
//        if currentCombination >= combinations.count {
//            currentCombination = 0
//        }
//
//        (gridSide1, gridSide2) = combinations[currentCombination]
//        combinationButtonItem.title = "\(gridSide1), \(gridSide2)"
//        cardSize.gridSide1 = gridSide1
//        cardSize.gridSide2 = gridSide2
//
//        newGame()
//    }
    
    func loadCards() {
        var backImage: String? = nil
        var frontImages = [String]()
        
        let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: cardsDirectory + currentCards)!
        
        for url in urls {
            if url.lastPathComponent.starts(with: "back.") {
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

        let cardsNumber = gridSide1 * gridSide2
        
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
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cardSize.getCardSize(collectionView: collectionView)
    }
}
