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

    @IBOutlet var thresholdAboveTempTextField: UITextField!
    @IBOutlet var thresholdBelowTempTextField: UITextField!
    @IBOutlet var thresholdAboveSoilMostureTextField: UITextField!
    @IBOutlet var thresholdBelowSoilMostureTextField: UITextField!
    @IBOutlet var thresholdAboveLightTextField: UITextField!
    @IBOutlet var thresholdBelowLightTextField: UITextField!

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
        backgroundModeButttonView.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 0.94, alpha: 1.00)
        backgroundModeAppView.roundCorners(with: 20)
        backgroundModeAppView.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 0.94, alpha: 1.00)
        backgroundModeAutoView.roundCorners(with: 20)
        backgroundModeAutoView.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 0.94, alpha: 1.00)
        backgroundParametersView.roundCorners(with: 20)
        backgroundParametersView.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 0.94, alpha: 1.00)
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

            if !checkTextFieldsEmpty() {
                writeDataToFirebase("CHEDO", "3") { [weak self] result in
                    switch result {
                    case .success:
                        self?.writeThresholdTempData()
                        self?.writeThresholdSoilMostureData()
                        self?.writeThresholdLightData()
                    case .failure(let error):
                        self?.handleWriteDataFailed(error)
                    }
                }
            } else {
                handleInvalidTextField()
                initDataModeFirebase()
            }
        }
    }

    private func handleWriteDataFailed(_ error: Error) {
        print(Self.self, #function, error.localizedDescription)

        let cancelAction = UIAlertAction(title: "Đóng", style: .destructive)

        showAlert(title: "Thông báo", message: "Chuyển chế độ thất bại", actions: [cancelAction])
    }

    // handle case read data textfield

    private func checkTextFieldsEmpty() -> Bool {
        if automaticControlModeSwitch.isOn {
            let textFields = [thresholdAboveTempTextField,
                              thresholdBelowTempTextField,
                              thresholdAboveSoilMostureTextField,
                              thresholdBelowSoilMostureTextField,
                              thresholdAboveLightTextField,
                              thresholdBelowLightTextField]
            for textField in textFields {
                if textField?.text == nil || textField?.text == "" {
                    return true
                }
            }
        }
        return false
    }

    private func writeThresholdTempData() {
        guard let above = thresholdAboveTempTextField.text,
              let below = thresholdBelowTempTextField.text else { return }

        let aboveTemp = String(format: "%02d", Int(above) ?? 0)
        let belowTemp = String(format: "%02d", Int(below) ?? 0)

        let thresholdSoilTemp = aboveTemp + belowTemp

        writeDataToFirebase("thresholdTemp", thresholdSoilTemp) { [weak self] result in
            switch result {
            case .success:
                print(Self.self)
            case .failure(let error):
                self?.handleWriteDataFailed(error)
            }
        }
    }

    private func writeThresholdSoilMostureData() {
        guard let above = thresholdAboveSoilMostureTextField.text,
              let below = thresholdBelowSoilMostureTextField.text else { return }

        let aboveSoilMoisture = String(format: "%02d", Int(above) ?? 0)
        let belowSoilMoisture = String(format: "%02d", Int(below) ?? 0)

        let thresholdSoilMoisture = aboveSoilMoisture + belowSoilMoisture

        writeDataToFirebase("thresholdSoilMosture", thresholdSoilMoisture) { [weak self] result in
            switch result {
            case .success:
                print(Self.self)
            case .failure(let error):
                self?.handleWriteDataFailed(error)
            }
        }
    }

    private func writeThresholdLightData() {
        guard let above = thresholdAboveLightTextField.text,
              let below = thresholdBelowLightTextField.text else { return }

        let aboveLight = String(format: "%02d", Int(above) ?? 0)
        let belowLight = String(format: "%02d", Int(below) ?? 0)

        let thresholdLight = aboveLight + belowLight

        writeDataToFirebase("thresholdLight", thresholdLight) { [weak self] result in
            switch result {
            case .success:
                print(Self.self)
            case .failure(let error):
                self?.handleWriteDataFailed(error)
            }
        }
    }

    private func handleInvalidTextField() {
        let dismissAction = UIAlertAction(title: "Đóng", style: .default)
        showAlert(title: "Lỗi", message: "Các thông số ngưỡng không được để trống", actions: [dismissAction])
    }
}
