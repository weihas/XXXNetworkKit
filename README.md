# 🚀 XXXNetworkKit

A unified networking architecture built on top of Moya, Alamofire, and Swift Concurrency, designed as a reference implementation for standardizing API response structures, error handling, and request flow in iOS applications.

⚠️ This is not intended as a plug-and-play library for direct dependency usage, but rather as an architectural design pattern demonstrating how to build a strongly-typed, scalable networking layer.

---

# 📌 Naming

The name XXXNetworkKit is intentionally designed as a placeholder, allowing developers to replace XXX with their own project or company prefix to form a customized networking framework name.

---

# 🧠 Overview

XXXNetworkKit is a layered networking architecture designed to solve common problems in large-scale iOS applications:

- Inconsistent API response formats across backend services
- Fragmented error handling strategies
- Bridging callback-based networking into Swift async/await
- Mixing of raw JSON parsing and strongly-typed models
- Tight coupling between business logic and networking layer

The framework provides a unified, predictable, and extensible networking layer.

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

# 🔄 Data Flow

```
API Call
  ↓
XXXAPIProvider.request()
  ↓
MoyaProvider (MultiTarget)
  ↓
URLSession
  ↓
HTTP Response
  ↓
BaseResponse Decoding
  ↓
Business Code Validation
  ↓
Data Extraction
  ↓
Codable Model / JSON
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

# 🧱 Namespace Design

Third-party dependencies are hidden behind typealiases:

- Prevents external coupling
- Simplifies public API surface
- Improves modularity

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

OR

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

---

# 📌 Philosophy

> All network responses should be predictable, strongly typed, and centrally controlled.

