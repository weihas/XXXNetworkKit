//
//  Retry.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2026/2/27.
//

import Foundation

// MARK: - Retry

/**
 Retries an async request with optional delay and conditional retry logic.

 This helper attempts the provided `request` and, on failure, checks cancellation,
 evaluates `shouldRetry`, and waits `retryDelay` seconds before retrying.

 - Parameters:
   - retries: The maximum number of retries after the initial attempt. Values below 0 are treated as 0.
   - retryDelay: The delay (in seconds) between retries. Set to 0 to retry immediately.
   - shouldRetry: Optional predicate to decide whether a given error should be retried. If it returns `false`, the error is rethrown.
   - request: An async throwing closure that performs the work and returns a `Decodable` value.
 - Returns: The successful decoded value returned by `request`.
 - Throws: The error from `request` if retries are exhausted or `shouldRetry` returns `false`.

 - Example:
 ```swift
 let value: MyModel = try await retry(retries: 3, retryDelay: 0.5) {
     try await api.fetchMyModel()
 }
 ```
 */
public func retry<T: Decodable>(retries: Int = 2, retryDelay: TimeInterval = 1.0, shouldRetry: ((Error) -> Bool)? = nil, request: @Sendable @escaping () async throws -> T) async throws -> T {
    
    var attempt = 0
    let maxRetries = max(0, retries)
    
    while true {
        do {
            return try await request()
        } catch {
            try Task.checkCancellation()
            
            
            if attempt >= maxRetries || (shouldRetry?(error) == false) {
                throw error
            }
            
            attempt += 1
            
            if retryDelay > 0 {
                let delay = UInt64(retryDelay * 1_000_000_000)
                try await Task.sleep(nanoseconds: delay)
            }
        }
    }
}

// MARK: - Polling

/**
 Polls an async request until a success condition is met or a timeout occurs.

 The function repeatedly executes `request`, evaluates `predicate` on each result,
 and sleeps between attempts using exponential backoff.

 - Parameters:
   - interval: Initial polling interval in seconds. Values below `0.1` are clamped to `0.1`.
   - timeout: Maximum total polling duration in seconds before throwing `PollingError.timedOut`.
   - multiplier: Backoff multiplier applied after each attempt.
   - maxInterval: Upper bound for the polling interval in seconds.
   - jitter: Whether to apply random jitter (`±20%`) to each delay interval.
   - request: Async throwing closure that fetches a `Decodable` value on each poll attempt.
   - predicate: Closure that returns `true` when polling should stop and return the current result.
 - Returns: The first value for which `predicate` returns `true`.
 - Throws: `PollingError.timedOut` when the timeout is reached, cancellation errors if the task is cancelled, or any error thrown by `request`.

 - Example:
 ```swift
 let status = try await poll(interval: 1, timeout: 20, request: {
     try await api.fetchStatus()
 }, until: { $0.isReady })
 ```
 */
public func poll<T: Decodable>(interval: TimeInterval = 2.0, timeout: TimeInterval = 120.0, multiplier: Double = 1.5, maxInterval: TimeInterval = 10, jitter: Bool = true, request: @Sendable @escaping () async throws -> T, until predicate: @Sendable @escaping (T) -> Bool) async throws -> T {
    
    let startTime = Date()
    var currentInterval = max(0.1, interval)
    
    while true {
        try Task.checkCancellation()
        
        let result: T = try await request()
        if predicate(result) {
            return result
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        if elapsed >= timeout {
            throw XXXNetworkWrappedError(errorCode: -10, description: "PollingTimedOut")
        }
        
        var nextInterval = min(currentInterval, maxInterval)
        
        // jitter（±20%）
        if jitter {
            let factor = Double.random(in: 0.8...1.2)
            nextInterval *= factor
        }
        
        let remaining = timeout - elapsed
        nextInterval = min(nextInterval, remaining)
        
        let delay = UInt64(nextInterval * 1_000_000_000)
        try await Task.sleep(nanoseconds: delay)
        
        currentInterval = min(currentInterval * multiplier, maxInterval)
    }
}
