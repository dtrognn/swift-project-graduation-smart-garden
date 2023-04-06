//
//  WeatherCell.swift
//  SmartGarden
//
//  Created by Vu Duc Trong on 28/03/2023.
//

import UIKit

class WeatherCell: UICollectionViewCell {

    private let parameterImages: [String] = ["temperature", "humidity", "meter", "light-c"]
    private let parameterNames: [String] = ["Nhiệt độ", "Độ ẩm", "Độ ẩm đất", "Ánh sáng"]

    @IBOutlet weak var parameterImageView: UIImageView!
    @IBOutlet weak var paramaterValueLabel: UILabel!
    @IBOutlet weak var parameterNameLabel: UILabel!

    @IBOutlet weak var backgroundCellView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundCellView.roundCorners(with: 20)
    }
}

extension WeatherCell {
    func bindData(_ indexPath: IndexPath) {
        parameterImageView.image = UIImage(named: parameterImages[indexPath.row])
        parameterNameLabel.text = parameterNames[indexPath.row]
    }
}
