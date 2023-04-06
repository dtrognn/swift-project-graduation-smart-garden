//
//  EquipmentCell.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 05/04/2023.
//

import UIKit

class EquipmentCell: UICollectionViewCell {
    @IBOutlet var backgroundEquipmentView: UIView!
    @IBOutlet var equipmentImageView: UIImageView!
    @IBOutlet var equipmentLabel: UILabel!
    @IBOutlet var equipmentSwitch: UISwitch!

    private let equipmentImages: [String] = ["canopy", "lightbulb", "fan", "revolve"]
    private let equipmentNames: [String] = ["Mái che", "Đèn", "Quạt", "Máy bơm"]

    var engineStates: String = "0000"
    var engineIndex: Int = 0

    var switchValueChangedHandler: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundEquipmentView.border(width: 1, color: .lightGray)
        backgroundEquipmentView.roundCorners(with: 15)

        // add target event
        // when switch changed, func switchValueChanged is called
        equipmentSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }

    @objc private func switchValueChanged(_ sender: UISwitch) {
        switchValueChangedHandler?(sender.isOn)
    }

    func bindData(_ indexPath: IndexPath) {
        equipmentImageView.image = UIImage(named: equipmentImages[indexPath.row])
        equipmentLabel.text = equipmentNames[indexPath.row]
    }
}
