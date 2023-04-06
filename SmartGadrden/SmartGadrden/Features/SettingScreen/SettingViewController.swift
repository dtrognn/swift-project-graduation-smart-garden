//
//  SettingViewController.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 06/04/2023.
//

import UIKit

class SettingViewController: BaseViewController {
    @IBOutlet var backgroundModeButttonView: UIView!
    @IBOutlet var backgroundModeAppView: UIView!
    @IBOutlet var backgroundModeAutoView: UIView!
    @IBOutlet var backgroundParametersView: UIView!

    @IBOutlet var buttonControlModeSwitch: UISwitch!
    @IBOutlet var appControlModeSwitch: UISwitch!
    @IBOutlet var automaticControlModeSwitch: UISwitch!

    @IBOutlet weak var thresholdTemperatureTextField: UITextField!
    @IBOutlet weak var thresholdSoilMostureTextField: UITextField!
    @IBOutlet weak var thresholdLightTextField: UITextField!

    static var workMode: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        initDataModeFirebase()
    }

    override func configSubViews() {
        backgroundModeButttonView.roundCorners(with: 20)
        backgroundModeAppView.roundCorners(with: 20)
        backgroundModeAutoView.roundCorners(with: 20)
        backgroundParametersView.roundCorners(with: 20)
    }

    private func initDataModeFirebase() {
        fetchDataFromFirebase(atPath: "CHEDO", dataType: String.self) { [weak self] result in
            switch result {
            case .success(let data):
                print(data)
                Self.workMode = data
                self?.handleWorkModeSwitch(Self.workMode)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    private func handleWorkModeSwitch(_ workmode: String) {
        switch workmode {
        case "1":
            buttonControlModeSwitch.isOn = true
            appControlModeSwitch.isOn = false
            automaticControlModeSwitch.isOn = false
        case "2":
            buttonControlModeSwitch.isOn = false
            appControlModeSwitch.isOn = true
            automaticControlModeSwitch.isOn = false
        default:
            buttonControlModeSwitch.isOn = false
            appControlModeSwitch.isOn = false
            automaticControlModeSwitch.isOn = true
        }
    }
}
