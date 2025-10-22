# Instagram Clone (Flutter)

An Instagram-style Flutter application featuring feed, reels, chat, search, and profile experiences. Built with Flutter and local persistence using SharedPreferences, with dummy seed data and media assets.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [Assets](#assets)
- [Permissions](#permissions)
- [Architecture Notes](#architecture-notes)
- [Key Modules](#key-modules)
- [Development Tips](#development-tips)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
 - [Screenshots](#screenshots)
 - [Presentation Guide (PDF-Ready)](#presentation-guide-pdf-ready)
 - [FAQ](#faq)

## Overview
- **Entry point:** `lib/main.dart`
  - Initializes seed data via `DummyData.initializeData()` then launches `SplashScreen`.
- **Navigation:** A bottom navigation (`BottomNavBarScreen`) manages Home, Reels, Messenger, Search, and Profile tabs using a `PageController`.
- **Persistence:** `lib/services/data_persistence.dart` stores posts, stories, reels, comments, likes, saved items, reposts, and simple user stats with `SharedPreferences`.
- **Seed data:** `lib/data/dummy_data.dart` provides `users`, `posts`, `stories`, `reels`, chat threads, following maps, and helpers.

## Features
- **Home Feed** with posts, like/save, comments, and navigation to reels.
- **Reels** with initial index navigation, start position, shuffle toggle, friends-only filter, like/share/repost.
- **Messenger** with sample chat threads and seen/unseen states.
- **Search** grid (staggered layout) for explore content.
- **Profile** with tabs, preview, and edit-profile.
- **Create**: add post, story, and reels editors with media pickers.
- **Local persistence** of user-created/liked/saved content using `SharedPreferences`.

Quick file links (open to jump into code):

- `lib/views/Home/home_screen.dart` (feed with `PostWidget`, `ReelWidget`, `StoryAvatar`)
- `lib/widgets/post_widget.dart` (pinch-zoom, gradient heart like)
- `lib/views/reels_screen/reels_screen.dart` and `lib/widgets/reel_widget.dart` (video + gestures)
- `lib/views/search_screen/searchscreen.dart` (staggered grid explore)
- `lib/views/add_post_screen/add_post_screen.dart` (camera/gallery + editors)
- `lib/views/commentscreen/commentscreen.dart` (draggable sheet comments)
- `lib/views/profile_screen/profile_screen.dart` and `lib/views/profile_tab_screen/profile_tab_screen.dart`

## Tech Stack
- **Flutter**: Material 3 widgets and navigation.
- **Dart**: SDK `^3.8.1` (see `pubspec.yaml`).
- **Packages:**
  - UI/UX: `google_fonts`, `flutter_svg`, `flutter_staggered_grid_view`, `visibility_detector`
  - Media: `image_picker`, `camera`, `video_player`, `photo_manager`, `gal`
  - Utilities: `path_provider`, `permission_handler`, `shared_preferences`, `share_plus`, `qr_flutter`

Why these packages (high level):

- `video_player`: efficient video playback (reels) with precise control.
- `visibility_detector`: auto play/pause in-feed reels by visibility.
- `camera`/`image_picker`: capture and pick media for create flows.
- `shared_preferences`: lightweight local persistence for content and flags.
- `flutter_staggered_grid_view`: quilted explore layout.
- `flutter_svg`: crisp scalable icons.

## Packages and Installation

Listed from `pubspec.yaml`. Install individually or run the combined command.

- **Dependencies**
  - `cupertino_icons:^1.0.8`
  - `video_player:^2.10.0`
  - `flutter_staggered_grid_view:^0.7.0`
  - `image_picker:^1.2.0`
  - `photo_manager:^3.7.1`
  - `shared_preferences:^2.5.3`
  - `qr_flutter:^4.1.0`
  - `share_plus:^12.0.0`
  - `path_provider:^2.1.5`
  - `permission_handler:^12.0.1`
  - `gal:^2.3.2`
  - `visibility_detector:^0.4.0+2`
  - `google_fonts:^6.3.2`
  - `flutter_svg:^2.2.1`
  - `camera:^0.11.2`
  - `vector_math:^2.2.0`

```bash
# Add runtime dependencies
flutter pub add \
  cupertino_icons:^1.0.8 \
  video_player:^2.10.0 \
  flutter_staggered_grid_view:^0.7.0 \
  image_picker:^1.2.0 \
  photo_manager:^3.7.1 \
  shared_preferences:^2.5.3 \
  qr_flutter:^4.1.0 \
  share_plus:^12.0.0 \
  path_provider:^2.1.5 \
  permission_handler:^12.0.1 \
  gal:^2.3.2 \
  visibility_detector:^0.4.0+2 \
  google_fonts:^6.3.2 \
  flutter_svg:^2.2.1 \
  camera:^0.11.2 \
  vector_math:^2.2.0

# Add dev dependencies
flutter pub add --dev \
  flutter_launcher_icons:^0.14.4 \
  flutter_lints:^5.0.0

# Then fetch all packages
flutter pub get
```

Notes:
- `flutter_test` is included via the Flutter SDK and typically not added manually.

## Project Structure
```
lib/
  core/
    constants/
      app_colors.dart
      app_images.dart
  data/
    dummy_data.dart                # Seed users, posts, reels, stories, chats, follows, helpers
  models/                          # Data models: user, post, reel, story, saved item, comment
  services/
    data_persistence.dart          # Read/write to SharedPreferences
  views/
    Home/home_screen.dart          # Feed
    reels_screen/                  # Reels viewer + bottom sheet
    reels_editor_screen/           # Reels editor
    post_screen/                   # Post detail
    post_editor_screen/            # Post editor
    my_story_screen/               # Story creation
    add_post_screen/               # Add post entry
    commentscreen/                 # Comments UI
    messenger_screen/              # Tab messenger
    chatscreen/                    # Chat threads
    search_screen/                 # Explore/search grid
    profile_screen/                # Profile view(s)
    profile_tab_screen/            # Profile tab container
    edit_profile_screen/           # Edit-profile UI
    bottomnavbarscreens/           # `BottomNavBarScreen`
    splash/                        # SplashScreen
  widgets/                         # Reusable widgets (e.g., image loader)
  main.dart
assets/
  images/, videos/, fonts/, Icons/
```

## Getting Started
1. **Prerequisites**
   - Flutter SDK 3.22+ (Dart SDK `^3.8.1` compatible)
   - Xcode (iOS) and/or Android Studio/SDKs (Android)

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure launcher icons (optional)**
   Uses `flutter_launcher_icons`. Configure in `pubspec.yaml` under `flutter_icons`.
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Prepare assets**
   Ensure media files exist per `pubspec.yaml` under `flutter.assets` and fonts under `flutter.fonts`.

## Running the App
```bash
flutter run -d <device_id>
```
- On first launch, seed data is loaded by `DummyData.initializeData()`.
- User-created posts/stories/reels and likes/saves persist locally with `SharedPreferences`.

Useful commands:

```bash
flutter doctor
flutter pub get
flutter clean && flutter pub get   # if assets/packages change
```

## Assets
Declared in `pubspec.yaml`:
- `assets/images/splashscreen_images/`
- `assets/images/`
- `assets/videos/`
- `assets/fonts/`
- `assets/Icons/`

Custom font:
```yaml
fonts:
  - family: Billabong
    fonts:
      - asset: assets/fonts/Billabong.otf
```

## Permissions
The app uses camera, gallery, and storage access.

- **Android**: Add required permissions to `android/app/src/main/AndroidManifest.xml` as needed by `image_picker`, `camera`, `photo_manager`, and `permission_handler` (e.g., `CAMERA`, `READ_MEDIA_IMAGES`/`READ_EXTERNAL_STORAGE` based on API level, `WRITE_EXTERNAL_STORAGE` on older APIs).
- **iOS**: In `ios/Runner/Info.plist`, add usage descriptions:
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`
  - `NSPhotoLibraryAddUsageDescription`

Refer to each package README for the exact, version-specific entries.

## Architecture Notes
- **State management:** Screens primarily use `StatefulWidget` and local state. No global state library is introduced.
- **Persistence layer:** `DataPersistence` wraps `SharedPreferences` for:
  - Posts, Stories, Reels: save/load user items
  - Comments: map of `postId -> List<CommentModel>`
  - Saved items and Likes: stored as lists of serialized `SavedItem`
  - Reposts: `Map<String, List<String>>`
  - Simple user metrics: post count
- **Seed & hydration:** `DummyData.initializeData()` merges persisted user content on top of pre-seeded content and hydrates like/save flags.
- **Navigation:** `BottomNavBarScreen` uses `PageView` with `PageController` and custom tab refresh logic.

## Key Modules
- `lib/main.dart`: App bootstrap and `SplashScreen`.
- `lib/views/bottomnavbarscreens/bottomnavbarscreen.dart`: Bottom nav, tabs, and page transitions.
- `lib/services/data_persistence.dart`: Save/load for posts/stories/reels/comments/saved/likes/reposts/user stats.
- `lib/data/dummy_data.dart`: Seed data, chats, following map, helpers (e.g., `getPostById`, `getReelById`, like/save/repost helpers, comments load/save).
- `lib/views/reels_screen/reels_screen.dart`: Reels playback with initial index, start position, and friends-only toggle.

See also the full presentation guide for an element-by-element breakdown: `docs/Project_Presentation_Guide.html`.

## Development Tips
- Use the provided editors in `views/*editor*` to create local content and verify persistence.
- When switching tabs rapidly, `BottomNavBarScreen` manages refresh keys to reset Reels state; inspect `_reelsRefreshKey` and related fields for behavior changes.
- If you change models, update their `toJson/fromJson` to keep persistence compatible.

## Troubleshooting
- **Black screen on video:** Ensure all video assets exist under `assets/videos/` and are declared in `pubspec.yaml`.
- **Permissions denied:** Verify Android/iOS permission entries and grant at runtime via `permission_handler`.
- **Assets not loading:** Run `flutter clean && flutter pub get` after changing `pubspec.yaml` assets.
- **Launcher icons not updating:** Re-run `flutter pub run flutter_launcher_icons` and rebuild.

If anchors don’t navigate in your IDE preview, open the HTML in a browser:

```powershell
start "" "c:\Users\faysa\OneDrive\Documents\Flutter\instagram\docs\Project_Presentation_Guide.html"
```

## Contributing
- Fork, create a feature branch, and open a PR.
- Keep code style consistent with `analysis_options.yaml` and `flutter_lints`.
- Add/adjust assets and update `pubspec.yaml` when necessary.

## Screenshots

Place screenshots in `docs/screenshots/` and reference them here (examples):

![Home](docs/screenshots/home.png)
![Reels](docs/screenshots/reels.png)
![Search](docs/screenshots/search.png)
![Profile](docs/screenshots/profile.png)

## Presentation Guide (PDF-Ready)

Open the HTML and Save as PDF from your browser. Background graphics recommended.

- `docs/Project_Presentation_Guide.html`

## FAQ

- **Where is the per-screen, per-element description?**
  - In `docs/Project_Presentation_Guide.html` under “Per‑Screen and Per‑Element Deep Dive”.
- **How do I jump to the Reels screen at a specific item from feed?**
  - `ReelWidget` calls `onNavigateToReels(1, index, position)` handled by `BottomNavBarScreen`.
- **How are likes/saves persisted?**
  - Via `DummyData.likeItem/unlikeItem/saveItem/removeSavedItem` and `DataPersistence` → `SharedPreferences`.
