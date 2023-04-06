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

    @IBOutlet var thresholdTemperatureTextField: UITextField!
    @IBOutlet var thresholdSoilMostureTextField: UITextField!
    @IBOutlet var thresholdLightTextField: UITextField!

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
                Self.self.workMode = data
                self?.handleAssignValueSwitch(Self.workMode)
            case .failure(let error):
                self?.handleReadDateFailed(error)
            }
        }
    }

    private func handleReadDateFailed(_ error: Error) {
        print(Self.self, #function, error.localizedDescription)
        let cancelAction = UIAlertAction(title: "Đóng", style: .default)

        showAlert(title: "Lấy dữ liệu thất bại", message: "Vui lòng kiểm tra lại đường truyền", actions: [cancelAction])
    }

    private func handleAssignValueSwitch(_ workmode: String) {
        let switches = [buttonControlModeSwitch, appControlModeSwitch, automaticControlModeSwitch]
        for (index, control) in switches.enumerated() {
            control?.isOn = ((index + 1) == Int(workmode) ?? switches.count - 1)
        }
    }
}
