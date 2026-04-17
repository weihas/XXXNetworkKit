# 🚀 XXXNetworkKit

A unified networking architecture built on top of Moya, Alamofire, and Swift Concurrency, designed as a reference implementation for standardizing API response structures, error handling, and request flow in iOS applications.

⚠️ This is not intended as a plug-and-play library for direct dependency usage, but rather as an architectural design pattern demonstrating how to build a strongly-typed, scalable networking layer.

---

# 📌 Naming

The name XXXNetworkKit is a placeholder.


Replace XXX with your project or company prefix:

```
XXXNetworkKit → MyAppNetworkKit / ABCNetworkKit
```

---

# 🧠 Overview

XXXNetworkKit is a layered networking architecture designed to solve common problems in large-scale iOS applications:

- Inconsistent API response formats across backend services
- Fragmented error handling strategies
- Bridging callback-based networking into Swift async/await
- Mixing of raw JSON parsing and strongly-typed models
- Tight coupling between business logic and networking layer

  The framework provides a unified, predictable, and extensible networking layer.
  
  ✅ Goal:

  > Build a **unified, predictable, and scalable** networking layer.

---

# 🏗 Architecture

```
Application Layer
        ↓
XXXAPIProvider (Unified Entry Point)
        ↓
Moya + Alamofire (Transport Layer)
        ↓
URLSession (System Layer)
```

---

# 📦 Core Components

## 1. API Provider Layer

`XXXAPIProvider` is the single entry point for all network requests.

### Responsibilities:

- Unified request interface
- Async/await bridging
- Request cancellation handling
- Plugin system (logging, timing, debugging)
- Session configuration management

### Features:

- Singleton shared instance
- Custom URLSession configuration
- Debug-only logging plugins
- Swift Concurrency support

---

## 2. Request System

The framework wraps Moya's callback-based API into Swift structured concurrency.

### Key technologies:

- withCheckedThrowingContinuation
- withTaskCancellationHandler
- Thread-safe cancellable management

### Capabilities:

- Cooperative cancellation
- Safe continuation handling
- Unified response abstraction

---

## 3. Response Mapping System

All backend responses are normalized into a standard format:

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "request_id": "xxx"
}
```

### Mapping Flow:

```
HTTP Response (status 200)
        ↓
BaseResponse<T>
        ↓
Business Code Validation
        ↓
Data Extraction
        ↓
Decodable Model
```

---

# ⚠️ Error Handling System

## Unified Error Protocol

All networking errors conform to a unified protocol:

- Server errors
- Transport errors
- Wrapped custom errors

### Error Types:

- ServerError (business code errors)
- MoyaError (transport layer)
- WrappedError (fallback / unknown)

---

## Error Strategy

| Layer        | Type of Error |
|-------------|--------------|
| HTTP Layer  | Network / Transport errors |
| Business    | Server-defined error codes |
| Fallback    | Wrapped custom errors |

---

# 🧭 API Namespace Design

To support large-scale APIs, the framework introduces namespace-based API organization.

## Problem

A single XXXAPI enum becomes:
- Hard to maintain
- Difficult to navigate
- High merge conflict risk

## Solution

Group APIs by domain:

```swift
enum XXXAPI {
    enum User {
        case info
        case login
        case logout
    }

    enum Order {
        case list
        case detail(id: String)
    }
}
```

## Benefits
- 📦 Clear domain separation
- 🔍 Better code completion experience
- 🧩 Easier modularization
- 👥 Reduced team conflicts

# 🧪 Test-Driven API Integration
API integration is now test-driven.

## Concept

Instead of writing API calls inside business logic:

👉 Write test cases first to complete API integration

## Example
```swift
import Testing
@testable import XXXNetworkKit

@Suite
struct UserTest {
  
    @Test
    func info() async throws {
        let user = try await XXXAPIProvider.shared.request(XXXAPI.User.info, to: Model.User.self)
        #expect(user.openid != nil)
    }


    @Test
    func union_id() async throws {
        let result = try await XXXAPIProvider.shared.request(XXXAPI.User.union_id)
        #expect(result["union_id"].string != nil)
    }
}

```

## Advantages
- ✅ No UI dependency
- ✅ Faster debugging
- ✅ Early backend validation
- ✅ Strong type-safety verification

# 🔄 Recommended Workflow

```
Define API (Namespace)
        ↓
Write Test Case
        ↓
Complete API Integration
        ↓
Develop Business Logic / UI
```

---

# ⚙️ Design Principles

## 1. Swift Concurrency First

- Full async/await support
- Task cancellation propagation
- Continuation-safe bridging

---

## 2. Strict API Contract

All backend responses must follow:

```json
{
  "code": Int,
  "message": String,
  "data": Any?
}
```

This ensures:

- Unified parsing logic
- Centralized error handling
- Backend contract consistency

---

## 3. Dual Decoding Strategy

### Codable (Recommended)
- High performance
- Type-safe
- Production-ready

### JSON fallback
- Flexible parsing
- Dynamic use cases

---

## 4. Performance Consideration

Dynamic JSON parsing is supported but not recommended for heavy workloads.

⚠️ Not recommended for complex or performance-sensitive scenarios
> Codable is significantly 40x faster and preferred for large or deeply nested responses.

---

# 🧪 Usage Examples

## Request with Model

```swift
struct User: Codable {
    let name: String
    let openid: String
}

let user = try await XXXAPIProvider.shared.request(
    XXXAPI.User.info,
    to: User.self
)

print(user.name)
```

---

## Request with JSON

```swift
let userJSON = try await XXXAPIProvider.shared.request(XXXAPI.User.info)
print(userJSON["name"].stringValue)
```

---

## Request without Response

```swift
try await XXXAPIProvider.shared.request(XXXAPI.User.delete)
```

---

## Error Handling

```swift
do {
    try await XXXAPIProvider.shared.request(...)
    print("Request Done")
} catch XXXNetworkServerError.serverException {
    // Handle a specific business error, usually used to show user-facing messages
    showToast(error.localizedDescription)
} catch let error as XXXNetworkError where error.isNetworkConnectError {
    // Use 'where' clause to filter network connection related errors
    showToast("Network connection error")
} catch let error as XXXNetworkError {
    // Handle all networking module errors
    print("code: \(error.errorCode)")
} catch {
    // Handle non-network errors
    print("Unknown error: \(error.localizedDescription)")
}
```

---

# 🧩 Extensibility

The framework supports:

- Custom plugins (logging / metrics / tracing)
- Custom error mapping
- Alternative decoding strategies
- Multi-target routing

---

# 🚀 Summary

XXXNetworkKit is a production-ready networking architecture that:

- Unifies networking via a single API provider
- Standardizes backend response format
- Centralizes error handling
- Supports async/await concurrency model
- Provides scalable architecture for large iOS applications
