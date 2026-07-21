# StudyHub UI/UX Redesign

## Goal

StudyHub uses a mobile-first learner interface that feels motivating and
professional without hiding useful features or adding heavy visual effects. The
redesign preserves the existing repository, API, navigation, answer-safety, and
localization boundaries.

## Conceptual References

- [Material 3 Expressive research](https://design.google/library/expressive-material-design-google-research): use color, shape, size, motion, and containment strategically to make important actions easier to find.
- [Android accessibility guidance](https://developer.android.com/design/ui/mobile/guides/foundations/accessibility): maintain 48 dp touch targets, readable contrast, descriptive semantics, and non-color status cues.
- [Flutter adaptive input guidance](https://docs.flutter.dev/ui/adaptive-responsive/input): keep controls usable with touch, keyboard, and assistive input.
- [Flutter platform adaptations](https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations): preserve expected route transitions and Back behavior.
- [Duolingo core tabs redesign](https://blog.duolingo.com/core-tabs-redesign/): consistent headers, spacing, type, and navigation make a multi-feature product feel cohesive.
- [Duolingo learner research](https://blog.duolingo.com/how-duolingo-works-with-learners/): combine learning usefulness with delight, then validate decisions through testing.
- [Khan Academy content navigation](https://support.khanacademy.org/hc/en-us/articles/10629803091853-Update-View-mastery-and-assignment-information-within-exercises-videos-and-articles): keep learner context visible and reduce unnecessary navigation.

Quizlet, modern finance apps, and productivity apps were also reviewed at the
pattern level: compact metadata, one dominant action, predictable tab ownership,
and calm feedback. No proprietary screen, logo, illustration, animation, or
content was copied.

## Principles Adopted

- One dominant action per screen, with secondary actions grouped by intent.
- Central design tokens for semantic color, spacing, radius, icon size,
  elevation, content width, duration, and motion curve.
- Indigo for primary learning actions, teal for trusted success/support, warm
  color for attention or motivation, and neutral tinted surfaces for long study.
- Material icons with visible labels for important actions and status icons that
  supplement, rather than replace, text.
- Mobile content width and scroll behavior first; constrained readable width on
  web/tablet rather than a desktop dashboard.
- Short, non-blocking transitions that respect reduced-motion settings.
- Loading, empty, error, and success states use icon, title, explanation, and a
  clear recovery action where one exists.

## Principles Rejected

- No fake streaks, recommendation intelligence, rank, progress, or account data.
- No copied brand layouts, mascots, logos, proprietary illustrations, or emoji
  icon system.
- No gradients, glass blur, decorative background animation, or large asset pack.
- No automatic carousel or animation across long lists.
- No functional-looking Facebook control. Google sign-in is shown disabled and
  explicitly marked as coming soon because the backend contract does not support
  social authentication yet.
- No architecture rewrite, state-management package, or extra UI dependency.

## Shared System

- `AppColors`, `AppSpacing`, `AppRadii`, `AppIconSizes`, `AppElevation`, and
  `AppLayout` define reusable visual values.
- `AppMotion` owns standard durations and a reduced-motion-aware helper.
- `AppTheme` now covers cards, inputs, buttons, navigation, dialogs, sheets,
  dividers, list tiles, and progress feedback.
- `StudyHubPageHeader`, `StudyHubSectionHeader`, `StudyHubIconSurface`, and
  `StudyHubStateView` provide consistent hierarchy and state presentation.

## Screen Audit And Changes

- **Authentication:** branded welcome surface, stronger form hierarchy,
  scroll/keyboard safety, animated login/register transition, visible loading,
  icon-supported error state, password tooltip, and honest social-auth status.
- **Home:** removed repeated featured/mode entry points; retained one primary
  learning CTA, four real shortcuts, Study Materials discovery, account-aware
  greeting, and the answer-safety note.
- **Main navigation:** kept four honest top-level destinations and deep-route
  behavior; strengthened selected icons and the shell boundary.
- **Subject browsing:** added a shared page header, semantic subject icon mapping,
  consistent spacing, and the shared loading/error/empty system.
- **Question sets, search, saved, quiz, result, history, contribution, profile,
  and settings:** audited for route ownership, scrolling, safe areas, action
  clarity, correctness safety, and honest data. Their existing focused structures
  were retained; global tokens and theme improve consistency without rewriting
  feature logic.

## Accessibility And Responsive Decisions

- Controls use Material touch targets of at least 48 dp.
- Text and icons remain labeled; error/success states use text and symbols as well
  as color.
- Forms and state screens scroll, content wraps, and primary surfaces are bounded
  to readable widths.
- The app continues to test compact 360 px layouts and 1.5 text scale.
- Standard Navigator behavior remains intact, including focused quiz routes and
  discard confirmation.

## Illustration And Motion Decisions

No raster or third-party illustration assets were added. Branded icon surfaces
provide lightweight visual anchors with reliable fallback behavior. Motion uses
only Flutter built-ins and is limited to short state transitions, progress, and
result feedback. It is disabled when the platform requests reduced motion.

## Future Branding Work

- Replace the template launcher icon with an original StudyHub mark.
- Commission a small project-owned illustration family for onboarding and empty
  states only after brand direction is approved.
- Implement real Google authentication only with a reviewed backend OAuth
  contract; keep Facebook hidden until a real product requirement exists.
- Validate contrast and interaction behavior on physical low-end Android devices.

## Render Verification

The refreshed profile-mode web build was inspected at 390 x 844 and 1280 x 800.
Authentication, registration, Home, top-level navigation, and Subject browsing
rendered without clipping or horizontal overflow. The mobile Home preserved one
clear CTA, readable two-column shortcuts, and reachable bottom navigation; the
desktop view kept the same mobile hierarchy inside a 560 px content boundary.
Automated compact-viewport coverage also checks 360 x 640 with 1.5 text scale.
