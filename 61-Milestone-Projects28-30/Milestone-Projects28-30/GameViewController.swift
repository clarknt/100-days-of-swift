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
    
    // too high values will have spacing between cells becoming larger than screen
    // exemple on iPhone XS, limit is around 60x30 (values unplayable anyway)
    let cardsLongNumber = 4
    let cardsShortNumber = 3
    
    let cardsDirectory = "Cards.bundle/"
    let currentCards = "Blocks"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Match Pairs"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New game", style: .plain, target: self, action: #selector(newGame))

//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settings))

        // some iPads don't automatically refresh the collection view when rotated
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main, using: didRotate)
        
        newGame()
    }

    @objc func newGame() {
        guard (cardsLongNumber * cardsShortNumber) % 2 == 0 else {
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
//
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
        
        // no back card image found
        guard backImage != nil else { fatalError("No back image found") }

        let cardsNumber = cardsLongNumber * cardsShortNumber
        
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
        return getCardSize(collectionView: collectionView)
    }
    
    func getCardSize(collectionView: UICollectionView) -> CGSize {
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height

        let layoutMargins = collectionView.layoutMargins
        let leftRightMargin = layoutMargins.left + layoutMargins.right
        let topBottomMargin = layoutMargins.top + layoutMargins.bottom
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let minInterimSpacing = layout?.minimumInteritemSpacing ?? 0
        let minLineSpacing = layout?.minimumLineSpacing ?? 0
        
        var widthCardNumber: CGFloat
        var heightCardNumber: CGFloat

        // portrait
        if height > width {
            widthCardNumber = CGFloat(cardsShortNumber)
            heightCardNumber = CGFloat(cardsLongNumber)
        }
        // landscape
        else {
            widthCardNumber = CGFloat(cardsLongNumber)
            heightCardNumber = CGFloat(cardsShortNumber)
        }
        
        let availableWidth = width - leftRightMargin - minInterimSpacing * (widthCardNumber - 1)
        let availableHeight = height - topBottomMargin - minLineSpacing * (heightCardNumber - 1)
        
        guard availableWidth > widthCardNumber && availableHeight > heightCardNumber else {
            fatalError("Too many cards to display")
        }
        
        let cardWidth = availableWidth / widthCardNumber
        let cardHeight = availableHeight / heightCardNumber

        return CGSize(width: cardWidth, height: cardHeight)
    }
}
