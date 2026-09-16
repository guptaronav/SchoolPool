# SchoolPool Web

A functional web port of the core SchoolPool flows — sign in, onboarding, and browsing/creating rides — built with React, TypeScript, and Vite, talking directly to the same Firebase project (Auth + Firestore) as the iOS app.

Deployed automatically to GitHub Pages on every push to `main` that touches this directory (see `.github/workflows/deploy-web.yml`).

## What's ported

- Auth: email/password, Google, and a guest demo mode (Firebase Anonymous Auth)
- Onboarding: role selection, school search (read-only — schools are admin-managed), student ID verification submission
- Rides: browse your school's ride feed, post a ride, view details, request a seat

Not ported: chat, ratings, admin review console, profile/settings editing, push notifications, and gamification displays beyond what's on the user doc. These mirror real backend constraints (e.g. schools can't be self-created; verification review is manual) rather than being trimmed for convenience.

## Local development

```bash
npm install
npm run dev
```

## Build

```bash
npm run build
```
