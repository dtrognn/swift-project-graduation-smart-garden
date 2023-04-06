//
//  ConfigViewController.swift
//  SmartGarden
//
//  Created by Vu Duc Trong on 29/03/2023.
//

import FirebaseDatabase
import UIKit

class ConfigViewController: BaseViewController {
    private var engineStates: String = "0000"

    @IBOutlet var configCollectionView: UICollectionView!

    private let numberOfItemInRow: CGFloat = 1
    private let cellPaddingLeft: CGFloat = 20
    private let cellPaddingRight: CGFloat = 20
    private let minimumLineSpacingForSectionAt: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        initDataEngineFirebase()

        configCollectionView(configCollectionView)
    }

    private func initDataEngineFirebase() {
        fetchDataFromFirebase(atPath: "TINHIEUDONGCO", dataType: String.self) { [weak self] result in
            switch result {
            case .success(let data):
                print(data)
                self?.engineStates = data
                self?.configCollectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    private func configCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(.init(nibName: "\(EquipmentCell.self)", bundle: nil), forCellWithReuseIdentifier: "\(EquipmentCell.self)")

        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK: - UICollectionViewDelegate

extension ConfigViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

// MARK: - UICollectionViewDataSource

extension ConfigViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(EquipmentCell.self)", for: indexPath) as! EquipmentCell

        cell.bindData(indexPath)

        let switchState = engineStates[engineStates.index(engineStates.endIndex, offsetBy: -(indexPath.row + 1))]
        cell.equipmentSwitch.setOn(switchState == "1", animated: true)

        cell.switchValueChangedHandler = { isOn in
            self.handleSwitchChanged(indexPath.row, isOn)
            self.updateFirebaseData()
        }

        return cell
    }

    // replaceSubRange: replace part of this string with another string
    // example: default string A: 0000, after func replaceSubRange, string A: 0001
    private func handleSwitchChanged(_ indexPath: Int, _ isOn: Bool) {
        switch indexPath {
        case 0:
            engineStates.replaceSubrange(engineStates.index(engineStates.endIndex, offsetBy: -1)..<engineStates.endIndex, with: isOn ? "1" : "0")
        case 1:
            engineStates.replaceSubrange(engineStates.index(engineStates.endIndex, offsetBy: -2)..<engineStates.index(engineStates.endIndex, offsetBy: -1), with: isOn ? "1" : "0")
        case 2:
            engineStates.replaceSubrange(engineStates.index(engineStates.endIndex, offsetBy: -3)..<engineStates.index(engineStates.endIndex, offsetBy: -2), with: isOn ? "1" : "0")
        default:
            engineStates.replaceSubrange(engineStates.startIndex..<engineStates.index(engineStates.endIndex, offsetBy: -3), with: isOn ? "1" : "0")
        }

        configCollectionView.reloadItems(at: [IndexPath(row: indexPath, section: 0)])
    }

    private func updateFirebaseData() {
        writeDataToFirebase("TINHIEUDONGCO", engineStates)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ConfigViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let widthContainer: CGFloat = view.frame.size.width

        let width = floor((widthContainer - cellPaddingLeft - cellPaddingRight) / numberOfItemInRow)
        let height: CGFloat = 70
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacingForSectionAt
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellPaddingLeft, bottom: 0, right: cellPaddingRight)
    }
}
