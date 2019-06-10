//
//  ViewController.swift
//  Project18
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("I'm inside the viewDidLoad() method")
        print(1, 2, 3, 4, 5, separator: "-")
        print("Some message", terminator: "")
        
        // assertions are removed before the app reaches the app store
        assert(1 == 1, "Math failure")

        // will fail
        //assert(1 == 2, "Math failure")

        // assertions can be used to run slow code during development only
        //assert(reallySlowMethod() == true, "The slow method returned false, which is a bad thing")
        
        for i in 1...100 {
            print("Got number \(i)")
        }
    }


}

