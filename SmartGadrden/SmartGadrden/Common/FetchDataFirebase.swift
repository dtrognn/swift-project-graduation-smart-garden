//
//  HomeViewController+FetchDataFirebase.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 03/04/2023.
//

import FirebaseDatabase
import Foundation

// MARK: - fetchDataFromFirebase

func fetchDataFromFirebase<T>(atPath path: String, dataType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
    let database = Database.database().reference()

    database.child(path).observe(.value) { snapshot in
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
