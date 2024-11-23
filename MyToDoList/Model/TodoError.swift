//
//  TodoError.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 19.11.2024.
//

import Foundation

// MARK: - TodoError
enum TodoError: Error, Sendable {
    case error(error: Error)
}

extension TodoError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .error(let error):
            if let localError = error as? LocalizedError {
                return localError.errorDescription
            } else {
                return NSLocalizedString(error.localizedDescription, comment: "")
            }
        }
    }
}

// MARK: - APIError
enum APIError: Error, Sendable {
    case invalidURL
    case requestError(error: Error)
    case missingData
    case decodeError(error: Error)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL link.", comment: "")
        case .requestError(let error):
            return NSLocalizedString("Request failed. \(error.localizedDescription)", comment: "")
        case .missingData:
            return NSLocalizedString("Missing JSON data.", comment: "")
        case .decodeError(let error):
            return NSLocalizedString("Error to decode JSON data. \(error.localizedDescription)", comment: "")
        }
    }
}

// MARK: - DataManagerError
enum DataManagerError: Error, Sendable {
    case creationError
    case insertError
    case deleteError
    case fetchError(error: Error)
    case unexpectedError(error: Error)
}

extension DataManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .creationError:
            return NSLocalizedString("Failed to create a new item.", comment: "")
        case .insertError:
            return NSLocalizedString("Failed to execute an insert request.", comment: "")
        case .deleteError:
            return NSLocalizedString("Failed to execute a delete request.", comment: "")
        case .fetchError(let error):
            return NSLocalizedString("Failed to fetch data. \(error.localizedDescription)", comment: "")
        case .unexpectedError(let error):
            return NSLocalizedString("Unexpected error. \(error.localizedDescription)", comment: "")
        }
    }
}
