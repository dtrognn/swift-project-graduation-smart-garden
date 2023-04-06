//
//  SplashViewController.swift
//  SmartGarden
//
//  Created by Vu Duc Trong on 27/03/2023.
//

import UIKit

class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.performSegue(withIdentifier: "\(Self.self)", sender: nil)
        }
    }
}
