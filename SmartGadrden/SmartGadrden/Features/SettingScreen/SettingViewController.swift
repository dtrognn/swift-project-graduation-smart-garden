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

    private var workMode: String = "1"

    override func viewDidLoad() {
        super.viewDidLoad()
        configValueDefaultSwitch()
        initDataModeFirebase()

        listenSwitchStatusChanged()
    }

    private func configValueDefaultSwitch() {
        buttonControlModeSwitch.isOn = false
        appControlModeSwitch.isOn = false
        automaticControlModeSwitch.isOn = false
    }

    override func configSubViews() {
        backgroundModeButttonView.roundCorners(with: 20)
        backgroundModeAppView.roundCorners(with: 20)
        backgroundModeAutoView.roundCorners(with: 20)
        backgroundParametersView.roundCorners(with: 20)
    }

    private func initDataModeFirebase() {
        displayIndicator(isShow: true)
        fetchDataFromFirebase(atPath: "CHEDO", dataType: String.self) { [weak self] result in
            self?.displayIndicator(isShow: false)
            switch result {
            case .success(let data):
                self?.workMode = data
                self?.handleAssignValueSwitch(self!.workMode)
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

    // MARK: -

    private func listenSwitchStatusChanged() {
        buttonControlModeSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        appControlModeSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        automaticControlModeSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
    }

    @objc func switchChanged(_ sender: UISwitch) {
        switch sender {
        case buttonControlModeSwitch:
            appControlModeSwitch.isOn = false
            automaticControlModeSwitch.isOn = false

            writeDataToFirebase("CHEDO", "1") { [weak self] result in
                switch result {
                case .success:
                    print(Self.self, #function)
                case .failure(let error):
                    self?.handleWriteDataFailed(error)
                }
            }
        case appControlModeSwitch:
            buttonControlModeSwitch.isOn = false
            automaticControlModeSwitch.isOn = false

            writeDataToFirebase("CHEDO", "2") { [weak self] result in
                switch result {
                case .success:
                    print(Self.self, #function)
                case .failure(let error):
                    self?.handleWriteDataFailed(error)
                }
            }
        default:
            buttonControlModeSwitch.isOn = false
            appControlModeSwitch.isOn = false

            writeDataToFirebase("CHEDO", "3") { [weak self] result in
                switch result {
                case .success:
                    print(Self.self, #function)
                case .failure(let error):
                    self?.handleWriteDataFailed(error)
                }
            }
        }
    }

    private func handleWriteDataSuccessed(_ mode: Any) {
        let cancelAction = UIAlertAction(title: "Đóng", style: .default)

        showAlert(title: "Thông báo", message: "Chuyển chế độ \(mode) thành công", actions: [cancelAction])
    }

    private func handleWriteDataFailed(_ error: Error) {
        print(Self.self, #function, error.localizedDescription)

        let cancelAction = UIAlertAction(title: "Đóng", style: .destructive)

        showAlert(title: "Thông báo", message: "Chuyển chế độ thất bại", actions: [cancelAction])
    }
}
