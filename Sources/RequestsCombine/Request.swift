//
//  Request.swift
//  RequestsCombine
//
//  Copyright 2020 Daniel Byon.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation
import Combine

public protocol Request {

    associatedtype Success
    associatedtype Failure: Error

    var retryCount: Int { get }
    
    func makeURLRequest() throws -> URLRequest

    func processData(_ data: Data, response: URLResponse) throws -> Success

    func mapError(_ error: Error) -> Failure

}

public extension Request {

    var retryCount: Int { 3 }

    func publisher(session: URLSessionProtocol = URLSession.shared) -> AnyPublisher<Success, Failure> {
        do {
            let urlRequest = try makeURLRequest()
            let publisher = session
                .anyDataTaskPublisher(for: urlRequest)
                .retry(retryCount)
                .tryMap { try processData($0.data, response: $0.response) }
                .mapError { mapError($0) }
                .eraseToAnyPublisher()
            return publisher
        } catch {
            return Fail(error: mapError(error))
                .eraseToAnyPublisher()
        }
    }

}

public extension Request where Failure == Error {

    func mapError(_ error: Error) -> Failure {
        return error
    }

}
