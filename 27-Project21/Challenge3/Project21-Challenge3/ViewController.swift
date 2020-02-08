//
//  ViewController.swift
//  Project21-Challenge3
//

// project 21 challenge 3
import UserNotifications
import UIKit

// project 21 challenge 3
class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    
    // project 12 challenge 2
    var highestScore = -11
    var highestScoreKey = "HighestScore"
    
    var correctAnswer = 0
    var currentQuestion = 0
    
    // challenge 2
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

        // project 3 challenge 3
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score", style: .plain, target: self, action: #selector(scoreTapped))
        
        // project 12 challenge 2
        let userDefaults = UserDefaults.standard
        highestScore = userDefaults.object(forKey: highestScoreKey) as? Int ?? -11
        
        // project 21 challenge 3
        manageNotifications()
        
        askQuestion()
    }

    // project 21 challenge 3
    func manageNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { [weak self] (settings) in
            
            // user has not made a choice yet regarding accepting notifications
            if settings.authorizationStatus == .notDetermined {
                // use this opportunity to explain why it could be useful
                let ac = UIAlertController(title: "Daily reminder", message: "Allow notifications to be reminded daily of playing Guess the Flag", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Next", style: .default) { _ in
                    self?.requestNotificationsAuthorization()
                })
                self?.present(ac, animated: true)
                return
            }

            // user already has accepted notifications
            if settings.authorizationStatus == .authorized {
                self?.scheduleNotifications()
            }
        }
    }
    
    // project 21 challenge 3
    func requestNotificationsAuthorization() {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            if granted {
                self?.scheduleNotifications()
            }
            else {
                // explain how notifications can be activated
                let ac = UIAlertController(title: "Notifications", message: "Your choice has been saved.\nShould you change your mind, head to \"Settings -> Project21-Challenge3 -> Notifications\" to update your preferences.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(ac, animated: true)
            }
        }

    }
    
    // project 21 challenge 3
    func scheduleNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        // cancel future scheduled notifications, to start over
        notificationCenter.removeAllPendingNotificationRequests()
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Daily reminder"
        notificationContent.body = "Play your daily Guess the Flag game"
        notificationContent.categoryIdentifier = "reminder"
        notificationContent.sound = .default
        
        // goal is to send notifications once a day for 7 days after the latest app launch
        let secondsPerDay: TimeInterval = 3600 * 24
        for day in 1...7 {
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsPerDay * Double(day), repeats: false)
            let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: notificationTrigger)
            notificationCenter.add(notificationRequest)
        }
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        currentQuestion += 1
        
        // challenge 2
        if currentQuestion > maxQuestion {
            showResult()
            return
        }

        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)

        // challenge 1
        updateTitle()
    }
    
    // challenge 2
    func showResult() {
        var message = "Questions asked: \(maxQuestion)\nFinal score: \(score)"
        
        // project 12 challenge 2
        var mustSaveHighestScore = false
        if score > highestScore {
            message += "\n\nNEW HIGH SCORE!\nPrevious high score: \(highestScore)"
            highestScore = score
            mustSaveHighestScore = true
        }
        
        let ac = UIAlertController(title: "End of the game", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Restart game", style: .default, handler: askQuestion))

        score = 0
        correctAnswer = 0
        currentQuestion = 0

        present(ac, animated: true)
        
        // project 12 challenge 2
        if mustSaveHighestScore {
            performSelector(inBackground: #selector(saveHighestScore), with: nil)
        }
    }
    
    // challenge 1
    func updateTitle() {
        title = "\(countries[correctAnswer].uppercased())? - Score [\(score)] - \(currentQuestion)/\(maxQuestion)"
    }
    
    // project 12 challenge 2
    @objc func saveHighestScore() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(highestScore, forKey: highestScoreKey)
    }

    // Project 15 challenge 3
    @IBAction func buttonTouched(_ sender: UIButton) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        // Project 15 challenge 3
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: [], animations: {
            sender.transform = .identity
        })

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
            
            // challenge 3
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
    
    // project 3 challenge 3
    @objc func scoreTapped() {
        let ac = UIAlertController(title: "Score", message: String(score), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }
}

