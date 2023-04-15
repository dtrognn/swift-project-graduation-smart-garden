//
//  SoilMostureViewController.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 12/04/2023.
//

import Charts
import UIKit

class SoilMostureViewController: BaseViewController {
    @IBOutlet var lineChart: LineChartView!

    private var timeSoilMostureTitle: [String] = []
    private var soilMostureData: [String] = []

    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        initData()
        initDataFirebase()
    }

    private func initData() {
        if let savedData = userDefaults.array(forKey: "soilMostureData") as? [String] {
            soilMostureData = savedData
        }
        if let savedTime = userDefaults.array(forKey: "timeSoilMostureTitle") as? [String] {
            timeSoilMostureTitle = savedTime
        }
    }

    private func saveData() {
        userDefaults.set(soilMostureData, forKey: "soilMostureData")
        userDefaults.set(timeSoilMostureTitle, forKey: "timeSoilMostureTitle")
    }

    private func initDataFirebase() {
        displayIndicator(isShow: true)
        fetchDataFromFirebase(atPath: "DULIEUCAMBIEN", dataType: String.self) { [weak self] result in
            self?.displayIndicator(isShow: false)
            switch result {
            case .success(let data):
                let temp = "\(data.dropFirst(4).prefix(2))"

                self?.appendTemperature(temp, self!.getCurrentDateTime())

                if let soilMostureData = self?.soilMostureData, let timeSoilMostureTitle = self?.timeSoilMostureTitle,
                   soilMostureData.count > 7, timeSoilMostureTitle.count > 7
                {
                    self?.removeFirst()
                }

                self?.createLineChart(self!.timeSoilMostureTitle, self!.soilMostureData)

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
//        soilMostureData.append(data)
//        timeSoilMostureTitle.append(title)

        guard let lastTemp = soilMostureData.last else {
            soilMostureData.append(data)
            timeSoilMostureTitle.append(title)
            return
        }
        if lastTemp != data {
            soilMostureData.append(data)
            timeSoilMostureTitle.append(title)
        }
    }

    private func removeFirst() {
        soilMostureData.removeFirst()
        timeSoilMostureTitle.removeFirst()
    }

    private func createLineChart(_ timeTitle: [String], _ values: [String]) {
        var lineArr: [ChartDataEntry] = []

        for i in 0 ..< timeTitle.count {
            let data = ChartDataEntry(x: Double(i), y: Double(values[i])!)
            lineArr.append(data)
        }

        let lineDataSet = LineChartDataSet(entries: lineArr, label: "Soil Mosture")
        lineDataSet.setColor(.red)

        let xAxis = lineChart.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTitle.suffix(7))
        xAxis.labelCount = 7
        xAxis.granularity = 1

        xAxis.axisMinimum = -0.3
        xAxis.axisMaximum = Double(soilMostureData.count) - 0.7

        let lineData = LineChartData(dataSet: lineDataSet)
        lineChart.data = lineData

        lineChart.animate(xAxisDuration: 2, easingOption: .easeInBounce)
        lineChart.animate(yAxisDuration: 2, easingOption: .easeInBounce)
    }
}
