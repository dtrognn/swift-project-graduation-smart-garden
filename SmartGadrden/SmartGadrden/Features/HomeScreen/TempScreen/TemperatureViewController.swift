//
//  TemperatureViewController.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 12/04/2023.
//

import Charts
import UIKit

class TemperatureViewController: BaseViewController {
    @IBOutlet var lineChart: LineChartView!

    private var timeTitle: [String] = []
    private var tempData: [String] = []

    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        initData()
        initDataFirebase()
    }

    private func initData() {
        if let savedData = userDefaults.array(forKey: "tempData") as? [String] {
            tempData = savedData
        }
        if let savedTime = userDefaults.array(forKey: "timeTitle") as? [String] {
            timeTitle = savedTime
        }
    }

    private func saveData() {
        userDefaults.set(tempData, forKey: "tempData")
        userDefaults.set(timeTitle, forKey: "timeTitle")
    }

    private func initDataFirebase() {
        displayIndicator(isShow: true)
        fetchDataFromFirebase(atPath: "DULIEUCAMBIEN", dataType: String.self) { [weak self] result in
            self?.displayIndicator(isShow: false)
            switch result {
            case .success(let data):
                let temp = "\(data.prefix(2))"
                self?.appendTemperature(temp, self!.getCurrentDateTime())

                if let tempData = self?.tempData, let timeTitle = self?.timeTitle,
                   tempData.count > 7, timeTitle.count > 7
                {
                    self?.removeFirst()
                }

                self?.createLineChart(self!.timeTitle, self!.tempData)

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
        guard let lastTemp = tempData.last else {
            tempData.append(data)
            timeTitle.append(title)
            return
        }
        if lastTemp != data {
            tempData.append(data)
            timeTitle.append(title)
        }
    }

    private func removeFirst() {
        tempData.removeFirst()
        timeTitle.removeFirst()
    }

    private func createLineChart(_ timeTitle: [String], _ values: [String]) {
        var lineArr: [ChartDataEntry] = []

        for i in 0 ..< timeTitle.count {
            let data = ChartDataEntry(x: Double(i), y: Double(values[i])!)
            lineArr.append(data)
        }

        let lineDataSet = LineChartDataSet(entries: lineArr, label: "Temperature")
        lineDataSet.setColor(.red)

        let xAxis = lineChart.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTitle.suffix(7))
        xAxis.granularity = 1

        xAxis.axisMinimum = -0.3
        xAxis.axisMaximum = Double(tempData.count) - 0.7

        let lineData = LineChartData(dataSet: lineDataSet)
        lineChart.data = lineData

        lineChart.animate(xAxisDuration: 2, easingOption: .easeInBounce)
        lineChart.animate(yAxisDuration: 2, easingOption: .easeInBounce)
    }
}
