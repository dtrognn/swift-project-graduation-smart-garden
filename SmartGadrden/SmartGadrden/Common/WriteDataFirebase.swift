//
//  WriteDataFirebase.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 05/04/2023.
//

import Foundation
import FirebaseDatabase

func writeDataToFirebase(_ ref: String, _ data: Any) {
    let databaseRef = Database.database().reference().child(ref)

    databaseRef.setValue(data)
}
