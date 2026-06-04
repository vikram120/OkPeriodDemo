# OkPeriodDemo

UIKit + MVVM auth sample: **Google Sign-In → Firebase Auth**, or **email → local 6-digit OTP → Firebase Email/Password**. No storyboards. iOS 17+, Xcode 15+.

## Stack

| Layer | Notes |
|-------|--------|
| UI | Programmatic UIKit, `AppCoordinator`, reusable `PrimaryButton` / `OTPInputView` |
| SPM | `FirebaseAuth`, `FirebaseCore`, `GoogleSignIn` |
| OTP | `OTPManager` — in-memory code, 5m TTL; DEBUG logs one line; `123456` always passes (reviewer shortcut) |
| Auth | `FirebaseAuthService` / `GoogleSignInService` behind protocols; no VC → Firebase calls |

Add your own `GoogleService-Info.plist` (gitignored). Enable **Email/Password** + **Google** in Firebase. URL scheme in `Info.plist` must match `REVERSED_CLIENT_ID`.

## Run

```bash
open OkPeriodDemo.xcodeproj
```

⌘R on simulator. First open: let SPM resolve.

## Verify

- **Google:** Continue with Google → Home.
- **Email:** Continue with Email → any valid email → OTP. Use console code (`[OkPeriodDemo · OTP] email=… code=…`) or `123456`.
- **Logout:** Home → Log Out → confirm.

Users land in Firebase Console → Authentication after success.

## OTP rationale

Firebase Auth has no native email OTP. Production: Functions + mail provider. Here: client-side OTP to avoid Blaze/Functions; Firebase sign-in still runs after verify.

```
VC → VM → Services → Firebase Auth
              ↳ OTPManager (local verify only)
```

## Layout

`Coordinator/` · `ViewControllers/` · `ViewModels/` · `Services/` · `Components/` · `Utilities/`

## UI tokens

Primary `#4F46E5` · BG `#F8FAFC` / `#0F172A` · radius 12 · button 52pt

## Notes

- Transitive SPM (e.g. `swift-protobuf`) lives in DerivedData only — delete if it appears under `OkPeriodDemo/`.
- Package issues: Reset Package Caches.

## Screenshots

| Auth | Email | OTP | Home |
|------|-------|-----|------|
