// RainSDK — migration umbrella.
//
// The Rain SDK is now modular (ports & adapters): a vendor-free `RainCore` plus one adapter module
// per wallet provider (`RainPortal`, `RainPrivy`; Turnkey ships inside `RainCore` for now).
//
// This umbrella re-exports `RainCore` + `RainPortal` so `import RainSDK` keeps resolving during
// migration. It deliberately does **not** re-export `RainPrivy`: 1.x had no Privy support, so no
// existing `import RainSDK` can be relying on it, and pulling it in here would drag Privy's vendor
// SDK into the dependency graph of every umbrella consumer — the opposite of the modular split's
// point. Privy adopters depend on `rain-privy-ios` and `import RainPrivy` directly.
//
// Note this is **module-level** compatibility only: v2 is a source-breaking release —
// the 1.x entry point (`RainSDKManager()`, `initializePortal` / `initializeTurnkey` /
// `initialize`, `setWalletProvider`, `reset`, the `.portal` / `.turnkey` accessors) was replaced
// by `RainSdk.builder()` + `provider(_:)`, with no shims. Models, errors, and the deprecated
// `RainClient` method shims (see each module's `Deprecated.swift`) are still available.
// Migration guide: README "Migrating from 1.x".
//
// New integrations should depend on only the modules they use — e.g. a Portal-only app depends on
// `RainPortal` alone, so Turnkey's (and Privy's) vendor SDKs never enter its dependency graph.
// This umbrella will be deprecated on a published timeline once clients have migrated.

@_exported import RainCore
@_exported import RainPortal
