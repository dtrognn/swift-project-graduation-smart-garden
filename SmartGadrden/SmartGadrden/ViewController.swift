//
//  ViewController.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 03/04/2023.
//

import FirebaseDatabase
import UIKit

class ViewController: UIViewController {
    let database = Database.database().reference()
    static var workMode: String = ""
    static var sensorData: String = ""
    static var engineData: String = ""
    lazy var dataValue: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let modeRef = database.child("CHEDO")
        modeRef.setValue("3")

        //        database.child("CHEDO").observeSingleEvent(of: .value) { snapshot in
        //            guard let chedo = snapshot.value as? String else {
        //                print("Error: Invalid data")
        //                return
        //            }
        //            print("CHEDO: \(chedo)")
        //        }

        //        let chedoRef = database.child("CHEDO")
        //
        //        // Retrieve the value of "CHEDO" from Firebase
        //        chedoRef.observeSingleEvent(of: .value, with: { snapshot in
        //            // Get the value of "CHEDO" as a String
        //            let chedoValue = snapshot.value as? String ?? ""
        //            print("CHEDO: \(chedoValue)")
        //        })

        fetchDataFromFirebase(atPath: "CHEDO", dataType: String.self) { result in
            switch result {
            case .success(let chedo):
                print("CHEDO: \(chedo)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }

        fetchDataFromFirebase(atPath: "DULIEUCAMBIEN", dataType: String.self) { result in
            switch result {
            case .success(let chedo):
                print("CHEDO: \(chedo)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func fetchDataFromFirebase<T>(atPath path: String, dataType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
//        let database = Database.database().reference()
        database.child(path).observeSingleEvent(of: .value) { snapshot in
            do {
                guard let data = snapshot.value as? T else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data type"])
                }
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
