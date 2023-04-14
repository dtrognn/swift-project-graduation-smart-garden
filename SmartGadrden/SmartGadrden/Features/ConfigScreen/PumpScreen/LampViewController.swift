//
//  LampViewController.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 08/04/2023.
//

import UIKit

class LampViewController: BaseViewController {
    @IBOutlet var progressBar: ProgressBar!

    @IBOutlet var backgroundTimeoutView: UIView!
    @IBOutlet var backgroundSliderView: UIView!
    @IBOutlet var timeoutTextField: UITextField!
    @IBOutlet var pumpModeSlider: UISlider!
    @IBOutlet var pumpConfigButton: UIButton!

    private var pumpSpeed: String = "1"

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

        initDataPumpSpeed()

        setupTimePicker()
        progressBar.setProgress(progress: 0)
    }

    private func initDataPumpSpeed() {
        fetchDataFromFirebase(atPath: "pumpSpeed", dataType: String.self) { [weak self] result in
            switch result {
            case .success(let data):
                self?.pumpModeSlider.value = Float(data)!
            case .failure:
                self?.handleReadDataPumpSpeedFailed()
            }
        }
    }

    private func handleReadDataPumpSpeedFailed() {
        let cancelAction = UIAlertAction(title: "Đóng", style: .default)

        showAlert(title: "Lấy dữ liệu thất bại", message: "Vui lòng kiểm tra lại đường truyền", actions: [cancelAction])
    }

    override func configSubViews() {
        backgroundTimeoutView.roundCorners(with: 15)
        backgroundSliderView.roundCorners(with: 15)
        pumpConfigButton.roundCorners(with: pumpConfigButton.frame.size.height / 2)
    }

    @IBAction func valueChangedSlider(_ sender: UISlider) {
        pumpModeSlider.value = roundf(pumpModeSlider.value)
    }

    @IBAction func touchUpInsidePumpConfigButton(_ sender: UIButton) {
        if let time = timeoutTextField.text, !time.isEmpty {
            timeLeft = getTimeLeft(time)
            writeDataTimerAndPumpSpeed("\(Int(timeLeft))")
        } else {
            writeDataPumpSpeed()
        }

        initialTime = CGFloat(timeLeft)

        endTime = Date().addingTimeInterval(timeLeft)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)

        print(pumpModeSlider.value)
    }

    // handle write data

    private func writeDataTimerAndPumpSpeed(_ timeLeft: String) {
        writeDataToFirebase("timeoutPump", timeLeft) { [weak self] result in
            switch result {
            case .success:
                self?.handleWriteDataPumpSpeedSuccess()
            case .failure:
                self?.handleWriteDataFailed()
            }
        }
        writeDataPumpSpeed()
    }

    private func writeDataPumpSpeed() {
        let pumpSpeed = "\(Int(pumpModeSlider.value))"
        writeDataToFirebase("pumpSpeed", pumpSpeed) { [weak self] result in
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

    // handle update time

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
