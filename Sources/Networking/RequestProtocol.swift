//
//  File.swift
//  
//
//  Created by Miso Lubarda on 23.03.20.
//

import Foundation

public protocol RequestProtocol {
    var endpointPath: String { get }
    var headers: [HTTP.Header.Key: HTTP.Header.Value] { get }
    var method: HTTP.Method { get }
}

public protocol RequestBodyProtocol {
    associatedtype Body: Encodable
    var body: Body { get }
}
