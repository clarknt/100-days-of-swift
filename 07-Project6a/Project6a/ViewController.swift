//
//  ViewController.swift
//  Project6a
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var currentQuestion = 0
    let maxQuestion = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1

        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score", style: .plain, target: self, action: #selector(scoreTapped))
        
        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        currentQuestion += 1
        
        // end of the game
        if currentQuestion > maxQuestion {
            showResult()
            return
        }

        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)

        
        updateTitle()
    }
    
    fileprivate func showResult() {
        let ac = UIAlertController(title: "End of the game", message: "Questions asked: \(maxQuestion)\nFinal score: \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Restart game", style: .default, handler: askQuestion))

        score = 0
        correctAnswer = 0
        currentQuestion = 0

        present(ac, animated: true)
    }
    
    
    func updateTitle() {
        title = "\(countries[correctAnswer].uppercased())? - Score [\(score)] - \(currentQuestion)/\(maxQuestion)"
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        var message: String
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            message = "Score: \(score)"
        }
        else {
            title = "Wrong"
            score -= 1
            message = """
                You picked: \(countries[sender.tag].uppercased())
                Flag of \(countries[correctAnswer].uppercased()) was: #\(correctAnswer + 1)
                Score: \(score)
                """
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        
        // update title before presenting the alert to have a matching score in the titlebar
        updateTitle()
        present(ac, animated: true)
    }
    
    @objc func scoreTapped() {
        let ac = UIAlertController(title: "Score", message: String(score), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }
}

