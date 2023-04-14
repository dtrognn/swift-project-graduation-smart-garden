//
//  BulbViewController.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 14/04/2023.
//

import UIKit

class BulbViewController: BaseViewController {
    @IBOutlet var progressBar: ProgressBar!

    @IBOutlet var backgroundTimeoutView: UIView!
    @IBOutlet var timeoutTextField: UITextField!
    @IBOutlet var bulbConfigButton: UIButton!

    var timeLeft: TimeInterval = 0.0
    var initialTime: CGFloat = 0.0
    var timer = Timer()
    var endTime: Date?

    let timePicker = UIDatePicker()
    let doneButton = UIBarButtonItem(title: "Done",
                                     style: .plain,
                                     target: self,
                                     action: #selector(doneButtonTapped))

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTimePicker()
        progressBar.setProgress(progress: 0)
    }

    override func configSubViews() {
        backgroundTimeoutView.roundCorners(with: 15)
        bulbConfigButton.roundCorners(with: bulbConfigButton.frame.size.height / 2)
    }

    @IBAction func touchUpInsideBulbConfigButton(_ sender: Any) {
        if let time = timeoutTextField.text, !time.isEmpty {
            compareTime(inputTime: time)
        } else {
            handTextFieldEmpty()
        }

        initialTime = CGFloat(timeLeft)

        endTime = Date().addingTimeInterval(timeLeft)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    private func compareTime(inputTime: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"

        let now = Date()
        let currentTimeStr = dateFormatter.string(from: now)
        let currentTime = dateFormatter.date(from: currentTimeStr)!

        let inputTimeDate = dateFormatter.date(from: inputTime)!

        if inputTimeDate < currentTime {
            handleInvalidTimeTextField()
        } else {
            timeLeft = getTimeLeft(inputTime)
            writeDataTimer("\(Int(timeLeft))")
        }
    }

    private func handleInvalidTimeTextField() {
        let dismissAction = UIAlertAction(title: "Đóng", style: .default)
        showAlert(title: "Lỗi", message: "Thời gian không hợp lệ", actions: [dismissAction])
    }

    private func handTextFieldEmpty() {
        let dismissAction = UIAlertAction(title: "Đóng", style: .default)
        showAlert(title: "Lỗi", message: "Thời gian không được để trống", actions: [dismissAction])
    }

    private func writeDataTimer(_ timeLeft: String) {
        writeDataToFirebase("timeoutBulb", timeLeft) { [weak self] result in
            switch result {
            case .success:
                self?.handleWriteDataPumpSpeedSuccess()
            case .failure:
                self?.handleWriteDataFailed()
            }
        }
    }

    private func handleWriteDataPumpSpeedSuccess() {
        let dismissAction = UIAlertAction(title: "Đóng", style: .default)
        showAlert(title: "Thiết lập thành công", message: "", actions: [dismissAction])
    }

    private func handleWriteDataFailed() {
        let dismissAction = UIAlertAction(title: "Đóng", style: .default)
        showAlert(title: "Thất bại", message: "Vui lòng kiểm tra lại", actions: [dismissAction])
    }

    @objc func updateTime() {
        if timeLeft > 0 {
            timeLeft = endTime?.timeIntervalSinceNow ?? 0
            let progress = CGFloat(timeLeft) / initialTime
            progressBar.setProgress(progress: progress)
            progressBar.textLayer.string = timeLeft.time
        } else {
            progressBar.textLayer.string = timeLeft.time
            timer.invalidate()
            timeoutTextField.text = ""
        }
    }

    private func getCurrentTime() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    private func getTimeoutTextField(_ textField: UITextField) -> String? {
        if let time = textField.text {
            return time
        }
        return nil
    }

    private func getTimeLeft(_ timeTextField: String) -> TimeInterval {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"

        let startTimeString = getCurrentTime()
        let endTimeString = timeTextField

        guard let startTime = dateFormatter.date(from: startTimeString),
              let endTime = dateFormatter.date(from: endTimeString)
        else {
            print("Invalid time format")
            return 0
        }

        let timeInterval = endTime.timeIntervalSince(startTime)

        return timeInterval
    }

    // handle UIDatePicker for TextField

    private func setupTimePicker() {
        timePicker.datePickerMode = .time
        timePicker.locale = Locale(identifier: "en_GB")

        timeoutTextField.placeholder = "Select Time"
        timeoutTextField.textAlignment = .center
        timeoutTextField.inputView = timePicker
        timeoutTextField.inputAccessoryView = setupToolbar()
        timeoutTextField.tintColor = .clear

        doneButton.tintColor = .blue
    }

    @objc func doneButtonTapped() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timeoutTextField.text = formatter.string(from: timePicker.date)
        timeoutTextField.resignFirstResponder()
    }

    private func setupToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        toolbar.setItems([doneButton], animated: true)
        toolbar.barTintColor = .white
        return toolbar
    }
}
