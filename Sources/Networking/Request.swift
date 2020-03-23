//
//  File.swift
//  
//
//  Created by Miso Lubarda on 23.03.20.
//

import Foundation

protocol Request {
    associatedtype Body: Encodable
    var endpointPath: String { get }
    var body: Body? { get }
    var headers: [HTTP.Header.Key: HTTP.Header.Value] { get }
    var method: HTTP.Method { get }
}

