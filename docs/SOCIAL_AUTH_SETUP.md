# Social Authentication Setup

StudyHub currently uses backend-owned email/password authentication. Google
sign-in is intentionally disabled until provider configuration and backend token
verification are complete. Facebook remains hidden.

## Google manual setup

1. Create OAuth clients in the project's Google Cloud console. Configure the
   Android package name and release/debug signing SHA fingerprints, and create a
   Web client for allowed browser origins where Flutter Web is supported.
2. Keep provider client secrets out of Flutter, Git, and public build
   configuration. Client IDs are configuration; server credentials remain in a
   secret manager or local ignored environment file.
3. Add a protected backend exchange endpoint that accepts a Google ID token,
   verifies its signature, issuer, audience, expiry, and nonce with Google's
   supported server library, then creates or reuses a StudyHub account.
4. Define account-linking behavior before launch. An existing StudyHub email
   must never be silently linked to an unverified provider identity.
5. Add an `AuthRepository` provider method only after the backend contract is
   available. Handle cancellation, provider failure, account conflict, and
   expired StudyHub sessions explicitly.
6. Test Android debug/release signing, Flutter Web allowed origins, first login,
   repeat login, cancellation, revoked consent, and existing-account conflicts.

Do not implement a client-only successful login. The backend remains the source
of truth and issues the StudyHub session after provider identity verification.
