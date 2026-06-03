# Prompto

> **"Duolingo for AI skills"** — bite-sized micro-lessons that teach prompt
> engineering, with a live, AI-graded **Prompt Lab** at the core.

A Flutter prototype built from a single codebase to run on **Android now** and
make a later **iOS** release as cheap as possible. It is clickable end-to-end
with realistic sample data and **no backend** — every data source is a fake
repository behind a clean interface, ready to swap for a real API.

---

## Quick start

> Requires Flutter **3.27+** (Dart 3.6+). Check with `flutter doctor`.

```bash
# 1. Generate the platform runners (android/, ios/, …) for this app.
#    This does NOT touch lib/ or pubspec.yaml.
flutter create .

# 2. Install dependencies.
flutter pub get

# 3. Run on an Android emulator / device (or iOS simulator on a Mac).
flutter run

# Tests (pure-Dart domain/data logic):
flutter test
```

> **Why `flutter create .`?** The platform folders are intentionally
> git-ignored to keep the prototype focused on the cross-platform code. The
> command regenerates them from your local Flutter version, avoiding stale
> Gradle/Xcode config. See *Releasing iOS* below for the manifest/Info.plist
> entries you'll add once notifications are wired.

---

## Architecture

A strict **layered** architecture keeps business logic out of the UI and free
of any platform assumptions:

```
presentation  →  domain  ←  data
   (UI + Riverpod)   (pure Dart:        (fake repositories,
                      entities +         sample data,
                      repo interfaces)   in-memory store)
```

- **`domain`** is pure Dart — no Flutter imports — so the logic is portable and
  unit-testable. It defines entities and **repository interfaces** only.
- **`data`** implements those interfaces with in-memory fakes today; swapping in
  Dio/Drift later touches *only* this layer.
- **`presentation`** holds widgets + Riverpod controllers. UI never talks to
  `data` directly — only through domain interfaces resolved by providers.
- Platform-specific capabilities (notifications, billing) sit behind
  `core/services` abstractions, so iOS is an implementation swap, not a rewrite.

### Tech stack & why

| Concern | Choice | Rationale |
|---|---|---|
| UI toolkit | **Flutter + Dart** | One codebase → Android + iOS. |
| Design | **Material 3** + adaptive seams | M3 base; Cupertino page transitions + adaptive layout already in place. |
| State | **Riverpod** | `AsyncValue` gives free loading/success/error; lighter than Bloc for this app. |
| Navigation | **go_router** | Declarative, deep-link ready, `StatefulShellRoute` for the bottom nav. |
| Local data | In-memory store (Drift-ready seam) | Keeps the prototype compiling without codegen; Drift recommended next. |
| Async | `Future` / `Stream` | Progress is a stream → streak/XP update reactively everywhere. |

---

## Project structure

```
lib/
├─ main.dart                      App entry; ProviderScope (composition root) + MaterialApp.router.
├─ core/
│  ├─ router/
│  │  ├─ app_router.dart          go_router config: shell + lesson/paywall/settings routes, onboarding redirect.
│  │  └─ routes.dart              Centralised path constants.
│  ├─ theme/app_theme.dart        Material 3 light/dark from one seed; per-platform page transitions.
│  ├─ services/reminder_service.dart  Notification abstraction (+ no-op impl) — isolates platform APIs.
│  ├─ utils/day.dart              Date-only helpers for streak math.
│  └─ widgets/
│     ├─ async_value_widget.dart  Uniform loading/error rendering for any AsyncValue.
│     └─ state_views.dart         Reusable empty + error state views.
├─ domain/                        PURE DART — no Flutter imports.
│  ├─ entities/                   SkillModule, Lesson, Exercise (sealed), Rubric, PromptEvaluation,
│  │                              UserProgress, UserProfile, PromptTemplate.
│  └─ repositories/               Interfaces: curriculum, progress, prompt-evaluation, library, user.
├─ data/
│  ├─ sources/
│  │  ├─ sample_data.dart         The seed curriculum + prompt library (stands in for a backend).
│  │  └─ in_memory_store.dart     Single source of truth for mutable state; broadcasts via streams.
│  └─ repositories/               Fake implementations of every domain interface.
│     └─ fake_prompt_evaluation_repository.dart  The heuristic stand-in for the live LLM grader.
└─ presentation/
   ├─ providers/                  Riverpod wiring: repository providers (composition root),
   │                              app state, lesson runtime + Prompt Lab controllers.
   ├─ shell/app_shell.dart        Bottom nav (NavigationBar) ↔ NavigationRail on wide screens.
   ├─ onboarding/                 First-run intro.
   ├─ learn/                      Skill tree (home) + stat header + lesson tiles.
   ├─ lesson/                     Lesson player, exercise views (theory / MCQ / Prompt Lab), completion.
   ├─ library/                    Curated prompt-template library.
   ├─ profile/                    XP / streak / level stats + account.
   ├─ settings/                   Theme, daily goal, reminders.
   └─ paywall/                    Transparent Free / Pro / Lifetime pricing (stubbed upgrade).
test/                             Unit tests for the grader heuristic and progress/streak logic.
```

---

## Implemented vs. stubbed

**Implemented (clickable, interactive):**
- Onboarding → skill tree → lesson player → completion loop with real back/forward nav.
- Lesson player with three exercise types: **theory cards, multiple-choice, and the Prompt Lab**.
- **Prompt Lab**: write a prompt → live rubric grade (per-criterion bars), simulated model
  output, concrete suggestions, before/after rewrite, and **iterate**.
- Streak / XP / level progression (XP scales with prompt quality); reactive across all screens.
- Lesson unlocking along the path; Pro-gated modules; daily free-evaluation cap → paywall.
- Prompt-template library with "why it works"; Profile stats; Settings (theme/goal/reminders);
  Paywall with a stubbed Pro upgrade.
- Empty / loading / error states, light & dark mode, responsive (phone bottom-nav ↔ wide rail).

**Stubbed (clear seams + `// TODO`s):**
- **Live LLM grading** → `FakePromptEvaluationRepository` (heuristic). Swap for a Dio-backed,
  provider-agnostic gateway.
- **Persistence** → `InMemoryStore`. Swap for Drift (recommended).
- **Auth** → local anonymous `UserProfile`.
- **Billing** → `upgradeToPro()` just flips a flag. Wire `in_app_purchase` / RevenueCat.
- **Notifications** → `NoopReminderService`. Implement with `flutter_local_notifications`.
- Content is hard-coded in `sample_data.dart` (no remote content sync yet).

---

## Recommended next steps (in order)

1. **Persistence (Drift).** Implement Drift-backed `ProgressRepository` + `UserRepository`
   behind the existing interfaces; keep the in-memory fakes for tests.
2. **Real grading API.** Build `ApiPromptEvaluationRepository` (Dio) calling a
   provider-agnostic LLM gateway; design the rubric→grade prompt; **cache** by
   `hash(prompt + taskId)` to control inference cost.
3. **Auth + account sync.** Replace the anonymous profile; define a sync/merge strategy
   for `UserProgress` (the sync-critical entity).
4. **Billing.** Integrate `in_app_purchase`; map products to `SubscriptionPlan`.
5. **Notifications.** Implement `ReminderService` for real; request permissions per platform.
6. **Content pipeline.** Move the curriculum to a versioned remote source (mitigates the
   "techniques go stale" risk) and seed Drift from it.
7. **Tests.** Add widget tests for the lesson flow and golden tests for light/dark.

---

## Releasing the iOS version

The code is already platform-neutral; iOS work is mostly configuration:

- **Toolchain:** Xcode + CocoaPods on a Mac; `flutter build ios`. Set bundle id,
  team, and signing certificates / provisioning profiles in Xcode (or via fastlane).
- **`ios/Runner/Info.plist`:** add only what you actually use. For daily reminders:
  no special key for local notifications, but you must call the iOS authorization
  flow (handled inside the real `ReminderService`). If you later add camera/mic,
  add the matching `NS*UsageDescription` strings (Android uses runtime permissions
  + `AndroidManifest.xml` instead).
- **Components to refine for native feel:** the theme already uses
  `CupertinoPageTransitionsBuilder`; review switches/dialogs/date pickers for
  `.adaptive` variants, and confirm safe-area + back-swipe behavior.
- **Push (if added):** APNs key/entitlement + a notifications backend.

---

## Assumptions, permissions & limitations

**Assumptions flagged in the concept analysis** (no value was given in the doc):
- Grading is a **deterministic heuristic** prototype (no real LLM/backend).
- **Anonymous local** account; auth deferred.
- XP = `baseXp × (0.5 + score/100 × 0.7)`; **100 XP per level**.
- Free tier = **5 live evaluations/day** (`kFreeDailyEvaluations`), then paywall.
- Streak continues if the gap is ≤ 1 day or a freeze is available.
- **English** UI strings (the concept doc is Polish); centralisable for i18n later.

**Permissions (MVP):** none required to run. Notifications (Android 13+
`POST_NOTIFICATIONS`; iOS authorization) are needed only when real reminders are
wired — already abstracted. No camera/location/storage permissions in scope.

**Known limitations:** in-memory state resets on restart; the grader is heuristic,
not a model; content is hard-coded; auth/billing/notifications are stubs;
platform folders are generated via `flutter create .`.
