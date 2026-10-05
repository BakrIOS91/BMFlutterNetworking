# Flutter Application – Development Architecture Plan

---

# 1. Introduction

## 1.1 Purpose

This document defines the **architectural standards, folder structure, dependency rules, and governance model** for the Flutter application.

It serves as:

* A development blueprint
* A technical governance contract
* A scalability framework
* A team alignment reference

The objective is not just to build features — but to build a **secure, scalable, and maintainable digital product platform**.

---

## 1.2 Architectural Goals

1. **Scalability** – The system must grow without structural degradation.
2. **Isolation** – Features must remain independent.
3. **Maintainability** – Refactoring must remain low-risk.
4. **Predictability** – Code patterns must be consistent.
5. **Testability** – Business logic must be independently testable.
6. **Security** – Sensitive data must be protected.

---

# 2. Architectural Overview

We follow:

> **Scene-Based Modular Clean Architecture using BLoC + Freezed**

High-level flow:

```text
Presentation (Scenes)
        ↓
Services (Data & APIs)
        ↓
Core Infrastructure
```

Each layer has a single responsibility and strict dependency direction.

---

# 3. What Is a Scene?

## 3.1 Definition

A **Scene** is a self-contained functional module representing a user-facing feature or flow.

Examples:

* Splash
* Login
* Home
* Settings
* Tab Container

A Scene includes:

* UI Widgets
* BLoC state management
* Feature-specific logic

A Scene does NOT include:

* Networking implementation
* Global configuration
* Environment handling
* App-wide services

---

## 3.2 Scene Characteristics – Detailed Definitions

1. **Self-contained**
   *A Scene must encapsulate all the logic, UI, and state it needs to function.*

    * Includes its own widgets, BLoC, and supporting view models.
    * No reliance on other Scenes to render correctly or perform actions.
    * Enables the Scene to be developed, reviewed, and deployed independently.

2. **Isolated**
   *A Scene operates independently from other Scenes in terms of dependencies and effects.*

    * Cannot directly access another Scene’s state, widgets, or BLoCs.
    * Minimizes coupling, ensuring changes in one Scene do not break others.
    * Facilitates safer feature branching and parallel development.

3. **Replaceable**
   *A Scene can be swapped out without impacting the rest of the application.*

    * Must have a well-defined interface (Events, States, Inputs, Outputs).
    * Enables re-implementation, redesign, or feature versioning.
    * Supports A/B testing or future modularization without rewriting core systems.

4. **Testable**
   *A Scene must be easy to test in isolation.*

    * All business logic resides in BLoC or services, not widgets.
    * Allows unit, widget, and integration tests without relying on external Scenes or live APIs.
    * Supports CI/CD pipelines and ensures reliability for production releases.


## **Summary:**
A Scene is a **modular, independent, and fully testable feature**. These characteristics ensure scalability, maintainability, and safe refactoring in large Flutter applications.

---

# 4. Folder Structure & Governance Rules

Below is the enforced project structure:

```text
lib/
│
├── core/
│   ├── dependency_injector/
│   │   ├── dependency_injector.dart
│   │   └── dependency_injector.config.dart
│   ├── env/ --for obfuscation
│   │   ├── env.dart
│   │   └── env.g.dart
│   ├── notification_services/
│   │   ├── firebase_options.dart
│   │   └── notification_service_manager.dart
│   ├── preferences/
│   │   ├── app_preferences.dart
│   │   └── app_preferences.pref.g.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── app_router.gr.dart
│   └── theme/
│       ├── button_themes.dart
│       ├── text_theme.dart
│       └── theme_manager.dart
│
├── scenes/
│   ├── 0_splash_view/
│   │   ├── bloc/
│   │   │   ├── splash_bloc.dart
│   │   │   ├── splash_event.dart
│   │   │   └── splash_state.dart
│   │   └── view/
│   │       └── splash_view.dart
│   ├── 1_login_view/
│   │   ├── bloc/
│   │   │   ├── login_bloc.dart
│   │   │   ├── login_event.dart
│   │   │   └── login_state.dart
│   │   └── view/
│   │       ├── login_view.dart
│   │       └── widgets.dart
│   └── 3_tab_base_view/
│       ├── children/
│       │   ├── 1_home_view/
│       │   │   ├── bloc/
│       │   │   │   ├── home_bloc.dart
│       │   │   │   ├── home_event.dart
│       │   │   │   └── home_state.dart
│       │   │   └── view/
│       │   │       └── home_view.dart
│       │   └── 2_setting_view/
│       │       ├── bloc/
│       │       │   ├── setting_bloc.dart
│       │       │   ├── setting_event.dart
│       │       │   └── setting_state.dart
│       │       └── view/
│       │           └── setting_view.dart
│       └── tab_view/
│           ├── bloc/
│           │   ├── tab_view_bloc.dart
│           │   ├── tab_view_event.dart
│           │   └── tab_view_state.dart
│           └── view/
│               └── tab_view.dart
│
├── services/
│   ├── client/
│   │   └── auth_client.dart
│   ├── models/
│   │   └── auth_models.dart
│   ├── requests/
│   │   └── auth_requests.dart
│   ├── app_targets.dart
│   ├── app_token_refresh_handler.dart
│   └── authorized.dart
│
├── utilities/
│   ├── constants/
│   │   ├── app_enums.dart
│   │   ├── color_constants.dart
│   │   └── image_constants.dart
│   ├── extensions/
│   │   ├── app_localizations_extension.dart
│   │   └── context_extension.dart
│   ├── l10n/
│   │   ├── app_ar.arb
│   │   ├── app_en.arb
│   │   ├── app_language_manager.dart
│   │   ├── app_localizations.dart
│   │   ├── app_localizations_ar.dart
│   │   └── app_localizations_en.dart
│   └── reusables_widgets/
│       └── with_view_state.dart
│
└── main.dart
```

## 4.1 Core (Infrastructure Layer)

### Purpose

Global application infrastructure.

### Contains

* Dependency injection setup
* Routing configuration
* Theme management
* Environment configuration
* Notification setup
* Local preferences

### Rules

✅ May depend on external packages
❌ Must NOT depend on Scenes
❌ Must NOT contain business logic

Core must remain stable even if all Scenes change.

---

## 4.2 Scenes (Presentation Layer)

### Purpose

User-facing features and flows.

### Structure

```
feature/
  bloc/
  view/
```

### Rules

✅ May depend on Services, Core, Utilities
❌ Must NOT depend on other Scenes
❌ Must NOT directly call APIs
❌ Must NOT contain environment logic

### UI Rules

* UI triggers Events only
* No business logic in Widgets
* BLoC handles decisions
* States must be immutable

---

## 4.3 Services (Data Layer)

### Purpose

Backend communication and data handling.

### Contains

* API clients
* Request models
* Response models
* Token refresh handler
* Authorization management

### Rules

✅ May depend on Core and networking SDK
❌ Must NOT depend on Scenes
❌ Must NOT use BuildContext
❌ Must NOT contain UI logic

Services must remain pure Dart logic.

---

## 4.4 Utilities (Shared Toolkit)

### Purpose

Reusable generic helpers.

### Contains

* Constants
* Enums
* Extensions
* Localization
* Generic reusable widgets

### Rules

❌ Must NOT contain feature logic
❌ Must NOT import Scenes
✅ Must remain generic

---

# 5. Dependency Direction Diagram

```text
┌──────────────────────────────┐
│          Scenes              │
│  (UI + BLoC - Presentation)  │
└───────────────┬──────────────┘
                │
                ▼
┌──────────────────────────────┐
│          Services            │
│   (API Clients / Data)       │
└───────────────┬──────────────┘
                │
                ▼
┌──────────────────────────────┐
│            Core              │
│ (DI, Router, Theme, Env)     │
└──────────────────────────────┘
```

### Strict Rule

Dependencies must only flow downward.
No circular dependencies allowed.

---

# 6. State Management Strategy

We use:

* bloc
* flutter_bloc
* freezed

## State Flow

```
User Action → Event → BLoC → State → UI
```

### Rules

* States must be immutable
* Events represent user intent
* BLoC may call Services only
* No direct API calls in UI

---

# 7. Dependency Injection

We use:

* get_it
* injectable

### Rules

* All services must be registered in DI
* No manual instantiation inside Scenes
* Constructor injection only
* Avoid static global access

---

# 8. Core Technology Stack

This section defines the foundational technology decisions that power the architecture.
Each selection supports scalability, maintainability, and enterprise-grade governance.

---

## 8.1 State Management

**bloc + flutter_bloc**

We use event-driven state management to ensure deterministic UI behavior.

### Principles

* Event-driven state handling
* Clear UI / business logic separation
* Predictable state transitions
* Suitable for large team collaboration

### Architectural Role

```
UI → Event → BLoC → Service → State → UI
```

### Business Value

* Reduced UI bugs
* Deterministic behavior
* Easier debugging
* Scalable team development

---

## 8.2 Immutable Modeling

**freezed + freezed_annotation**

We use immutable data modeling to guarantee safe state transitions.

### Provides

* Immutable data classes
* Sealed state modeling
* Compile-time safety
* `copyWith` generation
* Equality & pattern matching support

### Why It Matters

* Prevents accidental state mutation
* Enables predictable BLoC behavior
* Improves testing reliability

---

## 8.3 Dependency Injection

**get_it + injectable**

All dependencies are managed via a centralized service locator with code generation.

### Capabilities

* Automatic service registration
* Singleton & lazy lifecycle control
* Environment-based binding
* Test-time overrides

### Governance Rules

* No manual instantiation inside Scenes
* Constructor injection only
* No global static access

### Business Value

* Loose coupling
* Easier upgrades
* Simplified testing
* Reduced technical debt

---

## 8.4 Routing

**auto_route**

Provides type-safe and centralized navigation.

### Features

* Type-safe navigation
* Centralized route definitions
* Route guards
* Deep linking support
* Nested routing support (Tabs / Flows)

### Business Value

* Prevents runtime navigation errors
* Supports scalable feature growth
* Enables complex app flows safely

---

## 8.5 Localization

**flutter_localizations + ARB files**

Implements scalable internationalization.

### Capabilities

* Multi-language support
* ARB-based string management
* RTL/LTR support
* Regional scalability

### Business Value

* Enables multi-market deployment
* Supports Arabic & international expansion
* Reduces localization regression risks

---

## 8.6 Environment Security

**envied**

Handles secure environment configuration.

### Capabilities

* Encrypted environment variables
* Secure API key storage
* Environment-based builds (Dev / QA / Prod)
* Compile-time variable injection

### Business Value

* Protects sensitive credentials
* Prevents accidental production exposure
* Supports multi-environment deployments

---

## 8.7 Notifications & Monitoring

### firebase_core

Initializes Firebase services.

### firebase_messaging

Push notifications & token lifecycle handling.

### flutter_local_notifications

Foreground & scheduled notifications.

### firebase_crashlytics

Production crash monitoring & diagnostics.

---

### Business Value

* Real-time crash reporting
* Faster production issue resolution
* Improved notification engagement
* Centralized production diagnostics

---

## 8.8 System Integration

**app_settings**

Allows redirection to device system settings when permissions are denied.

### Example Use Cases

* Location permission denied
* Notification permission disabled
* Camera access blocked

### Business Value

* Improves UX recovery flow
* Reduces user drop-off
* Simplifies permission handling

---

## 8.9 Internal Shared SDKs

### ld_flutter_utilities

Provides shared infrastructure components across company applications.

Includes:

* Root/Jailbreak detection
* Responsive helpers
* Shared UI components
* Security utilities
* Common extensions

---

### ld_flutter_networking

Provides standardized API communication layer.

Includes:

* Unified API handling
* Token injection
* Retry management
* Error standardization
* Multi-environment switching

---

### Business Value of Internal SDKs

* Cross-project consistency
* Reduced duplicate development
* Centralized updates
* Enterprise-level governance
* Faster onboarding for new teams

---

# 9. Security Architecture

Security layers include:

* Root/Jailbreak detection
* Token management
* Encrypted environment variables
* Release build obfuscation
* Centralized error handling

Sensitive assets protected:

* API keys
* Tokens
* Base URLs

---

# 10. Testing Strategy

## 10.1 Unit Testing

Targets:

* BLoCs
* Services
* Token handlers
* Utility logic

Pattern:

```
Given Initial State
When Event Occurs
Then Expected State Is Emitted
```

---

## 10.2 Mocking Strategy

* Use DI to inject mock services
* Avoid real API calls in tests
* Replace service implementations per environment

---

# 11. Coding Standards

## 11.1 Naming Conventions

### Files

* snake_case
* Example: `login_bloc.dart`

### Classes

* PascalCase
* Example: `LoginBloc`

### Variables

* camelCase
* Example: `loginState`

### Enums

* PascalCase
* Values in camelCase

---

## 11.2 Folder Naming

* Scenes prefixed with order number

    * `0_splash_view`
    * `1_login_view`

* Keep predictable ordering

---

## 11.3 BLoC File Naming

```
login_bloc.dart
login_event.dart
login_state.dart
login_bloc.freezed.dart
```

---

## 11.4 Widget Guidelines

* Keep widgets small
* Extract reusable components
* Avoid deeply nested widget trees
* No business logic inside widgets

---

## 11.5 Import Rules

* Prefer package imports
* Avoid relative imports between features
* No cross-scene imports

---

# 12. Architectural Guardrails (Non-Negotiable)

1. No business logic in UI.
2. Scenes must not depend on other Scenes.
3. Core must not depend on Scenes.
4. Services must not depend on UI.
5. All dependencies go through DI.
6. All states must be immutable.
7. No direct API calls from UI.
8. Utilities must remain feature-agnostic.

Violation of these rules leads to architectural decay.

---

# 13. Non-Functional Benefits

### Stability

Deterministic state reduces runtime crashes.

### Scalability

Features integrate without structural impact.

### Maintainability

Refactoring remains low risk.

### Security

Multi-layer protection.

### Team Productivity

Clear boundaries reduce merge conflicts.

---

# 14. Executive Business Summary

| Decision       | Technical Benefit     | Business Impact          |
| -------------- | --------------------- | ------------------------ |
| Modular Scenes | Feature isolation     | Faster delivery          |
| BLoC + Freezed | Deterministic state   | Fewer production crashes |
| DI             | Loose coupling        | Easy upgrades            |
| LDFlutter SDK  | Shared infrastructure | Faster development       |
| Obfuscation    | Secret protection     | Reduced security risk    |
| Crashlytics    | Runtime monitoring    | Faster issue resolution  |

---

# Final Conclusion

This architecture ensures the application evolves into:

* A scalable digital platform
* A secure enterprise-grade product
* A maintainable long-term codebase
* A developer-friendly ecosystem

It prevents architectural degradation and supports sustainable product growth.

