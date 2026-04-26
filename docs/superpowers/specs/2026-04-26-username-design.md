# Username Feature Design

**Date:** 2026-04-26  
**Status:** Approved

## Problem

Users appear in chat with a long OAuth authorization code as their name because `ExchangeCodeForUserInfoAsync` is a stub that stores the raw OAuth code as the email. Independently of that bug, the app needs a proper user-chosen identifier shown in chat and other social surfaces.

## Requirements

- Every user has a unique username chosen by them.
- Username is asked once when a new account is created (after OAuth).
- Username can be changed later from a profile screen.
- Chat displays the username instead of any email-derived string.

## Username Format

- 3–20 characters.
- Only letters (`a-z`, `A-Z`), digits (`0-9`), and underscores (`_`).
- Must start with a letter.
- Regex: `^[a-zA-Z][a-zA-Z0-9_]{2,19}$`
- Uniqueness is case-insensitive (stored as entered, compared in lowercase).

---

## Backend

### Data model

Add `Username` (nullable `string`) to the `User` entity.  
EF Core: unique index on the expression `Username.ToLower()` (PostgreSQL functional index) so uniqueness is case-insensitive.  
Migration required. Existing rows have `Username = null`.

### JWT changes

`GenerateJwt` adds a `username` claim.  
New users get `username = ""` in their first JWT.  
After setting or updating a username, the relevant endpoint returns a **new JWT** with the real value, which the client replaces in secure storage.  
This ensures app restarts always read the current username from the stored token without extra API calls.

### Endpoints

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| `POST` | `/users/me/username` | Required (empty-username JWT accepted) | Set username for the first time. Returns new JWT. |
| `PUT` | `/users/me/username` | Required | Change username. Returns new JWT. |
| `GET` | `/users/username-available` | None | Check availability. Query param `username`. Returns `{"available": bool}`. |

**`POST /users/me/username` and `PUT /users/me/username`** share the same validation:
1. Validate format against regex.
2. Check uniqueness (case-insensitive) in DB — reject with 409 if taken.
3. Save `user.Username = request.Username`.
4. Call `GenerateJwt(user)` and return `{ token, expiresIn }`.

### Chat

`ChatMessageDto` replaces `SenderEmail` with `SenderUsername` (`string`).  
`EventHub.SendMessage` uses `user.Username` when building the DTO.  
`GetChatMessagesQuery` includes `m.Sender.Username` in the projection.

---

## Flutter

### AuthBloc state

`AuthAuthenticated` gains a `username` field (`String`, empty string until set).  
`AuthCallbackPage` extracts the `username` claim from the decoded JWT alongside the existing `sub` and `email` claims.

### Router guard

In `app.dart`, `GoRouter.redirect` checks: if `AuthAuthenticated.username.isEmpty` and the target route is not `/username-setup`, redirect to `/username-setup`. This fires automatically for every new user after their first OAuth login.

### UsernameSetupPage (`/username-setup`)

- Single text field for username input.
- Client-side format validation on every keystroke.
- 400 ms debounce → `GET /users/username-available?username=xxx` → inline "disponible" / "no disponible" feedback.
- CONFIRMAR button (disabled while unavailable or format invalid) → `POST /users/me/username` → store new JWT → dispatch updated `AuthAuthenticated` to `AuthBloc` → `context.go('/home')`.

### ProfilePage (`/home/profile`)

- Displays current username.
- Editable field with same availability check as setup.
- GUARDAR button → `PUT /users/me/username` → store new JWT → update `AuthBloc` state.

### Chat

`ChatMessageModel` replaces `senderEmail: String` with `senderUsername: String`.  
`fromJson` maps `json['senderUsername']`.  
The `senderHandle` computed property is removed.  
Chat bubbles display `message.senderUsername` directly.

---

## Data flow: new user

```
OAuth login
  → AuthCallbackPage decodes JWT (username = "")
  → AuthBloc emits AuthAuthenticated(username: "")
  → Router redirects to /username-setup
  → User types username, checks availability, confirms
  → POST /users/me/username → new JWT (username = "alice_d")
  → AuthBloc emits AuthAuthenticated(username: "alice_d")
  → Router navigates to /home
```

## Data flow: send chat message

```
User sends message
  → ChatBloc → SignalRService.sendMessage(eventId, content)
  → EventHub.SendMessage → loads user.Username from DB
  → Saves ChatMessage, broadcasts ChatMessageDto(senderUsername: "alice_d")
  → SignalRService ReceiveMessage → ChatMessageModel.fromJson
  → ChatBloc._onReceived → ChatLoaded with new message
  → Chat bubble shows "alice_d"
```

---

## Error handling

- **Username taken (409):** show inline "este nombre ya está en uso" under the field.
- **Format invalid:** client-side, shown before any API call.
- **Network error on availability check:** hide the availability indicator, still allow submission (server validates anyway).
- **Network error on submit:** show error message, keep the form open.
