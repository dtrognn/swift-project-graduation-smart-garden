//
//  HumidityViewController.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 12/04/2023.
//

import Charts
import UIKit

class HumidityViewController: BaseViewController {
    @IBOutlet var lineChart: LineChartView!

    private var timeHumidityTitle: [String] = []
    private var humidityData: [String] = []

    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        initData()
        initDataFirebase()
    }

    private func initData() {
        if let savedData = userDefaults.array(forKey: "humidityData") as? [String] {
            humidityData = savedData
        }
        if let savedTime = userDefaults.array(forKey: "timeHumidityTitle") as? [String] {
            timeHumidityTitle = savedTime
        }
    }

    private func saveData() {
        userDefaults.set(humidityData, forKey: "humidityData")
        userDefaults.set(timeHumidityTitle, forKey: "timeHumidityTitle")
    }

    private func initDataFirebase() {
        displayIndicator(isShow: true)
        fetchDataFromFirebase(atPath: "DULIEUCAMBIEN", dataType: String.self) { [weak self] result in
            self?.displayIndicator(isShow: false)
            switch result {
            case .success(let data):
                let temp = "\(data.dropFirst(2).prefix(2))"

                self?.appendTemperature(temp, self!.getCurrentDateTime())

                if let humidityData = self?.humidityData, let timeHumidityTitle = self?.timeHumidityTitle,
                   humidityData.count > 7, timeHumidityTitle.count > 7
                {
                    self?.removeFirst()
                }

                self?.createLineChart(self!.timeHumidityTitle, self!.humidityData)

                self?.saveData()
            case .failure(let error):
                self?.handleReadDataFailed(error)
            }
        }
    }

    private func handleReadDataFailed(_ error: Error) {
        print("Error: \(error.localizedDescription)")

        let cancelAction = UIAlertAction(title: "Đóng", style: .destructive)
        showAlert(title: "Lỗi", message: "Lấy dữ liệu không thành công", actions: [cancelAction])
    }

    private func appendTemperature(_ data: String, _ title: String) {
        humidityData.append(data)
        timeHumidityTitle.append(title)
    }

    private func removeFirst() {
        humidityData.removeFirst()
        timeHumidityTitle.removeFirst()
    }

    private func createLineChart(_ timeTitle: [String], _ values: [String]) {
        var lineArr: [ChartDataEntry] = []

        for i in 0 ..< timeTitle.count {
            let data = ChartDataEntry(x: Double(i), y: Double(values[i])!)
            lineArr.append(data)
        }

        let lineDataSet = LineChartDataSet(entries: lineArr, label: "Humidity")
        lineDataSet.setColor(.red)

        let xAxis = lineChart.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTitle.suffix(7))
//        xAxis.labelCount = 7
        xAxis.granularity = 1

        xAxis.axisMinimum = -0.3
        xAxis.axisMaximum = Double(humidityData.count) - 0.7

        let lineData = LineChartData(dataSet: lineDataSet)
        lineChart.data = lineData

        lineChart.animate(xAxisDuration: 2, easingOption: .easeInBounce)
        lineChart.animate(yAxisDuration: 2, easingOption: .easeInBounce)
    }
}
