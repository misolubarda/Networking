//
//  File.swift
//  
//
//  Created by Miso Lubarda on 23.03.20.
//

import Foundation

enum HTTP {
    enum Method {
        case get, post
    }

    enum Header {
        enum Key: Hashable {
            case authorization
            case contentType
            case custom(key: String)

            var rawValue: String {
                switch self {
                case .authorization:
                    return "Authorization"
                case .contentType:
                    return "Content-Type"
                case let .custom(key: key):
                    return key
                }
            }
        }

        enum Value {
            case applicationJSON
            case custom(value: String)

            var rawValue: String {
                switch self {
                case .applicationJSON:
                    return "application/json"
                case let .custom(value: value):
                    return value
                }
            }
        }
    }
}
