//
//  HomeViewController.swift
//  SmartGarden
//
//  Created by Vu Duc Trong on 27/03/2023.
//

import FirebaseDatabase
import UIKit

class HomeViewController: BaseViewController {
    @IBOutlet private var backgroundWeatherView: UIView!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var rainStateImaveView: UIImageView!

    @IBOutlet var weatherCollectionView: UICollectionView!

    private let numberOfItemInRow: CGFloat = 2
    private let cellPaddingLeft: CGFloat = 20
    private let cellPaddingRight: CGFloat = 20
    private let minimumLineSpacing: CGFloat = 10
    private let minimumInteritemSpacing: CGFloat = 10

    private var tempC: String = ""
    private var humidity: String = ""
    private var soilMoisture: String = ""
    private var lightIntensity: String = ""

    private var parameterValues: [String] = ["", "", "", ""]

    override func viewDidLoad() {
        super.viewDidLoad()

        initDataFirebase()
        initDataRaintState()

        fetchDataFromAPI()

        configCollectionView(weatherCollectionView)
    }

    override func configSubViews() {
        backgroundWeatherView.roundCorners(with: 20)
        backgroundWeatherView.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 0.94, alpha: 1.00)
    }

    // MARK: - initDataFirebase

    private func initDataRaintState() {
        fetchDataFromFirebase(atPath: "DULIEUCAMBIEN", dataType: String.self) { [weak self] result in
            self?.displayIndicator(isShow: false)
            switch result {
            case .success(let data):
                let rainCode = "\(data.suffix(1))"
                
                self?.applyRainState(rainCode)
            case .failure(let error):
                self?.handleReadDataFailed(error)
            }
        }
    }

    private func applyRainState(_ data: String) {
        if data == "0" {
            rainStateImaveView.image = UIImage(named: "sun-cloud")
        } else {
            rainStateImaveView.image = UIImage(named: "rain")
        }
    }

    private func initDataFirebase() {
        displayIndicator(isShow: true)
        fetchDataFromFirebase(atPath: "DULIEUCAMBIEN", dataType: String.self) { [weak self] result in
            self?.displayIndicator(isShow: false)
            switch result {
            case .success(let data):
                self?.tempC = "\(data.prefix(2))"
                self?.humidity = "\(data.dropFirst(2).prefix(2))"
                self?.soilMoisture = "\(data.dropFirst(4).prefix(2))"
                self?.lightIntensity = "\(data.dropFirst(6).prefix(2))"

                self?.parameterValues = ["\(self?.tempC ?? "")℃",
                                         "\(self?.humidity ?? "")%",
                                         "\(self?.soilMoisture ?? "")%",
                                         "\(self?.lightIntensity ?? "")%"]

                self?.weatherCollectionView.reloadData()
            case .failure(let error):
                self?.handleReadDataFailed(error)
            }
        }
    }

    private func handleReadDataFailed(_ error: Error) {
        print("Error: \(error.localizedDescription)")

        let cancelAction = UIAlertAction(title: "Đóng", style: .destructive)
        showAlert(title: "Mất kết nối", message: "", actions: [cancelAction])
    }

    // MARK: - configCollectionView

    private func configCollectionView(_ collectionView: UICollectionView) {
        // TODO: config collectionview

        collectionView.register(
            .init(nibName: "\(WeatherCell.self)", bundle: nil),
            forCellWithReuseIdentifier: "\(WeatherCell.self)")

        collectionView.register(
            .init(nibName: "\(HeaderReusableView.self)", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(HeaderReusableView.self)")

        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView
    {
        switch kind {
        case UICollectionView.elementKindSectionHeader:

            if let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "\(HeaderReusableView.self)",
                for: indexPath) as? HeaderReusableView
            {
                headerView.parametersLabel.text = "Các thông số trong vườn"

                return headerView
            }

        default:
            return UICollectionReusableView()
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewControllerIdentifier: String

        switch indexPath.row {
        case 0:
            viewControllerIdentifier = "TemperatureViewController"
        case 1:
            viewControllerIdentifier = "HumidityViewController"
        case 2:
            viewControllerIdentifier = "SoilMostureViewController"
        case 3:
            viewControllerIdentifier = "LightViewController"
        default:
            return
        }

        guard let viewController = storyboard?.instantiateViewController(withIdentifier: viewControllerIdentifier) else {
            return
        }

        present(viewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(WeatherCell.self)", for: indexPath) as! WeatherCell

        cell.bindData(indexPath)
        cell.paramaterValueLabel.text = parameterValues[indexPath.row]

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let widthContainer: CGFloat = view.frame.size.width
        let widthCell = floor((widthContainer - cellPaddingLeft - cellPaddingRight - (numberOfItemInRow - 1) * minimumInteritemSpacing) / numberOfItemInRow)
        let heightCell: CGFloat = widthCell + 20

        return CGSize(width: widthCell, height: heightCell)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellPaddingLeft, bottom: 0, right: cellPaddingRight)
    }
}
