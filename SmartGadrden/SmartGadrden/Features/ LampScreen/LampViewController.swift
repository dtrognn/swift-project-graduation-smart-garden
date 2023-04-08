//
//  LampViewController.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 08/04/2023.
//

import UIKit

class LampViewController: BaseViewController {

    @IBOutlet weak var backgroundTimeStartView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundTimeStartView.border(width: 1, color: .lightGray)
        backgroundTimeStartView.roundCorners(with: 20)
    }

}
