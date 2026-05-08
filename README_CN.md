# 🚀 XXXNetworkKit

一个基于 Moya、Alamofire、SwiftyJSON 与 Swift 并发构建的统一网络架构，旨在作为标准化 iOS 应用中 API 响应结构、错误处理与请求流程的参考实现。

⚠️ 它并非用于直接依赖的“开箱即用”类库，而是一种架构设计范式，演示如何构建强类型、可扩展的网络层。

---

# 📌 命名

名称 XXXNetworkKit 仅为占位符。

将 XXX 替换为你的项目或公司前缀：

```
XXXNetworkKit → MyAppNetworkKit / ABCNetworkKit
```

可以在仓库根目录运行改名脚本：

```sh
swift Scripts/rename.swift MyApp
```

如需先预览改动：

```sh
swift Scripts/rename.swift MyApp --dry-run
```

当前 Package 要求：

- Swift 6
- iOS 13+
- macOS 10.15+
- Swift Package Manager

---

# 🧠 概览

XXXNetworkKit 是一个分层的网络架构，旨在解决大型 iOS 应用中的常见问题：

- 后端服务之间 API 响应格式不一致
- 错误处理策略分散
- 将回调式网络请求桥接到 Swift async/await
- 原始 JSON 解析与强类型模型混用
- 业务逻辑与网络层高度耦合

该框架提供一个统一、可预测、可扩展的网络层。

✅ 目标：

> 构建一个统一、可预测且可扩展的网络层。

---

# 🏗 架构

```
.
├── Package.swift       
├── README.md           
├── Sources             
│   └── XXXNetworkKit            
│       ├── API
│       │     │── XXXAPI.swift
│       │     │── XXXAPI+User.swift
│       │     └── XXXAPI+Article.swift
│       ├── Errors
│       │     │── XXXNetworkError.swift
│       │     │── XXXNetworkMoyaError.swift
│       │     │── XXXNetworkServerError.swift
│       │     └── XXXNetworkWrappedError.swift
│       ├── Helper
│       │     │── Helper.swift
│       │     │── NetworkReachabilityManager.swift
│       │     └── Retry.swift
│       ├── Plugins
│       │     │── NetworkLoggerPlugin.swift
│       │     │── TimeoutPlugin.swift
│       │     └── TimerLoggerPlugin.swift
│       └── #XXXAPIProvider.swift           
│   └── XXXNetworkModel
│       └── Models
└── Tests
       └── XXXNetworkKitTests
       └── XXXNetworkKitTests.swift        

```

---

# 📦 核心组件

## 1. API 提供者层

`XXXAPIProvider` 是所有网络请求的单一入口。

### 职责：

- 统一的请求接口
- Async/await 桥接
- 请求取消处理
- 插件系统（日志、计时、调试）
- 会话配置管理

### 特性：

- 单例共享实例
- 自定义 `URLSession` 配置
- 仅在调试模式启用的日志插件
- 原生 Swift 并发支持
- 默认支持通过 SwiftyJSON 进行动态 JSON 解码

---

## 2. 请求系统

框架将 Moya 的回调式 API 封装为 Swift 的结构化并发。

### 关键技术：

- `withCheckedThrowingContinuation`
- `withTaskCancellationHandler`
- 线程安全的可取消对象管理

### 能力：

- 协作式取消
- 安全的延续处理
- 统一的响应抽象

### 平台锁说明

当前 Package 支持 iOS 13+ 与 macOS 10.15+，因此 async 请求封装中使用基于 `NSLock` 的 `LockIsolated` 辅助类型来保护可取消请求状态。

如果你的项目只支持 iOS 16+ 与 macOS 13+，可以直接使用 Swift 提供的 `OSAllocatedUnfairLock`。

---

## 3. 响应映射系统

将所有后端响应规范化为统一格式：

```json
{
  "code": 0,
  "message": "success",
  "data": {},
  "request_id": "xxx"
}
```

### 映射流程：

```
HTTP 响应（状态 200）
        ↓
BaseResponse<T>
        ↓
业务码校验（code == 0）
        ↓
数据提取
        ↓
可解码模型
```

当前实现中，HTTP 状态码必须是 `200`，业务成功码是 `0`，未定义业务码会包装为 `XXXNetworkWrappedError`。

---

# 🧭 API 命名空间设计

为支持大规模 API，框架引入基于命名空间的 API 组织方式。

## 问题

单一的 `XXXAPI` 枚举随着使用将会：
- 难以维护（case越来越多，文件越来越大）
- 难以导航
- 高合并冲突风险（不同的业务更改同一个文件）

## 解决方案

按领域分组 API：

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

## 益处
- 📦 清晰的领域边界
- 🔍 更佳的代码补全体验
- 🧩 更易模块化
- 👥 降低团队合并冲突

---

# ⚠️ 错误处理系统

## 统一的错误协议

所有网络错误均遵循统一协议，包括：

- 服务器错误
- 传输层错误
- 包装的自定义错误

### 错误类型：
| 层级        | 错误类型              |
|-------------|---------------------|
| HTTP 层     | 网络 / 传输错误       |
| 业务层      | 服务端定义的错误码      |
| 兜底层      | 包装的自定义错误       |

---

## 错误分层策略
```

    Error
    └── XXXNetworkError (统称网络错误)
            ├── XXXNetworkMoyaError (传输层错误)
            ├── XXXNetworkServerError (业务码错误)
            └── XXXNetworkWrappedError (兜底/未知)
    
```
---

# 🧪 测试驱动的 API 接入

API 对接从测试开始。

如果不是强制开发是不愿意写测试用例的。因此设计在对接时写测试用例的方式。这不但会加快对接流程，因为不再需要每次都启动整个App，只要跑单个测试方法。最后对接完测试用例也就自动的写好了。测试用例的编写不再是额外的工作，而是成了正常流程的一环。之后写其他的API，全部测试还能发现后端以前接口的失误。

## 概念

不再在业务逻辑中调试 API 调用：

👉 先编写测试用例以完成 API 对接

## 示例
```swift
import Testing
@testable import XXXNetworkKit
@testable import XXXNetworkModel

@Suite
struct UserTest {
  
    @Test
    func info() async throws {
        let user = try await XXXAPIProvider.shared.request(XXXAPI.User.info, to: User.self)
        #expect(user.openid != nil)
    }


    @Test
    func union_id() async throws {
        let result = try await XXXAPIProvider.shared.request(XXXAPI.User.union_id)
        #expect(result["union_id"].string != nil)
    }
}
```

## 优势
- ✅ 无 UI 依赖
- ✅ 调试更快
- ✅ 更早验证后端接口
- ✅ 强类型安全校验



# 🔄 推荐工作流

```
定义 API（命名空间）
        ↓
编写测试用例
        ↓
完成 API 接入
        ↓
开发业务逻辑 / UI
```

---

# ⚙️ 设计原则

## 1. Swift 并发优先

- 全面支持 async/await
- 任务取消的传递与响应
- 安全的延续桥接

---

## 2. 严格的 API 契约

所有后端响应必须遵循同样的统一返回结构，例如：

```json
{
  "code": Int,
  "message": String,
  "data": Any?,
  "request_id": String
}
```

这将确保：

- 统一的解析逻辑
- 集中的错误处理
- 与后端契约保持一致

当前实现中，`code == 0` 表示业务成功。其他已知业务码应补充到 `XXXNetworkServerError` 中，并和后端错误码定义保持同步。

---

## 3. 双重解码策略

### Codable（推荐）
- 高性能
- 强类型
- 适用于生产环境

### JSON 兜底
- 解析灵活
- 适应动态场景

---

## 4. 性能考量

支持动态 JSON 解析，但不建议在重负载下使用。

⚠️ 不推荐用于复杂或对性能敏感的场景
> Codable 的性能显著更高（比默认JSON类型快约 40 倍），更适合大体量或深度嵌套的响应。

---

# 🧪 使用示例

## 模型解码请求

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

## JSON 解码请求

```swift
let userJSON = try await XXXAPIProvider.shared.request(XXXAPI.User.info)
print(userJSON["name"].stringValue)
```

---

## 无返回体请求

```swift
try await XXXAPIProvider.shared.request(XXXAPI.Article.delete(ids: [1, 2, 3]))
```

如果后端省略 `data` 字段，默认 `JSON` 返回值会是 `JSON.null`。

---

## 错误处理

遵循错误范围从小到大的过程，且遵循从上层发起到上层处理的逻辑，不将处理错误的逻辑在整个流程写的到处都是

```swift
do {
    try await XXXAPIProvider.shared.request(...)
    print("请求完成")
} catch XXXNetworkServerError.serverException {
    // 处理特定的业务错误，通常用于展示给用户的提示信息
    // 例如密码输入错误，把输入框标红
    doSomeThing(error)
} catch let error as XXXNetworkError where error.isNetworkConnectError {
    // 使用 where 子句筛选网络连接相关错误
    showToast("网络连接错误")
} catch let error as XXXNetworkError {
    // 统一处理网络模块的所有错误
    print("code: \(error.errorCode)")
} catch {
    // 处理非网络错误
    print("未知错误: \(error.localizedDescription)")
}
```

---

# 🧩 可扩展性

该框架支持：

- 自定义插件（日志 / 指标 / 链路追踪）
- 使用 TimeoutPlugin 定制请求超时行为
- 使用 retry / poll 辅助异步重试与轮询流程
- 自定义错误映射
- 可替换的解码策略
- 多目标路由

---

# 🛠 如何变成你自己的网络库

这个仓库更适合作为起点被复制、改名、替换契约，而不是作为一个永远叫 `XXXNetworkKit` 的外部依赖。

推荐步骤：

1. 将 `XXXNetworkKit`、`XXXAPI`、错误域等命名替换为你的 App 或公司前缀。
2. 用自己的业务域替换示例 API，例如 `XXXAPI.User`、`XXXAPI.Article`。
3. 根据后端统一返回结构，调整 `Response.mapResult(to:)` 中的 `BaseResponse<T>`。
4. 用真实后端业务码替换 `XXXNetworkServerError`。
5. 决定 `XXXNetworkModel` 是保留为独立 target，还是移动到 App / 业务模块中。
6. 保留测试驱动接入流程：每新增一个 API，同时补一个聚焦的接口测试。

完成这些步骤后，它就不再是一个示例库，而是你项目自己的网络层基础设施。

---

# 🚀 总结

XXXNetworkKit 是一套可用于生产的网络架构，它：

- 通过单一 API 提供者统一网络请求
- 标准化后端响应格式
- 集中化错误处理
- 原生支持 async/await 并发模型
- 为大型 iOS 应用提供可扩展、可演进的架构
