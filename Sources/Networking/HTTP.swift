//
//  File.swift
//  
//
//  Created by Miso Lubarda on 23.03.20.
//

import Foundation

public enum HTTP {
    public enum Method {
        case get, post
    }

    public enum Header {
        public enum Key: Hashable {
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

        public enum Value {
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
