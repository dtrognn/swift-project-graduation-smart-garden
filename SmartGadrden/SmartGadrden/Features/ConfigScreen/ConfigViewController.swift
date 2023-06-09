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
    private var workMode: String = "1"

    let setting = SettingViewController.self

    @IBOutlet var configCollectionView: UICollectionView!

    private let numberOfItemInRow: CGFloat = 1
    private let cellPaddingLeft: CGFloat = 40
    private let cellPaddingRight: CGFloat = 40
    private let minimumLineSpacingForSectionAt: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        configCollectionView(configCollectionView)

        initDataWorkModeFirebase()
    }

    // MARK: - initDataWorkModeFirebase

    private func initDataWorkModeFirebase() {
        displayIndicator(isShow: true)
        fetchDataFromFirebase(atPath: "CHEDO", dataType: String.self) { [weak self] result in
            self?.displayIndicator(isShow: false)
            switch result {
            case .success(let data):
                self?.workMode = data

                if self?.workMode != "1", self?.workMode != "3" {
                    self?.initDataEngineFirebase()
                } else {
                    print(Self.self, #function)
                }
            case .failure(let error):
                self?.handleReadDataEngineFailed(error)
            }
            self?.configCollectionView.reloadData()
        }
    }

    // MARK: - initDataEngineFirebase

    private func initDataEngineFirebase() {
        fetchDataFromFirebase(atPath: "TINHIEUDONGCO", dataType: String.self) { [weak self] result in
            switch result {
            case .success(let data):
                self?.engineStates = data
                self?.configCollectionView.reloadData()
            case .failure(let error):
                self?.handleReadDataEngineFailed(error)
            }
        }
    }

    private func handleReadDataEngineFailed(_ error: Error) {
        print(Self.self, #function, error.localizedDescription)
        let cancelAction = UIAlertAction(title: "Đóng", style: .default)

        showAlert(title: "Lấy dữ liệu thất bại", message: "Vui lòng kiểm tra lại đường truyền", actions: [cancelAction])
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
        switch indexPath.row {
        case 1:
            let bulbVC = storyboard?.instantiateViewController(withIdentifier: "BulbViewController") as! BulbViewController
            present(bulbVC, animated: true)
        case 2:
            let fanVC = storyboard?.instantiateViewController(withIdentifier: "FanViewController") as! FanViewController
            present(fanVC, animated: true)
        case 3:
            let lampVC = storyboard?.instantiateViewController(withIdentifier: "LampViewController") as! LampViewController
            present(lampVC, animated: true)
        default:
            break
        }
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

        if workMode != "1" && workMode != "3" {
            cell.equipmentSwitch.isEnabled = true

            let switchState = engineStates[engineStates.index(engineStates.endIndex, offsetBy: -(indexPath.row + 1))]
            cell.equipmentSwitch.setOn(switchState == "1", animated: true)

            cell.switchValueChangedHandler = { isOn in
                self.handleSwitchChanged(indexPath.row, isOn)
                self.updateFirebaseData()
            }
        } else {
            cell.equipmentSwitch.isOn = false
            cell.equipmentSwitch.isEnabled = false
        }

        return cell
    }

    // replaceSubRange: replace part of this string with another string
    // example: default string A: 0000, after func replaceSubRange, string A: 0001
    private func handleSwitchChanged(_ indexPath: Int, _ isOn: Bool) {
        let oldValue = engineStates.first ?? "0"
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

        let newValue = engineStates.first ?? "0"
        if oldValue == "0" && newValue == "1" {
            writeDataToFirebase("pumpSpeed", "1") { [weak self] result in
                switch result {
                case .success:
                    print(Self.self, #function)
                case .failure(let error):
                    self?.handleWriteDataFailed(error)
                }
            }
        }

        configCollectionView.reloadItems(at: [IndexPath(row: indexPath, section: 0)])
    }

    private func updateFirebaseData() {
        displayIndicator(isShow: true)
        writeDataToFirebase("TINHIEUDONGCO", engineStates) { [weak self] result in
            self?.displayIndicator(isShow: false)
            switch result {
            case .success:
                print(Self.self, #function)
            case .failure(let error):
                self?.handleWriteDataFailed(error)
            }
        }
    }

    private func handleWriteDataFailed(_ error: Error) {
        let cancelAction = UIAlertAction(title: "Đóng", style: .default)

        showAlert(title: "Bật/tắt thiết bị thất bại", message: "", actions: [cancelAction])
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
