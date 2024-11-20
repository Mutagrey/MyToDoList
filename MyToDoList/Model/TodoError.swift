//
//  TodoError.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 19.11.2024.
//

import Foundation

enum TodoError: Error {
    case wrongDataFormat(error: Error)
    case missingData
    case creationError
    case batchInsertError
    case batchDeleteError
    case unexpectedError(error: Error)
    case errorMessage(msg: String)
}

extension TodoError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .wrongDataFormat(let error):
            return NSLocalizedString("Could not digest the fetched data. \(error.localizedDescription)", comment: "")
        case .missingData:
            return NSLocalizedString("Found and will discard a todo item, missing a valid data.", comment: "")
        case .creationError:
            return NSLocalizedString("Failed to create a new Todo object.", comment: "")
        case .batchInsertError:
            return NSLocalizedString("Failed to execute a batch insert request.", comment: "")
        case .batchDeleteError:
            return NSLocalizedString("Failed to execute a batch delete request.", comment: "")
        case .unexpectedError(let error):
            return NSLocalizedString("Received unexpected error. \(error.localizedDescription)", comment: "")
        case .errorMessage(let msg):
            return NSLocalizedString(msg, comment: "")
        }
    }
}

extension TodoError: Identifiable {
    var id: String? {
        errorDescription
    }
}
