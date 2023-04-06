//
//  WriteDataFirebase.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 05/04/2023.
//

import FirebaseDatabase
import Foundation

// func writeDataToFirebase(_ ref: String, _ data: Any) {
//    let databaseRef = Database.database().reference().child(ref)
//
//    databaseRef.setValue(data)
// }

func writeDataToFirebase(_ ref: String, _ data: Any, completion: @escaping (Result<Bool, Error>) -> Void) {
    let databaseRef = Database.database().reference().child(ref)

    databaseRef.setValue(data) { error, _ in
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(true))
        }
    }
}
