# SwiftUI iOS Development Architecture & Coding Constraints

---

**Document Version**: v1.0.0
**Last Updated**: 2025-01-15
**Maintainer**: iOS Development Team
**Language**: English (Code comments must be in Chinese)

---

## DEFINITION OF DONE (ARCHITECTURE & CODING GATE)

A SwiftUI iOS implementation MUST NOT be considered valid unless **ALL** requirements defined in this specification are satisfied.

If **any single requirement** is not met, the code **is NOT acceptable** and must be revised until it fully complies.

---

## Table of Contents

1. [Architecture Design](#i-architecture-design)
   - [1.1 Layered Architecture](#11-layered-architecture)
   - [1.2 Directory Organization](#12-directory-organization)
   - [1.3 Simplified Architecture Principles](#13-simplified-architecture-principles)

2. [Data Flow & Models](#ii-data-flow--models)
   - [2.1 Data Model Hierarchy](#21-data-model-hierarchy)
   - [2.2 Repository Pattern](#22-repository-pattern)
   - [2.3 DataSource Pattern](#23-datasource-pattern)
   - [2.4 Data Flow Direction](#24-data-flow-direction)

3. [Presentation Layer](#iii-presentation-layer)
   - [3.1 View Coding Standards](#31-view-coding-standards)
   - [3.2 ViewModel Coding Standards](#32-viewmodel-coding-standards)
   - [3.3 Data Flow Standards](#33-data-flow-standards)
   - [3.4 Feature Module Organization](#34-feature-module-organization)

4. [Domain Layer](#iv-domain-layer)
   - [4.1 Entity Definition Standards](#41-entity-definition-standards)
   - [4.2 Repository Protocol Standards](#42-repository-protocol-standards)
   - [4.3 Domain Layer Responsibility Boundaries](#43-domain-layer-responsibility-boundaries)

5. [Data Layer](#v-data-layer)
   - [5.1 Repository Implementation Standards](#51-repository-implementation-standards)
   - [5.2 DataSource Standards](#52-datasource-standards)
   - [5.3 Data Model Standards](#53-data-model-standards)
   - [5.4 Local Storage Standards](#54-local-storage-standards)
   - [5.5 Network Layer Standards](#55-network-layer-standards)

6. [Dependency Injection](#vi-dependency-injection)
   - [6.1 Constructor Injection](#61-constructor-injection)
   - [6.2 SwiftUI Environment Injection](#62-swiftui-environment-injection)
   - [6.3 Singleton Pattern](#63-singleton-pattern)

7. [Coding Style](#vii-coding-style)
   - [7.1 Comment Standards](#71-comment-standards)
   - [7.2 Naming Conventions](#72-naming-conventions)
   - [7.3 Access Control Standards](#73-access-control-standards)
   - [7.4 Type & Protocol Standards](#74-type--protocol-standards)

8. [Reactive Programming](#viii-reactive-programming)
   - [8.1 Combine Usage Standards](#81-combine-usage-standards)
   - [8.2 @Observable Macro Standards](#82-observable-macro-standards)
   - [8.3 ValueObservation (GRDB)](#83-valueobservation-grdb)

9. [Error Handling & Logging](#ix-error-handling--logging)
   - [9.1 Error Handling Standards](#91-error-handling-standards)
   - [9.2 Logging Standards](#92-logging-standards)

10. [Performance & Memory](#x-performance--memory)
    - [10.1 Memory Management](#101-memory-management)
    - [10.2 Performance Optimization](#102-performance-optimization)

11. [Cross-Document References](#xi-cross-document-references)
    - [11.1 Engineering Process Standards](#111-engineering-process-standards)
    - [11.2 Quick Reference](#112-quick-reference)

---

## I. Architecture Design

### 1.1 Layered Architecture

This project follows a **Clean Architecture** pattern with clear layer separation:

```
App/
├── Domain/          # Business logic & entities (framework-independent)
├── Data/            # Data access & transformation
├── Presentation/    # SwiftUI Views & ViewModels
└── Core/            # Shared utilities & extensions
```

#### 1.1.1 Domain Layer

**Responsibilities:**
- Define business entities (pure Swift structs/classes)
- Define repository protocols (interfaces)
- Contain business rules and logic
- Be completely framework-independent

**Forbidden:**
- Direct dependency on SwiftUI, UIKit, or any UI framework
- Direct access to databases, network, or storage
- Implementation details

**Structure:**
```
Domain/
├── Entities/
│   ├── Exercise.swift
│   ├── FaceScanResult.swift
│   └── Version.swift
└── Repositories/
    ├── ExerciseRepository.swift
    ├── FaceScanResultRepository.swift
    └── VersionRepository.swift
```

#### 1.1.2 Data Layer

**Responsibilities:**
- Implement repository protocols defined in Domain layer
- Manage data sources (local & remote)
- Handle data transformation (DTO ↔ Entity ↔ Record)
- Manage persistence (database, UserDefaults)
- Handle network communication

**Structure:**
```
Data/
├── Repositories/
│   ├── DefaultExerciseRepository.swift
│   └── DefaultFaceScanResultRepository.swift
├── DataSources/
│   ├── Local/
│   │   ├── LocalFaceScanResultDataSource.swift (Protocol)
│   │   └── DefaultLocalFaceScanResultDataSource.swift (Implementation)
│   └── Remote/
│       ├── RemoteFaceScanResultDataSource.swift (Protocol)
│       ├── DefaultRemoteFaceScanResultDataSource.swift (Implementation)
│       ├── APIs/
│       │   ├── FaceScanAPI.swift
│       │   └── S3API.swift
│       └── NetworkService/
│           ├── NetworkService+API.swift
│           ├── APIError.swift
│           └── APIResponse.swift
├── Models/
│   ├── DTOs/
│   │   ├── FaceScanDTO.swift
│   │   └── S3GetTempUploadUrlDTO.swift
│   └── Records/
│       ├── FaceScanResultRecord.swift (GRDB)
│       └── DailyExerciseRecord.swift (GRDB)
└── Storages/
    ├── OnboardingStorage.swift
    └── RatingFlowStorage.swift
```

#### 1.1.3 Presentation Layer

**Responsibilities:**
- SwiftUI Views (UI only)
- ViewModels (UI state management)
- Feature-based organization
- User interaction handling

**Forbidden:**
- Direct database access (use Repository)
- Direct network calls (use Repository)
- Direct UserDefaults access (use Repository or Storage)

**Structure:**
```
Presentation/
├── Features/
│   └── Exercises/
│       ├── Views/
│       │   ├── ExercisesMainView.swift
│       │   └── ExercisePreviewView.swift
│       └── ViewModels/
│           └── ExercisesMainViewModel.swift
├── Models/
│   ├── FaceScanModel.swift (Global state)
│   └── ToastModel.swift (Global state)
└── Components/
    ├── AppButtonStyle.swift
    └── ScalableCarouselView.swift
```

#### 1.1.4 Core Layer

**Responsibilities:**
- Shared utilities and helpers
- Extensions for standard types
- App-wide configuration
- Logging infrastructure

**Structure:**
```
Core/
├── Helpers/
│   ├── GRDBHelper.swift
│   ├── ProductHelper.swift
│   └── UserHelper.swift
├── Extensions/
│   ├── View+Extensions.swift
│   ├── String+Extensions.swift
│   └── Color+Extensions.swift
└── Utils/
    ├── AppLogger.swift
    ├── AppState.swift
    └── NetworkMonitor.swift
```

#### 1.1.5 Cross-Layer Dependency Rules

**MANDATORY RULES:**

1. **Dependency Direction:**
   ```
   Presentation → Data → Domain
                   ↓
                 Core (allowed from any layer)
   ```

2. **Forbidden Dependencies:**
   - ❌ Domain → Data
   - ❌ Domain → Presentation
   - ❌ Data → Presentation
   - ❌ Any layer → Implementation details of another layer

3. **Dependency Inversion:**
   - Data layer implements interfaces defined in Domain layer
   - Presentation layer depends on Domain protocols, not Data implementations

**Example:**
```swift
// ✅ CORRECT - Presentation depends on Domain protocol
@Observable
final class ExercisesMainViewModel {
    private let repository: ExerciseRepository  // Domain protocol

    init(repository: ExerciseRepository = DefaultExerciseRepository()) {
        self.repository = repository
    }
}

// ❌ WRONG - Presentation depends on Data implementation
@Observable
final class ExercisesMainViewModel {
    private let repository = DefaultExerciseRepository()  // Data implementation
}
```

---

### 1.2 Directory Organization

#### 1.2.1 Standard Project Root Structure

**MANDATORY structure:**

```
ProjectName/
├── App/
│   ├── App.swift                      # App entry point
│   ├── AppDelegate.swift              # AppDelegate (if needed)
│   ├── Domain/
│   ├── Data/
│   ├── Presentation/
│   └── Core/
├── Resources/
│   ├── Assets.xcassets/
│   ├── Fonts/
│   └── Localizable.xcstrings
├── Tests/
│   ├── UnitTests/
│   └── UITests/
└── Docs/
    └── IOS_DEVELOPMENT_CONSTRAINTS.md
```

#### 1.2.2 Feature Module Organization Pattern

Each feature MUST be organized as a self-contained module:

```
Presentation/Features/{FeatureName}/
├── Views/
│   ├── {FeatureName}MainView.swift
│   ├── {FeatureName}DetailView.swift
│   └── SubComponents/
│       └── {Component}Card.swift
└── ViewModels/
    ├── {FeatureName}MainViewModel.swift
    └── {FeatureName}DetailViewModel.swift
```

**Example:**
```
Presentation/Features/Exercises/
├── Views/
│   ├── ExercisesMainView.swift
│   ├── ExercisePreviewView.swift
│   └── SubComponents/
│       ├── ExerciseCard.swift
│       └── ProductIcon.swift
└── ViewModels/
    ├── ExercisesMainViewModel.swift
    └── ExerciseInstructionsViewModel.swift
```

#### 1.2.3 File Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| **View** | `{FeatureName}View.swift` or `{FeatureName}MainView.swift` | `ExercisesMainView.swift` |
| **ViewModel** | `{FeatureName}ViewModel.swift` or `{FeatureName}MainViewModel.swift` | `ExercisesMainViewModel.swift` |
| **Entity** | `{EntityName}.swift` | `Exercise.swift`, `FaceScanResult.swift` |
| **Repository Protocol** | `{EntityName}Repository.swift` | `ExerciseRepository.swift` |
| **Repository Implementation** | `Default{EntityName}Repository.swift` | `DefaultExerciseRepository.swift` |
| **DataSource Protocol** | `{Local/Remote}{EntityName}DataSource.swift` | `LocalFaceScanResultDataSource.swift` |
| **DataSource Implementation** | `Default{Local/Remote}{EntityName}DataSource.swift` | `DefaultLocalFaceScanResultDataSource.swift` |
| **DTO** | `{EntityName}DTO.swift` | `FaceScanDTO.swift` |
| **Record (GRDB)** | `{EntityName}Record.swift` | `FaceScanResultRecord.swift` |
| **Helper** | `{Purpose}Helper.swift` | `GRDBHelper.swift`, `ProductHelper.swift` |
| **Extension** | `{Type}+{Purpose}.swift` or `{Type}+Extensions.swift` | `View+Extensions.swift`, `String+Extensions.swift` |

---

### 1.3 Simplified Architecture Principles

This architecture intentionally **simplifies** Clean Architecture by omitting three common layers:

#### 1.3.1 No Independent UseCase Layer

**Rationale:**
- Reduces over-abstraction for small to medium-sized projects
- Business logic is integrated directly into Repository implementations
- Easier to understand and maintain

**Where business logic lives:**
- Simple queries → Repository methods
- Complex business rules → Private methods in Repository
- Cross-cutting concerns → Helper classes in Core layer

**Example:**
```swift
final class DefaultExerciseRepository: ExerciseRepository {
    // Business logic integrated in Repository
    func canScanToday() -> Bool {
        #if DEBUG
            if DebugMainViewModel.shared.isFaceScanUnlimited {
                return true
            }
        #endif

        let todayCount = localDataSource.getScansToday()
        let canScan = todayCount < QACheck.FaceScan.maxScansPerDay
        return canScan
    }
}
```

**When to consider adding UseCases:**
- Project grows to 50+ features
- Multiple ViewModels need to share complex business logic
- Business rules become too complex for Repository layer

#### 1.3.2 No Independent Mapper Layer

**Rationale:**
- Conversion logic is simple and one-to-one
- Extension-based mappers are self-documenting
- Reduces number of files to maintain

**Where mapping lives:**
- **DTO → Entity**: Extension on DTO with `toEntity()` method
- **Record → Entity**: Extension on Record with `toDomain()` method
- **Entity → Record**: Extension on Record with `init(from entity:)` initializer

**Example:**
```swift
// In FaceScanResultRecord.swift
extension FaceScanResultRecord {
    /// 转换为 Domain 实体
    func toDomain() -> FaceScanResult {
        FaceScanResult(
            id: id,
            imageName: imageName,
            pslScore: pslScore,
            createdAt: createdAt
        )
    }

    /// 从 Domain 实体创建
    init(from entity: FaceScanResult) {
        id = entity.id
        imageName = entity.imageName
        pslScore = entity.pslScore
        createdAt = entity.createdAt
    }
}
```

**When to consider adding Mappers:**
- Mapping logic becomes complex (validation, transformation)
- Multiple conversion strategies needed for same models
- Need to test mapping logic independently

#### 1.3.3 No Independent DI Container

**Rationale:**
- SwiftUI's native dependency injection is sufficient
- Reduces external dependencies
- Simpler mental model

**How dependencies are injected:**

1. **Constructor Injection** (for ViewModels):
   ```swift
   @Observable
   final class ExercisesMainViewModel {
       private let repository: ExerciseRepository

       init(
           date: Date = Date(),
           repository: ExerciseRepository = DefaultExerciseRepository()
       ) {
           self.repository = repository
       }
   }
   ```

2. **SwiftUI @Environment** (for global state):
   ```swift
   @Observable
   final class AppNavigationPath {
       var navigationPath = NavigationPath()
   }

   // In App:
   WindowGroup {
       ContentView()
           .environment(AppNavigationPath())
   }

   // In View:
   struct ExampleView: View {
       @Environment(AppNavigationPath.self) private var navigationPath
   }
   ```

3. **Singleton** (for stateless utilities):
   ```swift
   final class GRDBHelper {
       static let shared = GRDBHelper()
       private init() { }
   }
   ```

**When to consider adding DI Container:**
- Need complex object graphs with many dependencies
- Require different implementations for testing
- Project grows to 100+ classes

---

## II. Data Flow & Models

### 2.1 Data Model Hierarchy

This architecture uses **three distinct model types** for different layers:

| Model Type | Location | Purpose | Conversion Method |
|-----------|----------|---------|-------------------|
| **Entity** | `Domain/Entities/` | Business logic representation | - |
| **Record** | `Data/Models/` | Database persistence (GRDB) | `toDomain()` → Entity<br>`init(from:)` ← Entity |
| **DTO** | `Data/Models/DTOs/` | Network data transfer | `toEntity()` → Entity |

#### 2.1.1 Domain Entity

**Purpose**: Pure business object used throughout the app logic.

**Requirements:**
- MUST be a `struct` (value semantics preferred)
- MUST use `let` for immutable properties
- MAY have computed properties for derived values
- MUST conform to `Identifiable`, `Hashable` if needed
- MUST conform to `Sendable` for concurrency safety

**Example:**
```swift
/// 面部扫描结果
struct FaceScanResult: Identifiable, Hashable, Sendable {
    let id: UUID
    let imageName: String
    let pslScore: Int
    let pslLevel: PSLLevel
    let strategy: OptimizationStrategy
    let imageUrl: String?
    let createdAt: Date
    let isDeleted: Bool

    /// 根据 pslScore 计算等级分类
    var tier: PSLTier {
        switch pslScore {
        case 1...2: return .ltn
        case 3...4: return .mtn
        case 5...6: return .htn
        case 7...8: return .chadlite
        case 9...10: return .chad
        default: return .mtn
        }
    }
}
```

#### 2.1.2 Data Record (GRDB Persistence)

**Purpose**: Database representation of entities.

**Requirements:**
- MUST conform to `Codable`, `FetchableRecord`, `PersistableRecord`
- MUST use `var` (GRDB requires mutability)
- MUST define `databaseTableName`
- MUST provide `toDomain()` conversion method
- MUST provide `init(from entity:)` initializer

**Example:**
```swift
struct FaceScanResultRecord: Codable, FetchableRecord, PersistableRecord {
    var id: UUID
    var imageName: String
    var pslScore: Int
    var pslLevel: PSLLevel
    var imageUrl: String?
    var createdAt: Date
    var isDeleted: Bool

    static let databaseTableName = "face_scan_results"
}

extension FaceScanResultRecord {
    /// 转换为 Domain 实体
    func toDomain() -> FaceScanResult {
        FaceScanResult(
            id: id,
            imageName: imageName,
            pslScore: pslScore,
            pslLevel: pslLevel,
            imageUrl: imageUrl,
            createdAt: createdAt,
            isDeleted: isDeleted
        )
    }

    /// 从 Domain 实体创建
    init(from entity: FaceScanResult) {
        id = entity.id
        imageName = entity.imageName
        pslScore = entity.pslScore
        pslLevel = entity.pslLevel
        imageUrl = entity.imageUrl
        createdAt = entity.createdAt
        isDeleted = entity.isDeleted
    }
}
```

#### 2.1.3 DTO (Data Transfer Object)

**Purpose**: Network request/response representation.

**Requirements:**
- MUST conform to `Codable`, `Sendable`
- MAY have different field names than Entity (use `CodingKeys`)
- MUST provide `toEntity()` conversion method
- MAY return `nil` if validation fails

**Example:**
```swift
struct FaceScanDTO: Codable, Sendable {
    let pslScore: Int
    let pslLevel: Int
    let strategy: Int
    let imageUrl: String
}

extension FaceScanDTO {
    /// 转换为 Domain 实体
    func toEntity(id: UUID, imageName: String) -> FaceScanResult? {
        guard let pslLevel = PSLLevel(rawValue: pslLevel),
              let strategy = OptimizationStrategy(rawValue: strategy) else {
            return nil
        }

        return FaceScanResult(
            id: id,
            imageName: imageName,
            pslScore: pslScore,
            pslLevel: pslLevel,
            strategy: strategy,
            imageUrl: imageUrl,
            createdAt: Date(),
            isDeleted: false
        )
    }
}
```

#### 2.1.4 Model Conversion Standards

**MANDATORY naming conventions:**

| Conversion | Method Name | Example |
|-----------|-------------|---------|
| Record → Entity | `toDomain()` | `let entity = record.toDomain()` |
| DTO → Entity | `toEntity(...)` | `let entity = dto.toEntity(id: uuid)` |
| Entity → Record | `init(from entity:)` | `let record = Record(from: entity)` |

**Conversion placement:**
- All conversion methods MUST be in `extension` of the source type
- All conversion methods MUST be in the same file as the source type definition

---

### 2.2 Repository Pattern

The Repository pattern provides a **clean abstraction** between business logic and data access.

#### 2.2.1 Repository Protocol Definition (Domain Layer)

**Location**: `Domain/Repositories/`

**Requirements:**
- MUST be a `protocol`
- Name MUST end with `Repository`
- MUST group methods with `// MARK: - Comments`
- MUST provide both reactive (Combine) and synchronous methods when appropriate
- MUST use `throws` for operations that can fail

**Template:**
```swift
import Combine
import Foundation

protocol ExerciseRepository {
    // MARK: - 响应式发布者

    /// 响应式获取推荐的 Exercise
    func recommendedExercisePublisher(for date: Date) -> AnyPublisher<Exercise?, Never>

    // MARK: - 同步查询

    /// 获取推荐的 Exercise
    func getRecommendedExercise(for date: Date) -> Exercise

    /// 获取除指定日期推荐外的所有 exercises
    func getOtherExercises(excluding date: Date) -> [Exercise]

    // MARK: - 数据操作

    /// 标记 exercise 为完成
    func markExerciseCompleted(_ exercise: Exercise, for date: Date) throws

    /// 删除指定日期的 exercise 完成记录
    func removeExerciseCompletion(_ exercise: Exercise, for date: Date) throws
}
```

#### 2.2.2 Repository Implementation (Data Layer)

**Location**: `Data/Repositories/`

**Requirements:**
- MUST be a `final class`
- Name MUST be `Default{ProtocolName}`
- MUST conform to protocol from Domain layer
- MUST inject DataSources via properties
- MUST use `AppLogger` for logging
- MUST group methods with `// MARK: - Comments`
- Business logic MAY be integrated (no separate UseCase layer)

**Template:**
```swift
import Combine
import Foundation
import GRDB

final class DefaultExerciseRepository: ExerciseRepository {
    // MARK: - Properties

    private let dbQueue = GRDBHelper.shared.dbQueue
    private let logger = AppLogger(category: "DefaultExerciseRepository")
    private let exercises: [Exercise]

    // MARK: - Initialization

    init() {
        exercises = Self.loadExercisesFromJSON()
    }

    // MARK: - 响应式发布者

    func recommendedExercisePublisher(for date: Date) -> AnyPublisher<Exercise?, Never> {
        let dateString = date.string(withFormat: "yyyy-MM-dd")

        ensureRecommendationExists(for: date)

        let observation = ValueObservation.tracking { db -> Exercise? in
            guard let record = try DailyExerciseRecord
                .filter(Column("id") == dateString)
                .fetchOne(db) else {
                return nil
            }

            var exercise = self.exercises.first(where: { $0.id == record.recommendationExerciseId })
            exercise?.isCompleted = record.completedExerciseIds.contains(record.recommendationExerciseId)
            exercise?.isRecommended = true
            return exercise
        }

        return observation.publisher(in: dbQueue)
            .catch { [weak self] error -> Just<Exercise?> in
                self?.logger.error("获取推荐 exercise 发布者失败: \(error.localizedDescription)")
                return Just(nil)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - 同步查询

    func getRecommendedExercise(for date: Date) -> Exercise {
        // Implementation
    }

    // MARK: - 数据操作

    func markExerciseCompleted(_ exercise: Exercise, for date: Date) throws {
        let dateString = date.string(withFormat: "yyyy-MM-dd")

        try dbQueue.write { db in
            guard var record = try DailyExerciseRecord
                .filter(Column("id") == dateString)
                .fetchOne(db) else {
                return
            }

            if !record.completedExerciseIds.contains(exercise.id) {
                record.completedExerciseIds.append(exercise.id)
                try record.save(db)
                logger.info("标记 exercise 为完成: id=\(exercise.id)")
            }
        }
    }

    // MARK: - Private Methods

    /// 确保指定日期存在推荐记录
    private func ensureRecommendationExists(for date: Date) {
        // Business logic can be integrated here
    }
}
```

#### 2.2.3 Reactive vs. Synchronous Methods

**When to provide both:**
- UI needs real-time updates (reactive)
- Initial data fetch needed (synchronous)

**Publisher naming convention:**
- Suffix with `Publisher`: `recommendedExercisePublisher()`
- Non-publisher version: `getRecommendedExercise()`

**Example:**
```swift
protocol ExerciseRepository {
    // Reactive - returns Publisher for real-time updates
    func recommendedExercisePublisher(for date: Date) -> AnyPublisher<Exercise?, Never>

    // Synchronous - returns value immediately
    func getRecommendedExercise(for date: Date) -> Exercise
}
```

---

### 2.3 DataSource Pattern

DataSources provide **concrete data access** for local and remote sources.

#### 2.3.1 Local DataSource (Database Access)

**Location**: `Data/DataSources/Local/`

**Protocol Requirements:**
- Name MUST start with `Local` and end with `DataSource`
- MUST define protocol in separate file
- MUST provide reactive and synchronous methods

**Implementation Requirements:**
- Name MUST be `Default{ProtocolName}`
- MUST use GRDB for database access
- MUST use `ValueObservation` for reactive queries
- MUST use `AppLogger` for error logging

**Example:**
```swift
// LocalFaceScanResultDataSource.swift (Protocol)
import Combine
import Foundation

protocol LocalFaceScanResultDataSource {
    // MARK: - 响应式发布者

    /// 响应式获取所有扫描结果
    func allResultsPublisher(includeDeleted: Bool) -> AnyPublisher<[FaceScanResult], Never>

    // MARK: - 同步查询

    /// 获取所有扫描结果
    func getAllResults(includeDeleted: Bool) -> [FaceScanResult]

    /// 获取今天的扫描次数
    func getScansToday() -> Int

    // MARK: - 数据操作

    /// 添加或更新扫描结果
    func addOrUpdate(result: FaceScanResult) throws

    /// 软删除扫描结果
    func delete(result: FaceScanResult) throws
}

// DefaultLocalFaceScanResultDataSource.swift (Implementation)
import Combine
import Foundation
import GRDB

final class DefaultLocalFaceScanResultDataSource: LocalFaceScanResultDataSource {
    private let dbQueue = GRDBHelper.shared.dbQueue
    private let logger = AppLogger(category: "DefaultLocalFaceScanResultDataSource")

    func allResultsPublisher(includeDeleted: Bool = false) -> AnyPublisher<[FaceScanResult], Never> {
        let observation = ValueObservation.tracking { db -> [FaceScanResult] in
            var query = FaceScanResultRecord.all()

            if !includeDeleted {
                query = query.filter(Column("isDeleted") == false)
            }

            let records = try query
                .order(Column("createdAt").desc)
                .fetchAll(db)

            return records.map { $0.toDomain() }
        }

        return observation.publisher(in: dbQueue)
            .catch { [weak self] error -> Just<[FaceScanResult]> in
                self?.logger.error("获取所有扫描结果发布者失败: \(error.localizedDescription)")
                return Just([])
            }
            .eraseToAnyPublisher()
    }

    func addOrUpdate(result: FaceScanResult) throws {
        let record = FaceScanResultRecord(from: result)

        try dbQueue.write { db in
            try record.save(db)
        }

        logger.info("保存扫描结果: id=\(result.id.uuidString)")
    }
}
```

#### 2.3.2 Remote DataSource (Network Access)

**Location**: `Data/DataSources/Remote/`

**Protocol Requirements:**
- Name MUST start with `Remote` and end with `DataSource`
- MUST use `async/await` for asynchronous operations
- MUST use `throws` for error handling

**Implementation Requirements:**
- Name MUST be `Default{ProtocolName}`
- MUST use `NetworkService` for API calls
- MUST use `AppLogger` for logging
- MUST handle API errors appropriately

**Example:**
```swift
// RemoteFaceScanResultDataSource.swift (Protocol)
import Foundation

protocol RemoteFaceScanResultDataSource {
    /// 上传图片并获取面部扫描结果
    func fetchScanResult(id: UUID, imageData: Data) async throws -> FaceScanResult
}

// DefaultRemoteFaceScanResultDataSource.swift (Implementation)
import Foundation

final class DefaultRemoteFaceScanResultDataSource: RemoteFaceScanResultDataSource {
    private let logger = AppLogger(category: "DefaultRemoteFaceScanResultDataSource")

    func fetchScanResult(id: UUID, imageData: Data) async throws -> FaceScanResult {
        logger.info("开始面部扫描流程，id: \(id.uuidString)")

        // 1. 生成文件名
        let fileName = "\(id.uuidString).png"

        // 2. 获取 S3 临时上传 URL
        logger.debug("获取S3上传URL...")
        let uploadInfo = try await S3API.getTempUploadUrl(
            dirKey: "star108-facescan/",
            fileName: fileName,
            contentType: "image/png"
        )

        // 3. 上传图片到 S3
        logger.debug("上传图片到S3...")
        try await uploadImageToS3(imageData: imageData, uploadUrl: uploadInfo.uploadUrl)

        // 4. 调用面部扫描接口
        logger.debug("调用面部扫描接口...")
        let scanDTO = try await FaceScanAPI.scan(imageUrl: uploadInfo.fileUrl)

        // 5. 转换为实体
        guard let result = scanDTO.toEntity(id: id, imageName: fileName) else {
            throw NSError(domain: "FaceScan", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "无法解析 API 响应"
            ])
        }

        logger.info("面部扫描完成")
        return result
    }
}
```

---

### 2.4 Data Flow Direction

#### 2.4.1 Request Flow (View → DataSource)

```
View
  ↓ calls method
ViewModel
  ↓ uses protocol
Repository Interface (Domain)
  ↓ implementation
Repository Implementation (Data)
  ↓ delegates to
DataSource
  ↓ accesses
Database / Network / Storage
```

**Example:**
```swift
// 1. View calls ViewModel
Button("Load Data") {
    viewModel.loadData()
}

// 2. ViewModel calls Repository
@Observable
final class ViewModel {
    private let repository: ExerciseRepository

    func loadData() {
        exercise = repository.getRecommendedExercise(for: Date())
    }
}

// 3. Repository calls DataSource
final class DefaultExerciseRepository: ExerciseRepository {
    private let localDataSource: LocalExerciseDataSource

    func getRecommendedExercise(for date: Date) -> Exercise {
        return localDataSource.getRecommendedExercise(for: date)
    }
}

// 4. DataSource accesses database
final class DefaultLocalExerciseDataSource: LocalExerciseDataSource {
    func getRecommendedExercise(for date: Date) -> Exercise {
        let record = try dbQueue.read { db in
            try ExerciseRecord.fetchOne(db)
        }
        return record.toDomain()
    }
}
```

#### 2.4.2 Response Flow (DataSource → View)

```
Database / Network
  ↓ returns data
DTO / Record
  ↓ converts via extension
Entity (Domain)
  ↓ returns to
Repository
  ↓ returns to
ViewModel
  ↓ updates state
View (re-renders)
```

**Example:**
```swift
// 1. Database returns Record
let record = try ExerciseRecord.fetchOne(db)

// 2. Convert to Entity
let entity = record.toDomain()

// 3. Repository returns Entity
func getExercise() -> Exercise {
    let record = localDataSource.fetchRecord()
    return record.toDomain()  // Entity
}

// 4. ViewModel stores Entity
@Observable
final class ViewModel {
    var exercise: Exercise?

    func load() {
        exercise = repository.getExercise()  // View auto-updates
    }
}
```

#### 2.4.3 Responsibility Boundaries

**FORBIDDEN data access:**

| Layer | ❌ MUST NOT Access | ✅ SHOULD Access |
|-------|-------------------|-----------------|
| **View** | Database, Network, UserDefaults | ViewModel only |
| **ViewModel** | Database, Network, UserDefaults | Repository protocols |
| **Repository** | Database, Network directly | DataSource protocols |
| **DataSource** | - | Database, Network, Storage |

**Example violations:**
```swift
// ❌ WRONG - View accessing Repository directly
struct ExerciseView: View {
    private let repository = DefaultExerciseRepository()

    var body: some View {
        // Direct repository access
    }
}

// ❌ WRONG - ViewModel accessing Database directly
@Observable
final class ViewModel {
    func loadData() {
        let db = GRDBHelper.shared.dbQueue
        let records = try db.read { ... }  // NO!
    }
}

// ✅ CORRECT - Proper layering
struct ExerciseView: View {
    @State private var viewModel = ExerciseViewModel()
}

@Observable
final class ExerciseViewModel {
    private let repository: ExerciseRepository

    func loadData() {
        exercises = repository.getAllExercises()  // YES!
    }
}
```

---

## III. Presentation Layer

This chapter defines **strict standards** for SwiftUI Views and ViewModels.

*[Content integrated from SWIFTUI_CODING_STYLE_CONSTRAINTS.md]*

### 3.1 View Coding Standards

#### 3.1.1 View Scope and Responsibility

**Definition of a View:**
- A View represents a **complete screen-level or logical UI unit**
- A View does **NOT** mean a tiny visual subcomponent

**UI Logic Only:**
Views MUST contain **UI logic only**.

**Allowed in Views:**
- Presentation state (expand / collapse / selection)
- Gestures (tap / swipe / drag)
- Animations and transitions
- Showing or hiding UI elements

**NOT allowed in Views:**
- Business rules
- Data mutation
- Network or persistence logic
- Domain-level decisions

All business logic MUST be delegated to a ViewModel.

#### 3.1.2 View Internal Structure Order (STRICT)

Each View MUST follow this exact structure order:

```swift
struct SomeView: View {
    // MARK: - Properties
    // Properties and state variables

    // MARK: - Body
    var body: some View {
        contentView
            .navigationTitle("Title")
            .onAppear { }
    }

    // MARK: - Sub-Views

    /// 主内容视图
    @ViewBuilder
    private var contentView: some View {
        // Layout implementation
    }

    // MARK: - Private Methods

    /// 处理按钮点击
    private func handleButtonTap() {
        // Implementation
    }
}
```

**Violation of this order is NOT allowed.**

#### 3.1.3 Body Delegation Rule (MANDATORY)

**RULE**: `body` MUST be minimal and declarative.

**ALL UI layout MUST be delegated to a `contentView`.**

**✅ CORRECT:**
```swift
var body: some View {
    contentView
        .navigationTitle("Exercises")
        .onAppear {
            viewModel.loadData()
        }
}

/// 主内容视图
@ViewBuilder
private var contentView: some View {
    ScrollView {
        VStack(spacing: 16) {
            headerSection
            exerciseList
        }
    }
}
```

**❌ WRONG:**
```swift
var body: some View {
    ScrollView {
        VStack(spacing: 16) {
            Text("Header")
            ForEach(exercises) { exercise in
                ExerciseRow(exercise: exercise)
            }
        }
    }
    .navigationTitle("Exercises")
    .onAppear {
        viewModel.loadData()
    }
}
```

#### 3.1.4 Lifecycle Placement (STRICT RULE)

`body` is the ONLY place allowed for:
- `.onAppear`
- `.task`
- `.alert`
- `.sheet`
- `.fullScreenCover`
- Other lifecycle or presentation modifiers

**Sub-Views MUST NOT contain lifecycle logic.**

**✅ CORRECT:**
```swift
var body: some View {
    contentView
        .onAppear {
            viewModel.loadExercises()
        }
        .task {
            await viewModel.fetchRemoteData()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        }
}
```

**❌ WRONG:**
```swift
@ViewBuilder
private var contentView: some View {
    ScrollView {
        // ...
    }
    .onAppear {  // NO! Lifecycle in Sub-View
        viewModel.loadData()
    }
}
```

#### 3.1.5 Sub-View Rules (MANDATORY)

Sub-Views MUST:
- Be implemented as `private` computed properties
- Be annotated with `@ViewBuilder`
- Have a **Chinese comment** (concise, single-line)

**Template:**
```swift
// MARK: - Sub-Views

/// 顶部标题区域
@ViewBuilder
private var headerSection: some View {
    VStack(spacing: 8) {
        Text("Title")
            .font(.title)
    }
}

/// 练习列表
@ViewBuilder
private var exerciseList: some View {
    ForEach(viewModel.exercises) { exercise in
        ExerciseRow(exercise: exercise)
    }
}
```

**Sub-Views MUST:**
- Only care about their own content
- NOT manage spacing between sibling components

Spacing and layout are controlled by the parent View.

#### 3.1.6 View Size and Complexity Control

- Sub-Views MUST remain within a reasonable size
- Avoid extremely large or extremely small sub-Views
- Prefer readability and single responsibility

**Guideline**: If a Sub-View exceeds ~50 lines, consider extracting it to a separate component file.

#### 3.1.7 Preview Requirements (MANDATORY)

Every **complete View** MUST include a valid `#Preview`:

```swift
#Preview {
    ExercisesMainView()
        .environment(AppNavigationPath())
}
```

**Requirements:**
- Previews MUST compile without extra setup
- Previews MUST represent realistic UI states
- Provide necessary environment objects

---

### 3.2 ViewModel Coding Standards

#### 3.2.1 Mandatory Annotations

All ViewModels MUST be declared as:

```swift
@MainActor
@Observable
final class SomeViewModel {
    // Implementation
}
```

**MANDATORY requirements:**
- `@MainActor` - ensures all properties are accessed on main thread
- `@Observable` - SwiftUI 6's new observation system
- `final class` - prevents subclassing

#### 3.2.2 ViewModel Internal Structure (STRICT ORDER)

Each ViewModel MUST follow this exact structure:

```swift
@MainActor
@Observable
final class ExercisesMainViewModel {
    // MARK: - Properties

    // 1. Public properties
    /// 推荐的 Exercise
    private(set) var recommendedExercise: Exercise?

    /// 其他 Exercises
    private(set) var otherExercises: [Exercise] = []

    // 2. Private properties
    private let repository: ExerciseRepository
    private let logger = AppLogger(category: "ExercisesMainViewModel")
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    // 3. init
    init(
        date: Date = Date(),
        repository: ExerciseRepository = DefaultExerciseRepository()
    ) {
        self.repository = repository
        setupSubscriptions()
    }

    // MARK: - Public Methods

    // 4. Public methods
    /// 标记 Exercise 为完成
    func markCompleted(_ exercise: Exercise) {
        // Implementation
    }

    // MARK: - Private Methods

    // 5. Private methods
    private func setupSubscriptions() {
        // Implementation
    }
}
```

#### 3.2.3 Property Grouping

**Public properties:**
- Use `private(set)` for read-only external access
- MUST have Chinese comments

**Private properties:**
- Dependencies (repositories, services)
- Logging (`AppLogger`)
- Combine cancellables

#### 3.2.4 Method Visibility

**Public methods:**
- Called by Views
- Represent user actions or lifecycle events
- MUST have Chinese comments

**Private methods:**
- Internal helpers
- Subscription setup
- Data transformation
- MUST have Chinese comments

#### 3.2.5 Reactive Programming (Combine)

**Subscription management:**
```swift
private var cancellables = Set<AnyCancellable>()

private func setupSubscriptions() {
    repository.recommendedExercisePublisher(for: date)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] exercise in
            self?.recommendedExercise = exercise
        }
        .store(in: &cancellables)
}
```

**MANDATORY rules:**
- Use `[weak self]` to prevent retain cycles
- Use `.receive(on: DispatchQueue.main)` for UI updates
- Store subscriptions in `cancellables`

---

### 3.3 Data Flow Standards

#### 3.3.1 Unidirectional Data Flow

**RULE**: Data flows in ONE direction:

```
Repository → ViewModel → View
         ↑              ↓
      (actions)    (state changes)
```

**Example:**
```swift
// View reads ViewModel state
struct ExerciseView: View {
    @State private var viewModel = ExerciseViewModel()

    var body: some View {
        Text(viewModel.exerciseName)  // Read state
            .onTapGesture {
                viewModel.markCompleted()  // Trigger action
            }
    }
}

// ViewModel updates state
@Observable
final class ExerciseViewModel {
    private(set) var exerciseName: String = ""

    func markCompleted() {
        // Update repository
        try repository.markCompleted(exercise)
        // State will update via reactive publisher
    }
}
```

#### 3.3.2 View-ViewModel Interaction Rules

**FORBIDDEN:**
- ❌ View directly modifying ViewModel properties (except via `$binding`)
- ❌ ViewModel holding reference to View
- ❌ Bidirectional binding for business logic

**ALLOWED:**
- ✅ View calling ViewModel methods
- ✅ View reading ViewModel @Observable properties
- ✅ View using `$binding` for UI state (TextFields, Toggles)

#### 3.3.3 State Management

**UI State (expand/collapse, selection):**
- Managed in View via `@State`
- Local to View, not business data

**Business Data:**
- Managed in ViewModel via `@Observable`
- Shared across app via Repository

**Example:**
```swift
struct ExerciseView: View {
    @State private var viewModel = ExerciseViewModel()
    @State private var isExpanded = false  // UI state - View

    var body: some View {
        VStack {
            Text(viewModel.exerciseName)  // Business data - ViewModel

            if isExpanded {
                detailsView
            }
        }
    }
}
```

---

### 3.4 Feature Module Organization

#### 3.4.1 Directory Structure

**Standard structure for each feature:**

```
Presentation/Features/{FeatureName}/
├── Views/
│   ├── {FeatureName}MainView.swift
│   ├── {FeatureName}DetailView.swift
│   └── Components/
│       └── {Component}Card.swift
└── ViewModels/
    ├── {FeatureName}MainViewModel.swift
    └── {FeatureName}DetailViewModel.swift
```

**Example:**
```
Presentation/Features/Exercises/
├── Views/
│   ├── ExercisesMainView.swift
│   ├── ExercisePreviewView.swift
│   └── Components/
│       ├── ExerciseCard.swift
│       └── ProductIcon.swift
└── ViewModels/
    ├── ExercisesMainViewModel.swift
    └── ExerciseInstructionsViewModel.swift
```

#### 3.4.2 Feature Boundary Definition

**A feature module MUST:**
- Be self-contained for a specific app function
- Have clear entry point (MainView)
- Not directly depend on other feature modules
- Communicate via shared Domain models

#### 3.4.3 Module Dependency Rules

**ALLOWED:**
- ✅ Feature → Domain (entities, repository protocols)
- ✅ Feature → Core (extensions, utilities)
- ✅ Feature → Presentation/Components (shared UI components)

**FORBIDDEN:**
- ❌ Feature A → Feature B (direct import)
- ❌ Feature → Data layer (must go through Domain protocols)

---

## IV. Domain Layer

### 4.1 Entity Definition Standards

#### 4.1.1 Struct Preferred

**RULE**: Entities MUST be `struct` unless there's a compelling reason for reference semantics.

**Rationale**:
- Value semantics prevent unintended mutations
- Better performance for small data
- Thread-safe by default

**✅ CORRECT:**
```swift
/// 练习项目
struct Exercise: Identifiable, Hashable {
    let id: Int
    let name: String
    let duration: String
    var isCompleted: Bool
}
```

**❌ WRONG (without justification):**
```swift
class Exercise: Identifiable {  // Why class?
    let id: Int
    var name: String
}
```

#### 4.1.2 Immutability Principle

**RULE**: Use `let` for properties that don't change after initialization.

**✅ CORRECT:**
```swift
struct FaceScanResult {
    let id: UUID
    let imageName: String
    let pslScore: Int
    let createdAt: Date
    var isDeleted: Bool  // Only mutable property
}
```

#### 4.1.3 Protocol Conformance

**MANDATORY protocols** (when applicable):

| Protocol | When to use |
|----------|------------|
| `Identifiable` | Entity has unique ID and used in ForEach |
| `Hashable` | Entity used in Set or Dictionary keys |
| `Sendable` | Entity passed across concurrency boundaries |
| `Codable` | Entity serialized to JSON/Plist (rare for pure Domain) |

**Example:**
```swift
/// 面部扫描结果
struct FaceScanResult: Identifiable, Hashable, Sendable {
    let id: UUID
    let imageName: String
    let pslScore: Int
    let createdAt: Date
}
```

#### 4.1.4 Computed Properties

**ALLOWED**: Derived values that don't change entity state.

**Example:**
```swift
struct FaceScanResult {
    let pslScore: Int

    /// 根据 pslScore 计算等级分类
    var tier: PSLTier {
        switch pslScore {
        case 1...2: return .ltn
        case 3...4: return .mtn
        case 5...6: return .htn
        case 7...8: return .chadlite
        case 9...10: return .chad
        default: return .mtn
        }
    }
}
```

---

### 4.2 Repository Protocol Standards

#### 4.2.1 Protocol Naming

**RULE**: Protocol name MUST end with `Repository`.

**Examples:**
- `ExerciseRepository`
- `FaceScanResultRepository`
- `VersionRepository`

#### 4.2.2 Method Signature Standards

**Requirements:**
- MUST group methods with `// MARK: - Comments`
- MUST use clear, descriptive names
- MUST use Chinese comments (concise, single-line)
- MUST use `throws` for failable operations
- MUST use `async` for asynchronous operations

**Template:**
```swift
protocol ExerciseRepository {
    // MARK: - 响应式发布者

    /// 响应式获取推荐的 Exercise
    func recommendedExercisePublisher(for date: Date) -> AnyPublisher<Exercise?, Never>

    // MARK: - 同步查询

    /// 获取推荐的 Exercise
    func getRecommendedExercise(for date: Date) -> Exercise

    // MARK: - 数据操作

    /// 标记 exercise 为完成
    func markExerciseCompleted(_ exercise: Exercise, for date: Date) throws
}
```

#### 4.2.3 Reactive Publisher Standards

**When to provide Publisher methods:**
- UI needs real-time updates when data changes
- Multiple subscribers may observe the same data

**Naming convention:**
- Suffix method name with `Publisher`
- Return type: `AnyPublisher<T, Never>` for non-failable streams
- Return type: `AnyPublisher<T, Error>` for failable streams

**Example:**
```swift
// Returns Exercise updates in real-time
func recommendedExercisePublisher(for date: Date) -> AnyPublisher<Exercise?, Never>

// Synchronous counterpart
func getRecommendedExercise(for date: Date) -> Exercise
```

#### 4.2.4 Error Handling Standards

**RULE**: Operations that can fail MUST use `throws`.

**Examples:**
```swift
protocol Repository {
    /// 保存数据（可能失败）
    func save(_ entity: Entity) throws

    /// 删除数据（可能失败）
    func delete(id: UUID) throws

    /// 查询数据（不会失败，返回空数组）
    func getAll() -> [Entity]
}
```

---

### 4.3 Domain Layer Responsibility Boundaries

#### 4.3.1 Pure Business Logic

**ALLOWED in Domain:**
- Entity definitions
- Business rules and validation
- Repository protocol definitions
- Domain-specific enums and value objects

**Example:**
```swift
// Domain/Entities/Exercise.swift
struct Exercise {
    let id: Int
    let name: String
    let requiredProducts: [Product]

    /// 检查是否可以开始（业务规则）
    func canStart(availableProducts: Set<Product>) -> Bool {
        let required = Set(requiredProducts)
        return required.isSubset(of: availableProducts)
    }
}
```

#### 4.3.2 No Framework Dependencies

**FORBIDDEN in Domain:**
- Import SwiftUI, UIKit, or any UI framework
- Import GRDB, Alamofire, or any data framework
- Reference to concrete data implementations

**✅ CORRECT:**
```swift
// Domain/Entities/Exercise.swift
import Foundation  // OK - Foundation is acceptable

struct Exercise: Identifiable {
    let id: Int
    let name: String
}
```

**❌ WRONG:**
```swift
import SwiftUI  // NO!
import GRDB     // NO!

struct Exercise {
    let id: Int
}
```

#### 4.3.3 No Data Access Implementation

**FORBIDDEN in Domain:**
- Database queries
- Network calls
- File I/O
- UserDefaults access

**ONLY define interfaces (protocols):**
```swift
// ✅ CORRECT - Domain defines interface
protocol ExerciseRepository {
    func getAllExercises() -> [Exercise]
}

// ❌ WRONG - Domain implements data access
struct ExerciseRepository {
    func getAllExercises() -> [Exercise] {
        let db = GRDBHelper.shared.dbQueue  // NO!
        return try db.read { ... }
    }
}
```

---

## V. Data Layer

### 5.1 Repository Implementation Standards

#### 5.1.1 Naming Convention

**RULE**: Implementation MUST be named `Default{ProtocolName}`.

**Examples:**
| Protocol | Implementation |
|----------|----------------|
| `ExerciseRepository` | `DefaultExerciseRepository` |
| `FaceScanResultRepository` | `DefaultFaceScanResultRepository` |
| `VersionRepository` | `DefaultVersionRepository` |

#### 5.1.2 Internal Structure & Grouping

**MANDATORY structure:**

```swift
final class DefaultExerciseRepository: ExerciseRepository {
    // MARK: - Properties

    private let localDataSource: LocalExerciseDataSource
    private let remoteDataSource: RemoteExerciseDataSource
    private let logger = AppLogger(category: "DefaultExerciseRepository")
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        localDataSource: LocalExerciseDataSource = DefaultLocalExerciseDataSource(),
        remoteDataSource: RemoteExerciseDataSource = DefaultRemoteExerciseDataSource()
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    // MARK: - 响应式发布者

    func recommendedExercisePublisher(for date: Date) -> AnyPublisher<Exercise?, Never> {
        // Implementation
    }

    // MARK: - 同步查询

    func getRecommendedExercise(for date: Date) -> Exercise {
        // Implementation
    }

    // MARK: - 数据操作

    func markExerciseCompleted(_ exercise: Exercise, for date: Date) throws {
        // Implementation
    }

    // MARK: - Private Methods

    /// 确保推荐记录存在
    private func ensureRecommendationExists(for date: Date) {
        // Business logic can be integrated here
    }
}
```

#### 5.1.3 Business Logic Integration

**RULE**: Since there's no separate UseCase layer, business logic MAY be integrated in Repository.

**Allowed business logic in Repository:**
- Data validation
- Business rule checks
- Data transformation logic
- Conditional data fetching

**Example:**
```swift
final class DefaultFaceScanResultRepository: FaceScanResultRepository {
    func canScanToday() -> Bool {
        #if DEBUG
            if DebugMainViewModel.shared.isFaceScanUnlimited {
                return true
            }
        #endif

        // Business rule: max scans per day
        let todayCount = localDataSource.getScansToday()
        let canScan = todayCount < QACheck.FaceScan.maxScansPerDay

        logger.debug("今日扫描次数: \(todayCount), 是否可扫描: \(canScan)")
        return canScan
    }
}
```

#### 5.1.4 Error Handling & Logging

**MANDATORY requirements:**
- MUST use `AppLogger` for all logging
- MUST log in Chinese
- MUST log at appropriate levels (debug/info/error)
- MUST handle errors gracefully

**Logging levels:**
| Level | Usage |
|-------|-------|
| `debug` | Detailed flow information for debugging |
| `info` | Important state changes or operations |
| `error` | Errors and exceptions |

**Example:**
```swift
func markExerciseCompleted(_ exercise: Exercise, for date: Date) throws {
    logger.debug("开始标记 exercise 为完成: id=\(exercise.id), date=\(date)")

    do {
        try localDataSource.markCompleted(exercise, for: date)
        logger.info("成功标记 exercise 为完成: id=\(exercise.id)")
    } catch {
        logger.error("标记 exercise 失败: \(error.localizedDescription)")
        throw error
    }
}
```

---

### 5.2 DataSource Standards

#### 5.2.1 Local DataSource (GRDB)

**Protocol naming**: `Local{EntityName}DataSource`

**Implementation naming**: `DefaultLocal{EntityName}DataSource`

**Requirements:**
- MUST use GRDB for database access
- MUST use `ValueObservation` for reactive queries
- MUST use `AppLogger` for logging
- MUST convert Record → Entity in return types

**Example:**
```swift
// Protocol
protocol LocalFaceScanResultDataSource {
    func allResultsPublisher(includeDeleted: Bool) -> AnyPublisher<[FaceScanResult], Never>
    func getAllResults(includeDeleted: Bool) -> [FaceScanResult]
    func addOrUpdate(result: FaceScanResult) throws
    func delete(result: FaceScanResult) throws
}

// Implementation
final class DefaultLocalFaceScanResultDataSource: LocalFaceScanResultDataSource {
    private let dbQueue = GRDBHelper.shared.dbQueue
    private let logger = AppLogger(category: "DefaultLocalFaceScanResultDataSource")

    func getAllResults(includeDeleted: Bool = false) -> [FaceScanResult] {
        do {
            let records = try dbQueue.read { db in
                var query = FaceScanResultRecord.all()
                if !includeDeleted {
                    query = query.filter(Column("isDeleted") == false)
                }
                return try query.order(Column("createdAt").desc).fetchAll(db)
            }

            return records.map { $0.toDomain() }  // Convert to Entity
        } catch {
            logger.error("查询扫描结果失败: \(error.localizedDescription)")
            return []
        }
    }
}
```

#### 5.2.2 Remote DataSource (NetworkService)

**Protocol naming**: `Remote{EntityName}DataSource`

**Implementation naming**: `DefaultRemote{EntityName}DataSource`

**Requirements:**
- MUST use `async/await` for network operations
- MUST use `NetworkService` for API calls
- MUST use `AppLogger` for logging
- MUST convert DTO → Entity in return types

**Example:**
```swift
// Protocol
protocol RemoteFaceScanResultDataSource {
    func fetchScanResult(id: UUID, imageData: Data) async throws -> FaceScanResult
}

// Implementation
final class DefaultRemoteFaceScanResultDataSource: RemoteFaceScanResultDataSource {
    private let logger = AppLogger(category: "DefaultRemoteFaceScanResultDataSource")

    func fetchScanResult(id: UUID, imageData: Data) async throws -> FaceScanResult {
        logger.info("开始面部扫描: id=\(id.uuidString)")

        // 1. Upload image
        let uploadInfo = try await S3API.getTempUploadUrl(...)
        try await uploadImage(imageData, to: uploadInfo.uploadUrl)

        // 2. Call API
        let dto = try await FaceScanAPI.scan(imageUrl: uploadInfo.fileUrl)

        // 3. Convert DTO → Entity
        guard let result = dto.toEntity(id: id, imageName: fileName) else {
            throw APIError.invalidResponse
        }

        logger.info("面部扫描完成")
        return result
    }
}
```

---

### 5.3 Data Model Standards

#### 5.3.1 Record (GRDB Persistence Model)

**File naming**: `{EntityName}Record.swift`

**Requirements:**
- MUST conform to `Codable`, `FetchableRecord`, `PersistableRecord`
- MUST use `var` (GRDB requires mutability)
- MUST define `static let databaseTableName`
- MUST provide `toDomain()` method in extension
- MUST provide `init(from entity:)` initializer in extension

**Template:**
```swift
import Foundation
import GRDB

struct FaceScanResultRecord: Codable, FetchableRecord, PersistableRecord {
    var id: UUID
    var imageName: String
    var pslScore: Int
    var pslLevel: PSLLevel
    var createdAt: Date
    var isDeleted: Bool

    static let databaseTableName = "face_scan_results"
}

// MARK: - Conversion

extension FaceScanResultRecord {
    /// 转换为 Domain 实体
    func toDomain() -> FaceScanResult {
        FaceScanResult(
            id: id,
            imageName: imageName,
            pslScore: pslScore,
            pslLevel: pslLevel,
            createdAt: createdAt,
            isDeleted: isDeleted
        )
    }

    /// 从 Domain 实体创建
    init(from entity: FaceScanResult) {
        id = entity.id
        imageName = entity.imageName
        pslScore = entity.pslScore
        pslLevel = entity.pslLevel
        createdAt = entity.createdAt
        isDeleted = entity.isDeleted
    }
}

// MARK: - Database Migration

extension FaceScanResultRecord {
    static func createTable(in db: Database) throws {
        try db.create(table: databaseTableName, ifNotExists: true) { t in
            t.column("id", .text).primaryKey()
            t.column("imageName", .text).notNull()
            t.column("pslScore", .integer).notNull()
            t.column("pslLevel", .integer).notNull()
            t.column("createdAt", .datetime).notNull()
            t.column("isDeleted", .boolean).notNull().defaults(to: false)
        }
    }
}
```

#### 5.3.2 DTO (Network Transfer Model)

**File naming**: `{EntityName}DTO.swift`

**Location**: `Data/Models/DTOs/`

**Requirements:**
- MUST conform to `Codable`, `Sendable`
- MAY use `CodingKeys` if API field names differ
- MUST provide `toEntity()` method in extension
- MAY return `nil` from `toEntity()` if validation fails

**Template:**
```swift
import Foundation

struct FaceScanDTO: Codable, Sendable {
    let pslScore: Int
    let pslLevel: Int
    let strategy: Int
    let imageUrl: String
}

extension FaceScanDTO {
    /// 转换为 Domain 实体
    func toEntity(id: UUID, imageName: String) -> FaceScanResult? {
        // Validate enum values
        guard let pslLevel = PSLLevel(rawValue: pslLevel),
              let strategy = OptimizationStrategy(rawValue: strategy) else {
            return nil
        }

        return FaceScanResult(
            id: id,
            imageName: imageName,
            pslScore: pslScore,
            pslLevel: pslLevel,
            strategy: strategy,
            imageUrl: imageUrl,
            createdAt: Date(),
            isDeleted: false
        )
    }
}
```

#### 5.3.3 Conversion Method Standards

**MANDATORY naming conventions:**

| Conversion | Method Name | Return Type | Example |
|-----------|-------------|-------------|---------|
| Record → Entity | `toDomain()` | `Entity` | `let entity = record.toDomain()` |
| DTO → Entity | `toEntity(...)` | `Entity?` | `let entity = dto.toEntity(id: uuid)` |
| Entity → Record | `init(from:)` | `Self` | `let record = Record(from: entity)` |

**Placement:**
- All conversion methods MUST be in `extension` of the source type
- Extension MUST be in the same file as the type definition

---

### 5.4 Local Storage Standards

#### 5.4.1 GRDB Usage Standards

**Database initialization:**
- MUST use singleton `GRDBHelper.shared`
- MUST use `DatabaseQueue` for single-threaded access
- MUST use database migrations for schema changes

**Example:**
```swift
// GRDBHelper.swift
final class GRDBHelper {
    static let shared = GRDBHelper()

    let dbQueue: DatabaseQueue

    private init() {
        let dbURL = URL.documentsDirectory.appendingPathComponent("user.sqlite")
        dbQueue = try! DatabaseQueue(path: dbURL.path)
        try! setupDatabase()
    }

    private func setupDatabase() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1") { db in
            try FaceScanResultRecord.createTable(in: db)
            try DailyExerciseRecord.createTable(in: db)
        }

        try migrator.migrate(dbQueue)
    }
}
```

#### 5.4.2 Database Migration Standards

**MANDATORY rules:**
- Migrations MUST have unique names (e.g., "v1", "v2", "add_column_x")
- Migrations MUST be idempotent (use `ifNotExists: true`)
- Never modify old migrations after release

**Example:**
```swift
migrator.registerMigration("v1") { db in
    try db.create(table: "face_scan_results", ifNotExists: true) { t in
        t.column("id", .text).primaryKey()
        t.column("createdAt", .datetime).notNull()
    }
}

migrator.registerMigration("v2_add_psl_score") { db in
    try db.alter(table: "face_scan_results") { t in
        t.add(column: "pslScore", .integer).defaults(to: 0)
    }
}
```

#### 5.4.3 ValueObservation Reactive Queries

**RULE**: Use `ValueObservation` for real-time data updates.

**Example:**
```swift
func allResultsPublisher(includeDeleted: Bool) -> AnyPublisher<[FaceScanResult], Never> {
    let observation = ValueObservation.tracking { db -> [FaceScanResult] in
        var query = FaceScanResultRecord.all()

        if !includeDeleted {
            query = query.filter(Column("isDeleted") == false)
        }

        let records = try query.order(Column("createdAt").desc).fetchAll(db)
        return records.map { $0.toDomain() }
    }

    return observation.publisher(in: dbQueue)
        .catch { [weak self] error -> Just<[FaceScanResult]> in
            self?.logger.error("查询失败: \(error.localizedDescription)")
            return Just([])
        }
        .eraseToAnyPublisher()
}
```

#### 5.4.4 UserDefaults Usage Standards

**RULE**: UserDefaults access MUST be wrapped in Storage protocols.

**Forbidden:**
```swift
// ❌ WRONG - Direct UserDefaults access in Repository
func getSetting() -> String {
    UserDefaults.standard.string(forKey: "setting_key") ?? ""
}
```

**Correct:**
```swift
// ✅ CORRECT - Wrap in Storage protocol

// Storage protocol
protocol SettingsStorage {
    var userName: String { get set }
}

// Storage implementation
final class DefaultSettingsStorage: SettingsStorage {
    private let userNameKey = "settings_user_name"

    var userName: String {
        get { UserDefaults.standard.string(forKey: userNameKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: userNameKey) }
    }
}

// Repository uses Storage
final class DefaultSettingsRepository: SettingsRepository {
    private let storage: SettingsStorage

    init(storage: SettingsStorage = DefaultSettingsStorage()) {
        self.storage = storage
    }

    func getUserName() -> String {
        storage.userName
    }
}
```

---

### 5.5 Network Layer Standards

#### 5.5.1 NetworkService Usage

**RULE**: Use custom `NetworkService` for all network calls.

**FORBIDDEN**: Direct `URLSession` usage in DataSource.

**Architecture:**
```
API Definition (TargetType)
    ↓
NetworkService
    ↓
PluginType (Logging, Auth)
    ↓
APIResponse<T>
    ↓
DTO
```

#### 5.5.2 TargetType Definition

**RULE**: Define APIs using enum conforming to `TargetType`.

**Example:**
```swift
// FaceScanAPI.swift
private enum FaceScanTarget: TargetType {
    case scan(request: FaceScanRequest)

    var baseURL: URL { QACheck.baseURL }
    var path: String { "/faceScan" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? { nil }
    var task: NetworkTask {
        switch self {
        case .scan(let request):
            return .requestJSONEncodable(request)
        }
    }
}

enum FaceScanAPI {
    private static let provider = NetworkService(
        plugins: [
            PrettyNetworkLoggerPlugin(),
            AuthPlugin()
        ]
    )

    static func scan(imageUrl: String) async throws -> FaceScanDTO {
        let request = FaceScanRequest(imageUrl: imageUrl)
        return try await provider.request(FaceScanTarget.scan(request: request))
    }
}
```

#### 5.5.3 Plugin System

**RULE**: Use plugins for cross-cutting concerns.

**Common plugins:**
- `PrettyNetworkLoggerPlugin()` - Network logging
- `AuthPlugin()` - Authentication headers

**Example:**
```swift
struct AuthPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) async -> URLRequest {
        var request = request

        let uid = UserHelper.shared.uid
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)

        request.setValue(uid, forHTTPHeaderField: "uid")
        request.setValue("\(timestamp)", forHTTPHeaderField: "timestamp")
        request.setValue(calculateSignature(...), forHTTPHeaderField: "authSecret")

        return request
    }
}
```

#### 5.5.4 APIResponse Generic Structure

**RULE**: Wrap all API responses in generic `APIResponse<T>`.

**Structure:**
```swift
struct APIResponse<T: Codable & Sendable>: Codable, Sendable {
    let success: Bool
    let errCode: String?
    let errMessage: String?
    let data: T?
}

extension NetworkService {
    func request<T: Codable>(_ target: TargetType) async throws -> T {
        let data: Data = try await request(target)
        let response = try JSONDecoder().decode(APIResponse<T>.self, from: data)

        guard response.success else {
            throw APIError.customError(response.errCode, response.errMessage)
        }

        guard let responseData = response.data else {
            throw APIError.noData
        }

        return responseData
    }
}
```

#### 5.5.5 Error Handling & Retry

**RULE**: Define custom error types for API failures.

**Example:**
```swift
enum APIError: Error, LocalizedError {
    case noData
    case customError(String?, String?)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .noData:
            return "服务器未返回数据"
        case .customError(let code, let message):
            return "\(code ?? ""): \(message ?? "")"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        }
    }
}
```

---

## VI. Dependency Injection

### 6.1 Constructor Injection

**RULE**: ViewModels MUST use constructor injection for dependencies.

#### 6.1.1 ViewModel Dependency Injection

**MANDATORY pattern:**
```swift
@MainActor
@Observable
final class ExercisesMainViewModel {
    private let repository: ExerciseRepository
    private let logger = AppLogger(category: "ExercisesMainViewModel")

    init(
        date: Date = Date(),
        repository: ExerciseRepository = DefaultExerciseRepository()
    ) {
        self.repository = repository
    }
}
```

**Benefits:**
- Easy to test (inject mock repository)
- Clear dependencies
- No hidden global state

#### 6.1.2 Default Parameters

**RULE**: MUST provide default parameters for production implementations.

**Rationale**: Allows Views to create ViewModels without specifying dependencies while still allowing test injection.

**Example:**
```swift
// Production usage (uses defaults)
@State private var viewModel = ExerciseViewModel()

// Test usage (inject mock)
@State private var viewModel = ExerciseViewModel(
    repository: MockExerciseRepository()
)
```

#### 6.1.3 Protocol Dependency Preferred

**RULE**: Depend on protocols, not concrete implementations.

**✅ CORRECT:**
```swift
init(repository: ExerciseRepository = DefaultExerciseRepository()) {
    // Depends on protocol ^
}
```

**❌ WRONG:**
```swift
init(repository: DefaultExerciseRepository = DefaultExerciseRepository()) {
    // Depends on concrete implementation ^
}
```

---

### 6.2 SwiftUI Environment Injection

**RULE**: Use `@Environment` for global app state that needs to be accessed across many Views.

#### 6.2.1 @Environment Usage Scenarios

**Appropriate uses:**
- App navigation state
- Global theme/appearance settings
- User authentication state
- Toast/Alert helpers

**Example:**
```swift
@Observable
final class AppNavigationPath {
    var navigationPath = NavigationPath()
}

@Observable
final class AppSettings {
    var isDarkMode: Bool = false
    var language: String = "en"
}
```

#### 6.2.2 Global State Management

**Setup in App:**
```swift
@main
struct SwiftUILabApp: App {
    @State private var navigationPath = AppNavigationPath()
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigationPath)
                .environment(settings)
        }
    }
}
```

**Access in View:**
```swift
struct ExampleView: View {
    @Environment(AppNavigationPath.self) private var navigationPath
    @Environment(AppSettings.self) private var settings

    var body: some View {
        Button("Navigate") {
            navigationPath.navigationPath.append(Destination.detail)
        }
    }
}
```

#### 6.2.3 Custom EnvironmentKey

**When needed:** For non-@Observable types or legacy compatibility.

**Example:**
```swift
private struct AppStateKey: EnvironmentKey {
    static let defaultValue: AppState = .main
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}
```

---

### 6.3 Singleton Pattern

**RULE**: Use singletons ONLY for stateless utilities and managers.

#### 6.3.1 Limited Use Scenarios

**Appropriate uses:**
- Database helper (GRDBHelper)
- Product manager (ProductHelper)
- Logging infrastructure (AppLogger internally)
- Network monitor

**NOT appropriate:**
- ViewModels
- Repositories
- User-specific state

#### 6.3.2 Naming Convention

**MANDATORY**: Use `shared` as the singleton property name.

**Example:**
```swift
final class GRDBHelper {
    static let shared = GRDBHelper()

    private init() {
        // Prevent external initialization
    }
}
```

#### 6.3.3 Thread Safety Requirement

**RULE**: Singletons MUST be thread-safe.

**Swift's lazy initialization is thread-safe:**
```swift
final class ProductHelper {
    static let shared = ProductHelper()  // Thread-safe

    private init() { }
}
```

**For complex initialization, use `@MainActor`:**
```swift
@MainActor
final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private init() {
        // Complex setup
    }
}
```

---

## VII. Coding Style

### 7.1 Comment Standards

**CRITICAL REQUIREMENT**: All comments MUST be in **Chinese**.

#### 7.1.1 Chinese Comment Mandate

**RULE**: Every public and private property, method, and Sub-View MUST have a Chinese comment.

**Format:**
- Use `///` for documentation comments
- Single-line, concise description
- Explain **what**, not **how**

#### 7.1.2 Concise Comment Style

**MANDATORY style:**
- ✅ One line describing purpose
- ❌ NO parameter descriptions (`- Parameter:`)
- ❌ NO return value descriptions (`- Returns:`)
- ❌ NO multi-line structured documentation

#### 7.1.3 What to Comment

**MUST comment:**
- All public properties and methods
- All private properties and methods
- All Sub-Views (`@ViewBuilder` properties)
- All classes, structs, enums
- Complex logic or business rules

**NO comment needed:**
- `init` methods (unless complex logic)

#### 7.1.4 Good vs. Bad Examples

**✅ GOOD Examples:**

```swift
// Properties
/// 用户名
var username: String

/// 是否显示加载指示器
@State private var isLoading = false

/// 当前选中的标签页索引
@State private var selectedTab = 0

// Sub-Views
/// 顶部导航栏
@ViewBuilder
private var navigationBar: some View { }

/// 用户信息卡片
@ViewBuilder
private var userCard: some View { }

// Methods
/// 加载用户数据
func loadUserData() { }

/// 刷新列表
private func refreshList() { }

/// 验证输入格式
private func validateInput() -> Bool { }

// Classes/Structs
/// 练习功能的视图模型
@MainActor
@Observable
final class ExerciseViewModel { }
```

**❌ BAD Examples:**

```swift
// Too detailed with parameters
/// 加载用户数据
/// - Parameter userId: 用户ID
/// - Parameter force: 是否强制刷新
/// - Returns: 用户数据对象
func loadUserData(userId: String, force: Bool) -> User { }

// English comments
/// Load user data
func loadUserData() { }

// Describing implementation instead of purpose
/// 通过调用 API 获取数据并解析 JSON 返回
func loadUserData() { }

// Too verbose
/// 这个方法用于从服务器加载用户数据
/// 如果网络失败会显示错误提示
/// 成功后会更新界面显示
func loadUserData() { }
```

#### 7.1.5 Comment Placement

**RULE**: Comments MUST be placed:
- **Immediately above** the element being documented
- With **NO blank lines** between comment and element

**Example:**
```swift
/// 用户名
var username: String  // ✅ Correct

/// 用户名

var username: String  // ❌ Wrong - blank line
```

---

### 7.2 Naming Conventions

#### 7.2.1 Type Naming (PascalCase)

| Type | Convention | Example |
|------|-----------|---------|
| **Class** | Noun, PascalCase | `ExerciseViewModel` |
| **Struct** | Noun, PascalCase | `FaceScanResult` |
| **Enum** | Noun, PascalCase | `PSLLevel` |
| **Protocol** | Noun or Adjective, PascalCase | `ExerciseRepository`, `Identifiable` |

#### 7.2.2 Repository & DataSource Naming

**Specific conventions:**

| Type | Pattern | Example |
|------|---------|---------|
| **Repository Protocol** | `{Entity}Repository` | `ExerciseRepository` |
| **Repository Implementation** | `Default{Entity}Repository` | `DefaultExerciseRepository` |
| **Local DataSource Protocol** | `Local{Entity}DataSource` | `LocalFaceScanResultDataSource` |
| **Local DataSource Implementation** | `DefaultLocal{Entity}DataSource` | `DefaultLocalFaceScanResultDataSource` |
| **Remote DataSource Protocol** | `Remote{Entity}DataSource` | `RemoteFaceScanResultDataSource` |
| **Remote DataSource Implementation** | `DefaultRemote{Entity}DataSource` | `DefaultRemoteFaceScanResultDataSource` |

#### 7.2.3 Method & Property Naming (camelCase)

**Rules:**
- Methods: Start with verb
- Properties: Start with noun or adjective
- Boolean properties: Use `is`, `has`, `should` prefix

**Examples:**
```swift
// Methods
func loadUserData() { }
func validateInput() -> Bool { }
func markCompleted(_ exercise: Exercise) { }

// Properties
var username: String
var exerciseCount: Int
var isCompleted: Bool
var hasPermission: Bool
var shouldRefresh: Bool
```

#### 7.2.4 Constant Naming

**Global constants**: PascalCase or UPPER_SNAKE_CASE

```swift
let MaxRetryCount = 3
let DEFAULT_TIMEOUT: TimeInterval = 30
```

**Local constants**: camelCase

```swift
func processData() {
    let maxIterations = 100
    let defaultValue = ""
}
```

#### 7.2.5 File Naming

**RULE**: File name MUST match primary type name.

| File | Primary Type |
|------|-------------|
| `ExerciseViewModel.swift` | `ExerciseViewModel` |
| `FaceScanResult.swift` | `FaceScanResult` |
| `ExerciseRepository.swift` | `ExerciseRepository` |
| `String+Extensions.swift` | Extension on `String` |

---

### 7.3 Access Control Standards

#### 7.3.1 Minimum Visibility Principle

**RULE**: Use the most restrictive access level that fulfills requirements.

**Default hierarchy:**
```
private < fileprivate < internal < public < open
```

**Guidelines:**
- Start with `private`
- Elevate only when necessary
- Never use `open` (no subclassing allowed in this architecture)

#### 7.3.2 Access Level Usage

| Level | Usage |
|-------|-------|
| `private` | Implementation details within same type |
| `fileprivate` | Shared within same file (rare, avoid) |
| `internal` | Default, accessible within module |
| `public` | Accessible from other modules (frameworks) |
| `open` | NOT USED (no subclassing) |

#### 7.3.3 @ViewBuilder Visibility

**RULE**: Sub-Views MUST be `private`.

**Example:**
```swift
struct ExerciseView: View {
    var body: some View {
        contentView
    }

    /// 主内容视图
    @ViewBuilder
    private var contentView: some View {  // MUST be private
        ScrollView {
            // ...
        }
    }
}
```

#### 7.3.4 ViewModel Property Visibility

**Pattern:**
```swift
@Observable
final class ViewModel {
    // Public read-only
    private(set) var exercises: [Exercise] = []

    // Private
    private let repository: ExerciseRepository
    private var cancellables = Set<AnyCancellable>()
}
```

---

### 7.4 Type & Protocol Standards

#### 7.4.1 Struct vs. Class

**Decision matrix:**

| Use `struct` when: | Use `class` when: |
|-------------------|------------------|
| Value semantics needed | Reference semantics needed |
| Small, simple data | Large, complex state |
| Immutable or mostly immutable | Mutable state |
| No inheritance needed | Inheritance needed |
| Thread-safety important | - |

**Examples:**
```swift
// ✅ Struct for entities
struct Exercise: Identifiable {
    let id: Int
    let name: String
}

// ✅ Class for ViewModels
@Observable
final class ExerciseViewModel {
    var exercises: [Exercise] = []
}

// ✅ Class for managers
final class GRDBHelper {
    static let shared = GRDBHelper()
}
```

#### 7.4.2 Final Class Requirement

**RULE**: All classes MUST be `final` unless designed for inheritance.

**Rationale**:
- This architecture doesn't use inheritance
- Prevents unintended subclassing
- Performance optimization

**Example:**
```swift
// ✅ CORRECT
final class DefaultExerciseRepository: ExerciseRepository { }

@Observable
final class ExerciseViewModel { }

// ❌ WRONG (unless justified)
class DefaultExerciseRepository: ExerciseRepository { }
```

#### 7.4.3 Protocol Naming

**Conventions:**

| Type | Example |
|------|---------|
| Capability | `Identifiable`, `Hashable`, `Codable` |
| Repository | `ExerciseRepository` |
| DataSource | `LocalFaceScanResultDataSource` |
| Delegate (rare) | `NetworkServiceDelegate` |

**NO `-able` suffix for domain protocols:**
```swift
// ✅ CORRECT
protocol ExerciseRepository { }

// ❌ WRONG
protocol ExerciseRepositoryProtocol { }
```

#### 7.4.4 Extension Organization

**RULE**: Group related functionality in extensions.

**Pattern:**
```swift
// Main type definition
struct FaceScanResult {
    let id: UUID
    let pslScore: Int
}

// MARK: - Computed Properties
extension FaceScanResult {
    var tier: PSLTier {
        // Calculate tier from pslScore
    }
}

// MARK: - Business Logic
extension FaceScanResult {
    func canPerformAction() -> Bool {
        // Business rule
    }
}
```

**Extensions for protocol conformance:**
```swift
extension FaceScanResult: Identifiable { }
extension FaceScanResult: Hashable { }
```

---

## VIII. Reactive Programming

### 8.1 Combine Usage Standards

#### 8.1.1 Publisher Definition

**RULE**: Repository methods that provide real-time updates MUST return Publishers.

**Naming convention:**
- Method name ends with `Publisher`
- Return type: `AnyPublisher<T, Never>` or `AnyPublisher<T, Error>`

**Example:**
```swift
protocol ExerciseRepository {
    /// 响应式获取推荐的 Exercise
    func recommendedExercisePublisher(for date: Date) -> AnyPublisher<Exercise?, Never>
}
```

#### 8.1.2 Subscription Management

**MANDATORY pattern:**
```swift
@Observable
final class ExerciseViewModel {
    private var cancellables = Set<AnyCancellable>()

    private func setupSubscriptions() {
        repository.recommendedExercisePublisher(for: date)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exercise in
                self?.recommendedExercise = exercise
            }
            .store(in: &cancellables)
    }
}
```

**MANDATORY rules:**
- Use `[weak self]` to prevent retain cycles
- Use `.receive(on: DispatchQueue.main)` for UI updates
- Store all subscriptions in `cancellables`

#### 8.1.3 Thread Scheduling

**RULE**: UI-bound Publishers MUST use `.receive(on: DispatchQueue.main)`.

**Example:**
```swift
repository.dataPublisher()
    .receive(on: DispatchQueue.main)  // MANDATORY for UI updates
    .sink { [weak self] data in
        self?.updateUI(data)
    }
    .store(in: &cancellables)
```

#### 8.1.4 Error Handling in Publishers

**Pattern for non-failable streams:**
```swift
observation.publisher(in: dbQueue)
    .catch { [weak self] error -> Just<[Exercise]> in
        self?.logger.error("查询失败: \(error.localizedDescription)")
        return Just([])  // Return empty array on error
    }
    .eraseToAnyPublisher()
```

**Pattern for failable streams:**
```swift
func fetchDataPublisher() -> AnyPublisher<Data, Error> {
    URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
}
```

---

### 8.2 @Observable Macro Standards

#### 8.2.1 ViewModel Mandatory Usage

**RULE**: ALL ViewModels MUST use `@Observable` (SwiftUI 6+).

**Pattern:**
```swift
@MainActor
@Observable
final class ExerciseViewModel {
    // Properties automatically tracked
    var exercises: [Exercise] = []
    var isLoading: Bool = false
}
```

**Benefits over `@Published`:**
- No need for `@StateObject` in View
- Better performance
- Simpler syntax

#### 8.2.2 Integration with Combine

**Pattern**: @Observable can coexist with Combine publishers.

**Example:**
```swift
@MainActor
@Observable
final class ExerciseViewModel {
    // Observable properties
    var recommendedExercise: Exercise?

    private let repository: ExerciseRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: ExerciseRepository = DefaultExerciseRepository()) {
        self.repository = repository
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        // Combine publisher updates Observable property
        repository.recommendedExercisePublisher(for: Date())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exercise in
                self?.recommendedExercise = exercise  // View auto-updates
            }
            .store(in: &cancellables)
    }
}
```

#### 8.2.3 Performance Optimization

**Tips:**
- Avoid unnecessary property changes (View won't re-render)
- Group related property updates
- Use `private(set)` for read-only properties

**Example:**
```swift
@Observable
final class ViewModel {
    // Read-only to View
    private(set) var exercises: [Exercise] = []

    func loadData() {
        // Batch update
        let newExercises = repository.getAll()
        exercises = newExercises  // Single update
    }
}
```

---

### 8.3 ValueObservation (GRDB)

#### 8.3.1 Database Reactive Queries

**RULE**: Use `ValueObservation` for real-time database queries.

**Pattern:**
```swift
func allResultsPublisher(includeDeleted: Bool) -> AnyPublisher<[FaceScanResult], Never> {
    let observation = ValueObservation.tracking { db -> [FaceScanResult] in
        var query = FaceScanResultRecord.all()

        if !includeDeleted {
            query = query.filter(Column("isDeleted") == false)
        }

        let records = try query.order(Column("createdAt").desc).fetchAll(db)
        return records.map { $0.toDomain() }
    }

    return observation.publisher(in: dbQueue)
        .catch { [weak self] error -> Just<[FaceScanResult]> in
            self?.logger.error("查询失败: \(error.localizedDescription)")
            return Just([])
        }
        .eraseToAnyPublisher()
}
```

#### 8.3.2 Publisher Conversion

**RULE**: Convert `ValueObservation` to Combine `Publisher`.

**Pattern:**
```swift
// ValueObservation
let observation = ValueObservation.tracking { db in
    try Record.fetchAll(db)
}

// Convert to Publisher
let publisher = observation.publisher(in: dbQueue)
    .eraseToAnyPublisher()
```

#### 8.3.3 Performance Considerations

**Tips:**
- Limit observation scope (filter early)
- Use indexes on filtered columns
- Avoid observing entire tables unnecessarily

**Example:**
```swift
// ✅ GOOD - Filtered observation
let observation = ValueObservation.tracking { db in
    try Record
        .filter(Column("userId") == currentUserId)  // Filter early
        .fetchAll(db)
}

// ❌ BAD - Observing entire table
let observation = ValueObservation.tracking { db in
    let all = try Record.fetchAll(db)
    return all.filter { $0.userId == currentUserId }  // Filter late
}
```

---

## IX. Error Handling & Logging

### 9.1 Error Handling Standards

#### 9.1.1 Error Type Definition

**RULE**: Define custom error types for each layer.

**Pattern:**
```swift
enum RepositoryError: Error {
    case notFound
    case invalidData
    case databaseError(Error)
}

enum APIError: Error, LocalizedError {
    case noData
    case customError(String?, String?)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .noData:
            return "服务器未返回数据"
        case .customError(let code, let message):
            return "\(code ?? ""): \(message ?? "")"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        }
    }
}
```

#### 9.1.2 Throws vs. Result

**When to use `throws`:**
- Synchronous operations that can fail
- Operations where errors are exceptional
- Most repository and data source methods

**When to use `Result`:**
- Asynchronous callbacks (legacy, use `async/await` instead)
- When success and failure are equally expected
- When passing errors through non-throwing contexts

**Examples:**
```swift
// ✅ Throws (preferred for sync)
func saveExercise(_ exercise: Exercise) throws {
    try dbQueue.write { db in
        try record.save(db)
    }
}

// ✅ Async/await (preferred for async)
func fetchData() async throws -> Data {
    try await URLSession.shared.data(from: url).0
}

// ⚠️ Result (rare, legacy compatibility)
func loadData(completion: @escaping (Result<Data, Error>) -> Void) {
    // Legacy callback-based API
}
```

#### 9.1.3 Error Propagation Rules

**RULE**: Catch errors at ViewModel layer, not in Repository.

**Pattern:**
```swift
// Repository - propagate errors
final class DefaultExerciseRepository: ExerciseRepository {
    func markCompleted(_ exercise: Exercise) throws {
        try localDataSource.markCompleted(exercise)  // Propagate
    }
}

// ViewModel - handle errors
@Observable
final class ExerciseViewModel {
    func markCompleted(_ exercise: Exercise) {
        do {
            try repository.markCompleted(exercise)
            logger.info("标记完成成功")
        } catch {
            logger.error("标记完成失败: \(error.localizedDescription)")
            showError(error)  // Display to user
        }
    }

    private func showError(_ error: Error) {
        // Show user-friendly error
    }
}
```

#### 9.1.4 User-Friendly Error Display

**RULE**: Display user-friendly error messages, not technical details.

**Example:**
```swift
@Observable
final class ViewModel {
    var errorMessage: String?

    func handleError(_ error: Error) {
        errorMessage = switch error {
        case RepositoryError.notFound:
            "未找到数据"
        case APIError.networkError:
            "网络连接失败，请检查网络设置"
        default:
            "操作失败，请稍后重试"
        }
    }
}

// View
.alert("错误", isPresented: $hasError) {
    Button("确定") { }
} message: {
    Text(viewModel.errorMessage ?? "")
}
```

---

### 9.2 Logging Standards

#### 9.2.1 AppLogger Usage

**MANDATORY**: Use `AppLogger` for all logging.

**Pattern:**
```swift
private let logger = AppLogger(category: "DefaultExerciseRepository")

func loadData() {
    logger.debug("开始加载数据")
    logger.info("成功加载 \(count) 条记录")
}
```

#### 9.2.2 Chinese Logging Requirement

**RULE**: ALL log messages MUST be in Chinese.

**Example:**
```swift
// ✅ CORRECT
logger.info("加载用户数据成功，共 \(count) 条")
logger.error("保存失败: \(error.localizedDescription)")

// ❌ WRONG
logger.info("Loaded \(count) records")
logger.error("Save failed: \(error)")
```

#### 9.2.3 Logging Levels

| Level | Usage | Example |
|-------|-------|---------|
| `debug` | Detailed flow for debugging | `logger.debug("开始查询数据库...")` |
| `info` | Important state changes | `logger.info("成功保存数据")` |
| `error` | Errors and exceptions | `logger.error("网络请求失败: \(error)")` |

**Example:**
```swift
func loadExercises() {
    logger.debug("开始加载 exercises")

    do {
        let exercises = try repository.getAll()
        logger.info("成功加载 \(exercises.count) 个 exercises")
    } catch {
        logger.error("加载 exercises 失败: \(error.localizedDescription)")
    }
}
```

#### 9.2.4 Sensitive Information Protection

**FORBIDDEN in logs:**
- User passwords
- Authentication tokens
- Personal identifiable information (PII)
- Credit card numbers

**Example:**
```swift
// ✅ CORRECT - Log user ID only
logger.info("用户登录成功: id=\(userId)")

// ❌ WRONG - Don't log password
logger.debug("登录信息: username=\(username), password=\(password)")

// ✅ CORRECT - Mask sensitive data
logger.info("API请求: token=\(token.prefix(8))...")
```

---

## X. Performance & Memory

### 10.1 Memory Management

#### 10.1.1 Retain Cycle Detection

**RULE**: Use `[weak self]` or `[unowned self]` in closures to prevent retain cycles.

**Pattern:**
```swift
@Observable
final class ViewModel {
    private var cancellables = Set<AnyCancellable>()

    func setupSubscriptions() {
        repository.dataPublisher()
            .sink { [weak self] data in
                self?.processData(data)
            }
            .store(in: &cancellables)
    }

    func loadData() async {
        Task { [weak self] in
            let data = try await self?.repository.fetchData()
            await self?.updateUI(data)
        }
    }
}
```

**When to use `weak` vs. `unowned`:**
- Use `[weak self]` when `self` might be deallocated (preferred)
- Use `[unowned self]` only when `self` is guaranteed to outlive closure

#### 10.1.2 Large Object Handling

**Guidelines:**
- Avoid loading large datasets into memory at once
- Use pagination for lists
- Stream large files instead of loading entirely

**Example:**
```swift
// ✅ GOOD - Paginated loading
func loadExercises(page: Int, pageSize: Int = 20) -> [Exercise] {
    let offset = page * pageSize
    return repository.getExercises(limit: pageSize, offset: offset)
}

// ❌ BAD - Load all at once
func loadExercises() -> [Exercise] {
    return repository.getAllExercises()  // Potentially thousands
}
```

#### 10.1.3 Image Caching

**RULE**: Use caching for frequently accessed images.

**Pattern:**
```swift
final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()

    func getImage(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
```

---

### 10.2 Performance Optimization

#### 10.2.1 Lazy Loading Strategy

**RULE**: Load data only when needed.

**Example:**
```swift
struct ExerciseView: View {
    @State private var viewModel = ExerciseViewModel()

    var body: some View {
        ScrollView {
            exerciseList
        }
        .onAppear {
            viewModel.loadDataIfNeeded()  // Lazy load
        }
    }
}

@Observable
final class ExerciseViewModel {
    private var isDataLoaded = false

    func loadDataIfNeeded() {
        guard !isDataLoaded else { return }

        loadData()
        isDataLoaded = true
    }
}
```

#### 10.2.2 List Performance Optimization

**Guidelines:**
- Use `LazyVStack` / `LazyHStack` for large lists
- Implement proper `Identifiable` conformance
- Avoid heavy computations in list cells

**Example:**
```swift
// ✅ GOOD - Lazy loading
ScrollView {
    LazyVStack(spacing: 16) {
        ForEach(exercises) { exercise in
            ExerciseRow(exercise: exercise)
        }
    }
}

// ❌ BAD - Eager loading
ScrollView {
    VStack(spacing: 16) {
        ForEach(exercises) { exercise in
            ExerciseRow(exercise: exercise)
        }
    }
}
```

#### 10.2.3 Database Query Optimization

**Guidelines:**
- Use indexes on frequently queried columns
- Filter data in SQL, not in Swift
- Limit result set size

**Example:**
```swift
// ✅ GOOD - Filter in SQL
let records = try dbQueue.read { db in
    try Record
        .filter(Column("userId") == userId)  // SQL WHERE
        .limit(20)
        .fetchAll(db)
}

// ❌ BAD - Filter in Swift
let records = try dbQueue.read { db in
    try Record.fetchAll(db)
}.filter { $0.userId == userId }
```

#### 10.2.4 Network Request Optimization

**Guidelines:**
- Cache network responses
- Batch multiple requests
- Cancel unnecessary requests
- Use appropriate timeout values

**Example:**
```swift
@Observable
final class ViewModel {
    private var currentTask: Task<Void, Never>?

    func loadData() {
        // Cancel previous request
        currentTask?.cancel()

        currentTask = Task {
            do {
                let data = try await repository.fetchData()
                await processData(data)
            } catch {
                handleError(error)
            }
        }
    }
}
```

---

## XI. Cross-Document References

### 11.1 Engineering Process Standards

> **See**: `ENGINEERING_AGENT_CONSTRAINTS.md`

This document focuses on **architecture design and coding standards**.

After completing development tasks, you MUST follow the engineering process standards for verification and submission:

**Verification Process:**
1. Run `swiftformat ./` (code formatting)
2. Run `periphery scan` (unused code detection)
3. Run `xcodebuild build` (compilation verification)

**Git Commit Standards:**
- Use emoji binding: feat:✨, fix:🐛, refactor:♻️, docs:📝, chore:🔧
- Write commit messages in Chinese
- Follow single-line format

**Completion Checklist:**
```
Done Checklist:
- 🎨 swiftformat: PASS / SKIP
- 🔍 periphery: PASS / SKIP
- 🧪 Verification: PASS / FAIL
  - ▶ Commands executed:
- 📦 Git commit: DONE / NOT DONE
  - 📝 Commit message:
```

---

### 11.2 Quick Reference

#### Architecture Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────────┐              ┌──────────────────────┐ │
│  │     View     │ ──reads──>   │     ViewModel        │ │
│  │  (SwiftUI)   │              │   (@Observable)      │ │
│  └──────────────┘              └──────────────────────┘ │
│         │                                │               │
│         │ user actions                   │ uses protocol │
│         └────────────────────────────────┘               │
└──────────────────────────────┬──────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                        │
│  ┌──────────────────────┐          ┌─────────────────┐  │
│  │  Repository Protocol │          │     Entity      │  │
│  │    (Interface)       │          │  (struct/enum)  │  │
│  └──────────────────────┘          └─────────────────┘  │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │       Repository Implementation                  │    │
│  │    (Default*Repository)                          │    │
│  └─────────────────────────────────────────────────┘    │
│                  │                    │                  │
│         ┌────────┘                    └────────┐         │
│         ▼                                      ▼         │
│  ┌─────────────────┐              ┌─────────────────┐   │
│  │ Local DataSource│              │Remote DataSource│   │
│  │   (GRDB)        │              │  (NetworkService│   │
│  └─────────────────┘              └─────────────────┘   │
│         │                                      │         │
│         ▼                                      ▼         │
│  ┌─────────────────┐              ┌─────────────────┐   │
│  │     Record      │              │      DTO        │   │
│  │  (Database)     │              │   (Network)     │   │
│  └─────────────────┘              └─────────────────┘   │
│         │                                      │         │
│         └──────────────┬───────────────────────┘         │
│                        │ convert to                      │
│                        ▼                                 │
│                  ┌─────────────────┐                     │
│                  │     Entity      │                     │
│                  │   (Domain)      │                     │
│                  └─────────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

#### Data Flow Sequence

```
Request Flow:
View → ViewModel → Repository → DataSource → Database/Network

Response Flow:
Database/Network → DTO/Record → (convert) → Entity → ViewModel → View
```

#### Code Templates

**Repository Protocol:**
```swift
protocol ExerciseRepository {
    /// 响应式获取推荐的 Exercise
    func recommendedExercisePublisher(for date: Date) -> AnyPublisher<Exercise?, Never>

    /// 获取推荐的 Exercise
    func getRecommendedExercise(for date: Date) -> Exercise

    /// 标记 exercise 为完成
    func markExerciseCompleted(_ exercise: Exercise, for date: Date) throws
}
```

**ViewModel Template:**
```swift
/// {Feature} 功能的视图模型
@MainActor
@Observable
final class {Feature}ViewModel {
    // MARK: - Properties

    /// {Description}
    private(set) var data: [Item] = []

    private let repository: {Feature}Repository
    private let logger = AppLogger(category: "{Feature}ViewModel")
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(repository: {Feature}Repository = Default{Feature}Repository()) {
        self.repository = repository
        setupSubscriptions()
    }

    // MARK: - Public Methods

    /// 加载数据
    func loadData() {
        // Implementation
    }

    // MARK: - Private Methods

    private func setupSubscriptions() {
        // Implementation
    }
}
```

**View Template:**
```swift
/// {Feature} 主视图
struct {Feature}MainView: View {
    // MARK: - Properties

    @State private var viewModel = {Feature}ViewModel()

    // MARK: - Body

    var body: some View {
        contentView
            .navigationTitle("{Title}")
            .onAppear {
                viewModel.loadData()
            }
    }

    // MARK: - Sub-Views

    /// 主内容视图
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            // Layout
        }
    }
}

#Preview {
    {Feature}MainView()
}
```

---

## ABSOLUTE RULE

If this specification cannot be followed exactly, the SwiftUI iOS code **MUST NOT be accepted**.

Any violation of requirements defined in this document renders the code invalid and requires revision until full compliance is achieved.

---

**End of Document**
