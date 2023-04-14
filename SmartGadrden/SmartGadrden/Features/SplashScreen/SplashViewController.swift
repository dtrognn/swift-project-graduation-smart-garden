//
//  SplashViewController.swift
//  SmartGarden
//
//  Created by Vu Duc Trong on 27/03/2023.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 200) {
            self.performSegue(withIdentifier: "\(Self.self)", sender: nil)
        }

        updateTimeLabel()
        updateDateLabel()

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateTimeLabel()
            self.updateDateLabel()
        }
    }

    private func updateTimeLabel() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: date)
        timeLabel.text = dateString
    }

    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: Date())
    }
}
