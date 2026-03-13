# iOS 客户端技术文档

> 基于 Telegram 官方 iOS 开源代码，通过 CocoaPods 将 ~344 个模块以本地 pod 形式组织。
> OwnPod 为自定义 App 壳工程（作者 thunder, 2023-12-14 创建）。

---

## 目录

- [技术栈](#技术栈)
- [分层架构](#分层架构)
- [目录结构](#目录结构)
- [模块分类](#模块分类)
- [SwiftSignalKit 响应式框架详解](#swiftsignalkit-响应式框架详解)
- [网络层](#网络层)
- [协议与序列化](#协议与序列化)
- [TelegramEngine — 业务门面](#telegramengine--业务门面)
- [AccountContext — 依赖注入](#accountcontext--依赖注入)
- [UI 框架体系](#ui-框架体系)
- [PostboxKit — 本地持久化](#postboxkit--本地持久化)
- [App 入口与启动流程](#app-入口与启动流程)
- [代码规模参考](#代码规模参考)
- [开发备忘](#开发备忘)

---

## 技术栈

| 组件           | 技术                                                |
|:---------------|:---------------------------------------------------|
| 语言           | Swift（~2,865 文件）+ Objective-C/C++（~755 文件，~1,641 头文件）|
| 最低系统版本    | iOS 13.0（Podfile），个别 podspec 写 iOS 11.0        |
| UI 框架        | AsyncDisplayKit（Texture fork）+ Display + ComponentFlow |
| 响应式框架     | SwiftSignalKit（自研，非 RxSwift/Combine）            |
| 网络协议       | MTProto 2.0（MtProtoKit, ObjC 实现）                |
| 本地数据库     | SQLCipher（加密 SQLite, PostboxKit 封装）            |
| 序列化         | TL（Type Language）自定义二进制协议                   |
| 包管理         | CocoaPods（344 本地 pod + Stripe 外部 pod）          |
| 构建工具       | Xcode，使用 `OwnPod.xcworkspace`                    |
| 支付           | Stripe / StripeApplePay（唯一外部 pod 依赖）         |

---

## 分层架构

```
┌────────────────────────────────────────────────────────────────┐
│                    Layer 4: Feature UI                          │
│  ChatListUI / SettingsUI / PeerInfoUI / PremiumUI / ...        │
│  (~60+ 独立 UI 模块, 每个功能页面一个 Pod)                      │
│  代表文件: ChatController.swift (18,418 行, 92 个 import)       │
├────────────────────────────────────────────────────────────────┤
│                  Layer 3: Presentation                          │
│  AccountContextKit — 依赖注入容器 (AccountContext 协议)         │
│  Display — 导航/弹窗/列表 (自定义, 非 UIKit 导航)              │
│  ComponentFlow — 声明式组件 (类 SwiftUI 概念, 基于 UIKit)      │
│  AsyncDisplayKit — 异步渲染引擎 (Texture fork, ObjC++)         │
│  TelegramPresentationData — 主题/本地化/外观                   │
├────────────────────────────────────────────────────────────────┤
│                 Layer 2: Business Logic                         │
│  TelegramCore — 核心业务 (561 Swift 文件)                      │
│    TelegramEngine (门面): Auth / Messages / Peers / Contacts   │
│                           Stickers / Payments / Privacy / Calls│
│    Network/ — 连接管理, 分片传输, 带宽统计                      │
│    State/ — 应用状态同步, 更新管理                              │
│    SecretChats/ — 端到端加密                                    │
├────────────────────────────────────────────────────────────────┤
│                   Layer 1: Core / Data                          │
│  TelegramApi — TL Schema 自动生成 (31 文件, 47,124 行)         │
│  MtProtoKit — MTProto 传输/加密 (ObjC, DH 密钥交换, AES-IGE)  │
│  PostboxKit — 本地持久化 (SQLCipher + 自定义二进制编码)         │
│  SwiftSignalKit — 响应式编程 (Signal/Promise/Disposable)       │
│  SSignalKit — ObjC 响应式 (SwiftSignalKit 的 ObjC 对应版)     │
└────────────────────────────────────────────────────────────────┘
```

### 核心设计模式

- **信号驱动/响应式**：所有数据流通过 `SwiftSignalKit` 的 `Signal<T, E>` 管道，用 `|>` 操作符组合，非 delegate / callback
- **门面模式**：`TelegramEngine` 是访问所有业务逻辑的统一入口，内含懒加载子引擎
- **依赖注入**：`AccountContext` 协议持有应用绑定、presentation 数据、媒体管理器等所有依赖
- **超模块化**：344 个 CocoaPod，每个有独立 podspec + xcodeproj，清晰的依赖边界

---

## 目录结构

```
pods/
├── OwnPod/                       # App 壳工程
│   ├── main.m                    #   ObjC 入口（@import TelegramUI, UIApplicationMain）
│   ├── AppDelegate.swift         #   应用代理（标准 UIKit Scene 生命周期）
│   ├── ViewController.swift      #   依赖验证控制器（导入 43 个框架）
│   ├── SceneDelegate.swift       #   Scene 代理
│   ├── OwnPod-Bridging-Header.h  #   桥接头文件（空）
│   ├── PresentationStrings.data  #   本地化二进制数据（177KB）
│   ├── NSMutableArray+hello.h/.m #   测试 ObjC 分类
│   └── Resources1/, Resources2/  #   资源 bundle
│
├── TGFramework/                  # ~344 个本地 Pod 模块
│   │
│   │── ─── 核心/传输层 ───
│   ├── MtProtoKit/               #   MTProto 协议（ObjC）
│   │   └── Sources/              #     MTProto, MTProtoEngine, MTContext
│   │                             #     MTDatacenterAuthAction (DH 密钥交换)
│   │                             #     MTNetworkAvailability, GCDAsyncSocket
│   ├── TelegramApi/              #   TL Schema 生成（Swift）
│   │   └── Sources/              #     Api0.swift ~ Api30.swift (31 文件, 47,124 行)
│   │                             #     Int32 constructor ID → Parser 字典
│   ├── CryptoUtils/              #   加密工具
│   ├── OpenSSLEncryptionProvider/ #  OpenSSL 封装
│   ├── EncryptionProviderKit/    #   加密提供者协议
│   ├── PKCS/                     #   PKCS 标准实现
│   │
│   │── ─── 响应式框架 ───
│   ├── SwiftSignalKit/           #   响应式编程（Swift, ~20 源文件）
│   │   └── Source/               #     Signal, Promise, ValuePromise
│   │                             #     Subscriber, Disposable, MetaDisposable
│   │                             #     Queue, Atomic, Bag, Timer
│   │                             #     操作符: map, flatMap, filter, combine(2-19路)
│   │                             #     distinctUntilChanged, reduce, take, delay
│   ├── SSignalKit/               #   ObjC 响应式对应版
│   │
│   │── ─── 数据/持久化 ───
│   ├── PostboxKit/               #   本地数据库（Swift）
│   │   └── Sources/              #     Postbox (SQLCipher 数据库管理)
│   │                             #     PostboxCoding (自定义二进制序列化)
│   │                             #     PostboxEncoder/PostboxDecoder
│   │                             #     MemoryBuffer/WriteBuffer/ReadBuffer
│   │                             #     declareEncodable (MurMurHash32 类型注册)
│   ├── sqlcipher/                #   加密 SQLite
│   ├── CloudDataKit/             #   云数据同步
│   │
│   │── ─── 核心业务逻辑 ───
│   ├── TelegramCore/             #   核心业务（561 Swift 文件）
│   │   └── Sources/
│   │       ├── TelegramEngine/   #     门面模式入口
│   │       │   ├── Auth/         #       登录/注册/验证码
│   │       │   ├── Messages/     #       消息收发/编辑/删除/搜索
│   │       │   ├── Peers/        #       用户/群/频道信息
│   │       │   ├── Contacts/     #       联系人管理
│   │       │   ├── Stickers/     #       贴纸包
│   │       │   ├── Payments/     #       支付
│   │       │   ├── Privacy/      #       隐私设置
│   │       │   └── Calls/        #       音视频通话
│   │       ├── Network/          #     网络管理
│   │       │   ├── Network.swift #       连接状态/MTProto 桥接 (1,131 行)
│   │       │   ├── MultipartFetch.swift   #  分片下载
│   │       │   └── MultipartUpload.swift  #  分片上传
│   │       ├── State/            #     应用状态同步
│   │       ├── SecretChats/      #     端到端加密
│   │       └── Account/          #     账号管理
│   ├── TelegramNotices/          #   通知处理
│   ├── TelegramPermissions/      #   权限管理
│   │
│   │── ─── UI 基础 ───
│   ├── AsyncDisplayKit/          #   异步 UI 渲染（ObjC++, Texture fork）
│   │                             #     ASDisplayNode, ASLayoutSpec
│   │                             #     后台布局+渲染, 主线程上屏
│   ├── Display/                  #   高级 UI 原语（Swift）
│   │   └── Source/               #     NavigationController (89KB, 自定义导航栈)
│   │                             #     ViewController (非 UIViewController 子类)
│   │                             #     ListView (替代 UITableView)
│   │                             #     ActionSheetController, AlertController
│   │                             #     ContextMenuController
│   ├── ComponentFlow/            #   声明式组件系统（Swift）
│   │   └── Source/
│   │       ├── Base/             #     Component 协议, CombinedComponent
│   │       │                     #     ComponentState, AnyComponent 类型擦除
│   │       └── Host/             #     ComponentHostView (UIView 宿主)
│   │                             #     ComponentView (非 UIView 管理器)
│   ├── ComponentDisplayAdapters/ #   ComponentFlow ↔ Display 适配
│   ├── AccountContext/           #   依赖注入容器
│   │   └── Sources/              #     AccountContext 协议 (~1000 行)
│   │                             #     TelegramApplicationBindings (平台闭包)
│   │                             #     NavigateToChatControllerParams (25+ 字段)
│   │                             #     ResolvedUrl 枚举 (所有深链类型)
│   ├── TelegramPresentationData/ #  主题/本地化/外观
│   │
│   │── ─── 功能 UI（60+ 模块）───
│   ├── TelegramUI/               #   主 UI 协调器
│   │   └── Sources/              #     ChatController.swift (18,418 行)
│   │                             #     30+ MetaDisposable 的信号订阅管理
│   ├── ChatListUI/               #   会话列表
│   ├── SettingsUI/               #   设置页
│   ├── PeerInfoUI/               #   用户/群信息页
│   ├── ContactListUI/            #   联系人列表
│   ├── PremiumUI/                #   Premium 功能页
│   ├── PassportUI/               #   Passport 身份验证
│   ├── GalleryUI/                #   图片/视频浏览
│   ├── LocationUI/               #   位置分享
│   ├── BotPaymentsUI/            #   Bot 支付
│   ├── DrawingUI/                #   绘图编辑
│   ├── BrowserUI/                #   内置浏览器
│   │
│   │── ─── 媒体（~25 模块）───
│   ├── FFMpegBinding/            #   FFmpeg 视频/音频解码
│   ├── OpusBinding/              #   Opus 音频编解码（语音消息）
│   ├── RLottieBinding/           #   Lottie 动画渲染
│   ├── WebPBinding/              #   WebP 图片格式
│   ├── MozjpegBinding/           #   JPEG 优化压缩
│   ├── TgVoipWebrtc/             #   WebRTC 音视频通话
│   ├── vpx/                      #   VP8/VP9 视频编解码
│   ├── YuvConversion/            #   YUV 色彩空间转换
│   │
│   │── ─── UI 组件（~80 模块）───
│   ├── AvatarNodeKit/            #   头像节点
│   ├── SwitchNode/               #   开关组件
│   ├── SolidRoundedButtonNodeKit/#   圆角按钮
│   ├── ... (更多 *Kit / *Node / *Component)
│   │
│   │── ─── 工具（~30 模块）───
│   ├── Crc32/                    #   CRC32 校验
│   ├── GZip/                     #   GZip 压缩
│   ├── Emoji/                    #   Emoji 处理
│   ├── StringTransliteration/    #   字符串转写
│   ├── MergeLists/               #   列表差分合并
│   │
│   │── ─── 遗留（~4 模块）───
│   ├── LegacyComponents/         #   ObjC 遗留 UI（大量 ObjC 代码）
│   ├── LegacyUI/                 #   遗留 UI 适配
│   ├── LegacyMediaPickerUI/      #   遗留媒体选择器
│   ├── LegacyReachability/       #   遗留网络可达性
│   │
│   └── kit.py                    #   构建辅助脚本（arm64 排除管理, 含中文注释）
│
├── Podfile                       # CocoaPods 清单（344 本地 pod, use_frameworks!）
├── Podfile.lock                  # 锁定版本（所有本地 pod 版本 0.0.1）
├── Pods/                         # CocoaPods 输出（Stripe, 支持文件）
├── OwnPod.xcworkspace/           # Xcode 工作区 ← 用这个打开
├── OwnPod.xcodeproj/            # Xcode 工程（199KB pbxproj）
├── DerivedData/                  # Xcode 构建缓存
└── README                        # 空文件
```

---

## 模块分类

| 分类         | 示例模块                                                     | 数量    |
|:-------------|:------------------------------------------------------------|:--------|
| 核心/传输    | MtProtoKit, TelegramApi, CryptoUtils, OpenSSL, PKCS         | ~10     |
| 数据/持久化  | PostboxKit, sqlcipher, CloudDataKit                          | ~5      |
| 业务逻辑    | TelegramCore, TelegramNotices, TelegramPermissions            | ~8      |
| 响应式      | SwiftSignalKit, SSignalKit                                    | 2       |
| UI 基础     | AsyncDisplayKit, Display, ComponentFlow, ComponentDisplayAdapters | ~5  |
| 功能 UI     | ChatListUI, SettingsUI, PeerInfoUI, PremiumUI, GalleryUI...   | ~60+    |
| UI 组件     | AvatarNodeKit, SwitchNode, SolidRoundedButtonNodeKit...       | ~80+    |
| 媒体        | FFMpegBinding, OpusBinding, RLottieBinding, WebPBinding...    | ~25     |
| 工具        | Crc32, GZip, Emoji, StringTransliteration, MergeLists...     | ~30     |
| 遗留        | LegacyComponents, LegacyUI, LegacyMediaPickerUI              | ~4      |

---

## SwiftSignalKit 响应式框架详解

位置：`TGFramework/SwiftSignalKit/SwiftSignalKit/Source/`（~20 源文件）

这是整个项目的基石框架，所有异步操作和数据流都基于它。**理解 SwiftSignalKit 是理解整个代码库的前提。**

### Signal<T, E> — 核心信号类型

```swift
public final class Signal<T, E> {
    private let generator: (Subscriber<T, E>) -> Disposable

    // 工厂方法
    static func single(_ value: T) -> Signal<T, E>      // 发一个值就完成
    static func complete() -> Signal<T, NoError>          // 直接完成
    static func fail(_ error: E) -> Signal<T, E>          // 直接报错
    static func never() -> Signal<T, E>                   // 永不发射

    // 订阅
    func start(next: (T)->Void, error: (E)->Void, completed: ()->Void) -> Disposable
}
```

- **冷信号**（Cold Observable）：每次 `start()` 都执行一次 generator
- **引用类型**（`class`，不是 `struct`）：可以直接存储，无需 boxing
- **`NoError`** / **`NoValue`**：空枚举，用作幻象类型，表示不会出错 / 不会发值

### Pipe 操作符 `|>`

```swift
// 自定义中缀操作符，用于函数式链式组合
precedencegroup PipeRight { associativity: left, higherThan: DefaultPrecedence }
infix operator |> : PipeRight

// 使用示例
let signal = someSignal
    |> map { $0.name }
    |> filter { !$0.isEmpty }
    |> distinctUntilChanged
    |> deliverOnMainQueue
```

所有操作符都是**自由函数**返回柯里化闭包 `(Signal<T, E>) -> Signal<R, E>`，设计用于 `|>` 组合。这与 RxSwift 的方法链式（`.map{}.filter{}`）风格不同。

### Promise / ValuePromise — 响应式属性

```swift
// Promise<T>: 信号支持的属性容器
let promise = Promise<User>()
promise.set(fetchUserSignal)        // 绑定到一个信号
promise.get() -> Signal<User, NoError>  // 获取响应式信号（含缓存值）

// ValuePromise<T: Equatable>: 简单值属性容器
let value = ValuePromise<String>("initial", ignoreRepeated: true)
value.set("new")                    // 直接设值
value.get() -> Signal<String, NoError>  // 获取信号（自动去重）
```

- `Promise` 类似 RxSwift 的 `BehaviorRelay`，但底层是信号订阅
- `ValuePromise` 更轻量，直接持有值，有 `ignoreRepeated` 去重选项
- 两者都用 POSIX `pthread_mutex_t` 做线程同步

### Subscriber / Disposable — 生命周期管理

- **`Subscriber<T, E>`**：管理 next/error/completed 回调，`pthread_mutex_t` 保护 `terminated` 标志
- **`Disposable` 协议**：`dispose()` 方法，class-only
- **`MetaDisposable`**：可替换内部 disposable（旧的自动 dispose）。**整个代码库最常用的 Disposable 类型**
- **`DisposableSet`**：批量持有，统一 dispose
- **`DisposableDict<T: Hashable>`**：按 key 管理
- **`ActionDisposable`**：闭包包装，dispose 时执行一次

`withExtendedLifetime` 用于确保闭包在 mutex 锁外释放，避免析构函数中的死锁。

### Queue — 线程模型

```swift
public final class Queue {
    static func mainQueue() -> Queue
    static func concurrentDefaultQueue() -> Queue
    static func concurrentBackgroundQueue() -> Queue

    func isCurrent() -> Bool    // 通过 DispatchSpecificKey 判断
    func async(_ f: @escaping ()->Void)  // 已在目标队列则直接执行（优化！）
    func sync(_ f: ()->Void)    // 同上优化
    func justDispatch(_ f: ...)  // 总是异步 dispatch
    func after(_ delay: Double, _ f: ...)  // 延迟执行
}
```

关键优化：**"如果已经在目标队列就直接执行"**。避免不必要的队列跳转和线程上下文切换。整个代码库大量依赖此优化。

### 常用操作符

| 操作符                    | 说明                           |
|:-------------------------|:-------------------------------|
| `map { }`                | 值变换                         |
| `filter { }`             | 值过滤                         |
| `flatMap { }`            | Optional 值变换（nil 透传）     |
| `mapError { }`           | 错误类型变换                   |
| `castError(Type.self)`   | 从 NoError 转换到任意错误类型   |
| `distinctUntilChanged`   | 去重（Equatable 或自定义比较）  |
| `combineLatest(s1, s2, ...)` | 2~19 路信号合并（暴力泛型重载）|
| `deliverOnMainQueue`     | 切到主线程                     |
| `deliverOn(queue)`       | 切到指定 Queue                 |
| `take(1)`                | 只取第一个值                   |
| `delay(seconds, queue)`  | 延迟发射                       |
| `throttle(seconds)`      | 节流                           |
| `reduceLeft(value:f:)`   | 归约                           |

`combineLatest` 有 **17 个重载**（2 路到 19 路），内部通过类型擦除到 `Any` + 强制转换实现。

---

## 网络层

### MTProto 传输层（MtProtoKit, ObjC）

位置：`TGFramework/MtProtoKit/MtProtoKit/Sources/`

| 类                         | 职责                          |
|:---------------------------|:------------------------------|
| `MTProto`                  | 协议引擎主类                   |
| `MTProtoEngine`            | 引擎封装                      |
| `MTContext`                | 数据中心上下文（序列化/加密/API 环境/代理）|
| `MTDatacenterAuthAction`   | DH 密钥交换                   |
| `MTBindKeyMessageService`  | 临时密钥绑定                   |
| `MTNetworkAvailability`    | 网络可达性监控                 |
| `GCDAsyncSocket`           | TCP 连接（异步 Socket）        |
| `AFHTTPRequestOperation`   | HTTP 回退传输                  |

功能：
- 数据中心发现（DNS, 配置）
- DH 密钥交换 + AES-256-IGE 消息加密
- 多种传输：TCP（GCDAsyncSocket）、HTTP 回退
- CDN 加速媒体传输
- 盐值管理、连接探测、自动重连

### 应用网络管理（TelegramCore/Network/）

位置：`TGFramework/TelegramCore/TelegramCore/Sources/Network/Network.swift`（1,131 行）

```swift
enum ConnectionStatus {
    case waitingForNetwork
    case connecting(proxyAddress: String?, proxyHasConnectionIssues: Bool)
    case updating(proxyAddress: String?)
    case online(proxyAddress: String?)
}
```

**网络初始化**：`initializedNetwork(...)` 函数返回 `Signal<Network, NoError>`，创建 `MTContext`，配置加密提供者（OpenSSL）、API 环境、代理、种子地址。

**NetworkInitializationArguments**：

```swift
struct NetworkInitializationArguments {
    let apiId: Int32
    let apiHash: String
    let languagesCategory: String
    let appVersion: String
    let voipMaxLayer: Int32
    let voipVersions: [CallSessionManagerImplementationVersion]
    let encryptionProvider: EncryptionProvider   // OpenSSL
    let appData: Signal<Data?, NoError>          // 响应式应用数据
    let autolockDeadline: Signal<Int32?, NoError> // 响应式自动锁定
}
```

**带宽统计**：
```swift
// 追踪 8 种流量类型 × 2 种连接 × 2 种方向
enum UsageCalculationTag { generic, image, video, audio, file, call, stickers, voiceMessages }
enum UsageCalculationConnection { wifi, cellular }
enum UsageCalculationDirection { incoming, outgoing }
```

### API 请求完整调用链

```
// 1. 业务层调用
engine.messages.sendMessage(...)

// 2. TelegramEngine 子引擎分发
→ TelegramCore/Sources/TelegramEngine/Messages/SendMessage.swift
→ _internal_sendMessage(...)

// 3. 构造 TL 函数类型
→ Api.functions.messages.sendMessage(
      peer: inputPeer,
      message: text,
      random_id: randomId, ...
   )

// 4. 通过 Network 发送
→ account.network.request(api)
→ 返回 Signal<Api.Updates, MTRpcError>

// 5. MTProtoKit 序列化 + 加密 + TCP 发送
→ MTProto → BufferWriter (TL 二进制序列化)
→ AES-IGE 加密
→ 传输编码 (Abridged/Intermediate/...)
→ GCDAsyncSocket TCP 发送

// 6. 服务端处理
→ Gateway (10443/5222/8801) → Session → BFF → msg
```

所有调用通过 `SwiftSignalKit` 的 `Signal` 管道驱动，订阅返回 `Disposable`。

---

## 协议与序列化

### TL（Type Language）— 线上二进制协议

**不是 JSON、不是 Protobuf、不是 REST**。Telegram 自研的二进制序列化。

位置：`TGFramework/TelegramApi/TelegramApi/Sources/`（31 文件，Api0.swift ~ Api30.swift，47,124 行）

```swift
// 类型通过 constructor ID (Int32 哈希) 标识
// 全局解析器字典
dict[-1132882121] = { return Api.Bool.parse_boolFalse($0) }
dict[-1720552011] = { return Api.Bool.parse_boolTrue($0) }

// API 命名空间
Api.account, Api.auth, Api.channels, Api.contacts, Api.help,
Api.messages, Api.payments, Api.phone, Api.photos, Api.stats,
Api.stickers, Api.storage, Api.updates, Api.upload, Api.users

// 函数命名空间
Api.functions.auth.sendCode(...)
Api.functions.messages.sendMessage(...)
Api.functions.users.getFullUser(...)
```

通过 `BufferReader` / `Buffer` 类进行二进制读写。

### MTProto 2.0 协议栈

```
┌──────────────────────────────────────────────────────┐
│  应用层    │ TL 二进制序列化                           │
│           │ constructor ID (Int32) + 字段二进制编码    │
├──────────────────────────────────────────────────────┤
│  加密层    │ AES-256-IGE 加密                         │
│           │ auth_key (256 字节) + msg_key 派生         │
├──────────────────────────────────────────────────────┤
│  传输层    │ Abridged / Intermediate / Padded / Full   │
│           │ Obfuscated (AES-CTR-128 包裹内层)         │
├──────────────────────────────────────────────────────┤
│  网络层    │ TCP (端口 10443/5222/8801) / HTTP 回退    │
└──────────────────────────────────────────────────────┘
```

---

## TelegramEngine — 业务门面

位置：`TGFramework/TelegramCore/TelegramCore/Sources/TelegramEngine/`

`TelegramEngine` 是所有业务逻辑的统一入口，子引擎按需懒加载：

| 子引擎               | 访问方式           | 典型方法                                     |
|:--------------------|:------------------|:---------------------------------------------|
| Auth                | `engine.auth`     | `sendCode()`, `signIn()`, `signUp()`, `logOut()` |
| Messages            | `engine.messages` | `sendMessage()`, `deleteMessages()`, `getHistory()`, `searchMessages()` |
| Peers               | `engine.peers`    | `getUser()`, `getChat()`, `updatePeerTitle()` |
| Contacts            | `engine.contacts` | `importContacts()`, `getContacts()`, `addContact()` |
| Stickers            | `engine.stickers` | `getStickerPacks()`, `addStickerPack()` |
| Payments            | `engine.payments` | `getBankCardInfo()`, `sendPaymentForm()` |
| Privacy             | `engine.privacy`  | `getPrivacySettings()`, `updatePrivacy()` |
| Calls               | `engine.calls`    | `requestCall()`, `acceptCall()` |

**使用模式**：
```swift
// 所有返回 Signal，通过 |> 组合
let signal = engine.messages.sendMessage(
    peerId: peerId,
    text: "Hello",
    ...
)
|> deliverOnMainQueue

let disposable = signal.start(next: { result in
    // 处理结果
}, error: { error in
    // 处理错误
})

// disposable 需要被持有，释放时自动取消
```

内部每个方法调用 `_internal_*` 辅助函数 → `account.network.request(Api.functions.*)` → 返回 Signal。

---

## AccountContext — 依赖注入

位置：`TGFramework/AccountContext/AccountContext/Sources/AccountContext.swift`（~1000 行）

### AccountContext 协议

这是整个 UI 层的核心依赖注入容器：

```swift
protocol AccountContext: AnyObject {
    var sharedContext: SharedAccountContext { get }
    var account: Account { get }
    var engine: TelegramEngine { get }

    // 管理器
    var liveLocationManager: LiveLocationManager? { get }
    var peersNearbyManager: PeersNearbyManager? { get }
    var fetchManager: FetchManager { get }
    var downloadedMediaStoreManager: DownloadedMediaStoreManager { get }
    var wallpaperUploadManager: WallpaperUploadManager? { get }
    var watchManager: WatchManager? { get }
    var inAppPurchaseManager: InAppPurchaseManager? { get }

    // 原子配置（线程安全，Atomic<T>）
    var currentLimitsConfiguration: Atomic<LimitsConfiguration> { get }
    var currentContentSettings: Atomic<ContentSettings> { get }
    var currentAppConfiguration: Atomic<AppConfiguration> { get }
    var currentCountriesConfiguration: Atomic<CountriesConfiguration> { get }

    // 缓存
    var animationCache: AnimationCache { get }
    var animationRenderer: MultiAnimationRenderer { get }

    // 方法
    func storeSecureIdPassword(password: String)
    func chatLocationInput(for location: ChatLocation, ...) -> Signal<...>
    func scheduleGroupCall(peerId: PeerId)
    func joinGroupCall(peerId: PeerId, ...)
    func requestCall(peerId: PeerId, isVideo: Bool, ...)
}
```

### TelegramApplicationBindings

平台绑定闭包集合（应用级别的依赖）：

```swift
struct TelegramApplicationBindings {
    let openUrl: (String) -> Void
    let canOpenUrl: (String) -> Bool
    let getTopWindow: () -> UIWindow?
    let displayNotification: (String) -> Void
    let applicationInForeground: Signal<Bool, NoError>
    let applicationIsActive: Signal<Bool, NoError>
    // ... 更多平台绑定
}
```

### 导航参数

```swift
struct NavigateToChatControllerParams {
    let context: AccountContext
    let chatLocation: ChatLocation
    let subject: ChatControllerSubject?
    let botStart: ChatControllerInitialBotStart?
    let peekData: ChatPeekTimeout?
    // ... 25+ 字段
}
```

### ResolvedUrl — 深链类型

```swift
enum ResolvedUrl {
    case peer(PeerId?, ...)
    case inaccessiblePeer
    case botStart(peerId: PeerId, payload: String)
    case stickerPack(name: String)
    case join(String)          // 群组邀请链接
    case proxy(host:port:...)  // 代理配置
    case settings(SettingsSection)
    // ... 更多深链类型
}
```

---

## UI 框架体系

本项目有三套并存的 UI 体系，层层递进：

### 1. AsyncDisplayKit（底层渲染引擎）

位置：`TGFramework/AsyncDisplayKit/`（ObjC++，Texture fork）

- **`ASDisplayNode`**：替代 `UIView`，支持后台线程计算布局和渲染
- **`ASLayoutSpec`**：Flexbox 风格布局系统
- 主线程只做最终上屏，实现流畅 60fps 滚动
- 这是 Facebook 开发的 Texture 框架的 fork 版本

### 2. Display（中层 UI 原语）

位置：`TGFramework/Display/Display/Display/Source/`

**整个导航系统是自定义的**，不使用 UIKit 的 `UINavigationController`：

| 组件                      | 说明                                           |
|:-------------------------|:-----------------------------------------------|
| `NavigationController`   | 自定义导航栈（89KB 源码），支持 Master-Detail 布局 |
| `ViewController`         | 非 UIViewController 子类，Display 框架自己的控制器基类 |
| `ListView`               | 替代 UITableView/UICollectionView              |
| `ActionSheetController`  | 底部操作表                                     |
| `AlertController`        | 弹窗                                           |
| `ContextMenuController`  | 长按上下文菜单                                  |
| `ControllerRecord`       | 跟踪控制器和转场状态                            |

`NavigationControllerMode`：`.single`（普通导航）或 `.automaticMasterDetail`（iPad 分屏）。

### 3. ComponentFlow（上层声明式组件）

位置：`TGFramework/ComponentFlow/ComponentFlow/Source/`

类 SwiftUI 概念，但构建在 UIKit 之上：

#### Component 协议

```swift
protocol Component: Equatable {
    associatedtype EnvironmentType
    associatedtype View: UIView
    associatedtype State: ComponentState

    func makeView() -> View              // 创建视图
    func makeState() -> State            // 创建状态
    func update(                         // 更新/布局
        view: View,
        availableSize: CGSize,
        state: State,
        environment: EnvironmentType,
        transition: ComponentTransition
    ) -> CGSize
}
```

- `ComponentState` 有 `updated(transition:)` 方法触发重绘
- `AnyComponent<EnvironmentType>` 通过 `_TypeErasedComponent` 做类型擦除
- 上下文通过 `objc_setAssociatedObject` 关联到 View

#### CombinedComponent — 组合组件

```swift
protocol CombinedComponent: Component {
    // 类似 SwiftUI 的 body，返回布局尺寸
    static var body: Body { get }
}
```

子组件通过 Builder 模式定位：
```swift
childComponent
    .position(CGPoint(x: 10, y: 20))   // 位置
    .opacity(0.8)                       // 透明度
    .scale(1.2)                         // 缩放
    .clipsToBounds(true)                // 裁剪
    .appear(.default(alpha: true))      // 出现动画
    .disappear(.default(alpha: true))   // 消失动画
```

支持 Guides 跨组件动画协调、出现/消失/更新过渡动画。

#### ComponentHostView — 宿主视图

```swift
class ComponentHostView<EnvironmentType>: UIView {
    func update(
        transition: ComponentTransition,
        component: AnyComponent<EnvironmentType>,
        environment: EnvironmentType,
        containerSize: CGSize
    ) -> CGSize
}
```

- 缓存当前组件/容器尺寸/渲染尺寸，未变化时跳过更新
- `hitTest` 透传到子视图，自身返回 `nil`（透明容器）
- 状态变化通过 `componentState._updated` 触发自动重绘

---

## PostboxKit — 本地持久化

位置：`TGFramework/PostboxKit/PostboxKit/Sources/`

### 自定义二进制序列化（PostboxCoding）

```swift
protocol PostboxCoding {
    init(decoder: PostboxDecoder)
    func encode(_ encoder: PostboxEncoder)
}

// 类型注册（全局）
declareEncodable(MyType.self) { MyType(decoder: $0) }
// 内部: murMurHashString32("MyType") 作为类型 ID
```

### 编码格式

每个字段为 Key-Value 对：
```
[keyLength: Int8] [keyBytes...] [valueType: Int8] [valueData...]
```

对象编码：
```
[typeHash: Int32] [dataLength: Int32] [encodedData...]
```

### 内存管理

```swift
class MemoryBuffer {
    var memory: UnsafeMutableRawPointer  // 手动 malloc/free
    var capacity: Int
    var length: Int
}

class WriteBuffer: MemoryBuffer {
    // 初始 32 字节, 每次增长 256 字节
}

class ReadBuffer: MemoryBuffer {
    var offset: Int  // 顺序读取位置
}
```

### PostboxEncoder 支持的类型

| 方法                    | 值类型               |
|:----------------------|:---------------------|
| `encodeInt32`         | Int32                |
| `encodeInt64`         | Int64                |
| `encodeBool`          | Bool                 |
| `encodeDouble`        | Double               |
| `encodeString`        | String               |
| `encodeObject`        | PostboxCoding 对象   |
| `encodeObjectArray`   | [PostboxCoding]      |
| `encodeObjectDictionary` | [String: PostboxCoding] |
| `encodeBytes`         | MemoryBuffer 原始字节 |
| `encodeCodable`       | Codable（JSON 编码后存储）|
| `encodeNil`           | 空值标记              |

数据库：SQLCipher（加密 SQLite），PostboxKit 封装了完整的数据库操作。

---

## App 入口与启动流程

### 启动序列

```
main.m (ObjC)
    │  @import TelegramUI
    │  UIApplicationMain(AppDelegate)
    ▼
AppDelegate.swift
    │  标准 UIKit Scene 生命周期
    │  application:configurationForConnecting: → "Default Configuration"
    ▼
SceneDelegate.swift
    │  标准 UIWindowSceneDelegate
    ▼
ViewController.swift
    │  viewDidLoad()
    │  创建 ASDisplayNode（测试用）
    │  导入 43 个框架用于编译验证
```

### OwnPod 文件说明

| 文件                        | 说明                                        |
|:---------------------------|:--------------------------------------------|
| `main.m`                   | ObjC 入口，`@import TelegramUI`，调用 `UIApplicationMain`。含注释掉的 extension 加载代码（`dlopen` Share.appex, NotificationContent.appex 等）|
| `AppDelegate.swift`        | 标准 Scene 生命周期代理                      |
| `SceneDelegate.swift`      | 标准 Window Scene 代理                       |
| `ViewController.swift`     | **依赖验证器**：导入 43 个框架确保全部编译链接成功。创建 `ASDisplayNode` + `UILabel` 作为烟雾测试 |
| `OwnPod-Bridging-Header.h` | 空桥接头文件                                |
| `NSMutableArray+hello.h/m` | 测试 ObjC 分类                               |
| `PresentationStrings.data`  | 本地化字符串二进制数据（177KB）             |
| `Resources1/`, `Resources2/`| 资源 bundle                                |

---

## 代码规模参考

| 文件/模块          | 规模                                |
|:------------------|:------------------------------------|
| TelegramApi       | 31 文件, 47,124 行（自动生成）        |
| ChatController    | 单文件 18,418 行, 92 个 import, 30+ MetaDisposable |
| TelegramCore      | 561 个 Swift 源文件                  |
| Network.swift     | 1,131 行                            |
| AccountContext.swift | ~1,000 行                          |
| NavigationController | 89KB 源码                          |
| 整体 Swift 文件   | ~2,865 个                           |
| 整体 ObjC 文件    | ~755 个 (.m/.mm)                    |
| 整体头文件        | ~1,641 个                           |
| Podfile 模块数    | 344 个本地 pod                      |

---

## 开发备忘

### 环境与构建

- **打开工程**：**必须**使用 `OwnPod.xcworkspace`（不是 `.xcodeproj`）
- **包管理**：`pod install` 安装依赖（344 本地 pod，版本均 0.0.1）
- **模拟器构建**：`TGFramework/kit.py` 管理 arm64 排除（`python3 kit.py`）
- **唯一外部依赖**：Stripe / StripeApplePay（支付功能）
- **动态框架**：Podfile 使用 `use_frameworks!`，所有 pod 编译为动态 framework
- **Podfile 注意**：有几个重复声明（AppBundle, MultiAnimationRendererKit, CryptoUtils），`opus` 被注释掉

### 新增功能模块

```
1. TGFramework/ 下创建新目录 MyFeature/
2. 创建目录结构:
   MyFeature/
   ├── MyFeature.podspec       # 参考现有模块
   ├── MyFeature.xcodeproj/    # Xcode 工程
   └── MyFeature/Sources/      # 源代码
3. Podfile 添加: pod 'MyFeature', path: 'TGFramework/MyFeature'
4. 运行 pod install
5. 在 OwnPod 中 import 使用
```

### 业务逻辑开发

```swift
// 1. 通过 TelegramEngine 访问
let signal = context.engine.messages.sendMessage(...)

// 2. 用 |> 组合操作符
let processed = signal
    |> map { result in ... }
    |> deliverOnMainQueue

// 3. 订阅并持有 Disposable
self.sendDisposable.set(processed.start(next: { updates in
    // 处理结果
}, error: { error in
    // 处理错误
}))

// 4. MetaDisposable 自动取消旧订阅
// 在 deinit 中统一 dispose
```

### UI 开发

**ComponentFlow（推荐用于新代码）**：
```swift
final class MyComponent: Component {
    typealias EnvironmentType = Empty
    let title: String

    func makeView() -> UIView { return UIView() }
    func makeState() -> EmptyComponentState { return EmptyComponentState() }

    func update(view: UIView, availableSize: CGSize, state: EmptyComponentState,
                environment: Empty, transition: ComponentTransition) -> CGSize {
        // 布局逻辑
        return CGSize(width: availableSize.width, height: 44)
    }
}
```

**Display + AsyncDisplayKit（现有代码风格）**：
```swift
class MyNode: ASDisplayNode {
    override func didLoad() {
        super.didLoad()
        // 配置
    }

    override func layout() {
        super.layout()
        // 使用 calculatedSize 布局
    }
}
```

### 注意事项

- **不要修改 TelegramApi 的 Api*.swift 文件**：由 TL Schema 自动生成（47,124 行）
- **协议兼容性**：客户端 API Layer 必须与后端匹配（当前 Layer 166）
- **RSA 密钥**：MTProto 握手需要与服务端 `server_pkcs1.key` 配套的密钥
- **Signal 内存管理**：
  - 所有 Disposable 必须被持有（通常用 `MetaDisposable`）
  - 释放 Disposable 自动取消订阅
  - 注意闭包中的循环引用（`[weak self]`）
  - ChatController 有 30+ 个 MetaDisposable 管理各种订阅
- **ObjC/Swift 混编**：MtProtoKit（ObjC）、AsyncDisplayKit（ObjC++）、业务逻辑+上层 UI（Swift）
- **线程安全**：
  - SwiftSignalKit 使用 `pthread_mutex_t`（非 GCD/NSLock）
  - `Atomic<T>` 用于跨线程安全访问配置
  - `Queue` 的 "已在目标队列则直接执行" 优化要注意递归调用
- **NavigationController 是自定义的**：不是 UIKit 的 UINavigationController，push/pop 逻辑完全不同
- **ListView 是自定义的**：不是 UITableView/UICollectionView，API 不同
