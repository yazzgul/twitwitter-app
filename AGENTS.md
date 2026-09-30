# AGENTS.md

Инструкции для ИИ-агентов (Claude Code, Codex, Cursor, Copilot и др.), работающих с этим репозиторием.
Описание для людей, скриншоты и запуск — в `README.md`.

## Что это за проект

**TwiTwitter** — iOS-приложение (SwiftUI + Firebase): регистрация/вход, лента постов с фото и подписью, профиль пользователя со списком его постов, переключение языка (ru/en) без перезапуска.

- Язык интерфейса и комментариев в коде: **русский**. Комментарии пиши по-русски, в стиле существующих.
- Тестов и линтера в проекте **нет**.

## Стек

- Swift, SwiftUI, Xcode 26.x, iOS 26.x (deployment target в `.pbxproj` — 26.1)
- Firebase iOS SDK 12.19.2 через Swift Package Manager: `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`, `FirebaseCore`
- Combine (`ObservableObject` / `@Published`), **не** `@Observable`
- В проекте включено `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` и `SWIFT_APPROACHABLE_CONCURRENCY = YES`, `SWIFT_VERSION = 5.0` (language mode 5). Всё по умолчанию изолировано на MainActor.
- Сторонних библиотек кроме Firebase нет. Новые зависимости без согласования не добавляй.

## Структура

Исходники: `TwiTwitter/TwiTwitter/`

```
TwiTwitterApp.swift      Точка входа, AppDelegate (FirebaseApp.configure), создаёт AuthViewModel и LocalizationManager
RootView.swift           Если authVM.userSession != nil → MainTabView, иначе SignInView
Models/                  AppUser, Post, AuthField, AppLanguage
Screens/
  Authorization/         SignInView, SignUpView, AuthViewModel
  Feed/                  FeedView
  Posts/                 NewPostView, PostsViewModel (чтение), PostComposerViewModel (создание)
  UserProfile/           UserProfileView, UserProfileViewModel
Services/                AuthService, UserService, PostService, StorageService (протокол + реализация)
Validation/              AuthValidator, PostValidator (чистые функции, без зависимостей от UI)
Exeptions/               AuthValidationError, PostValidationError (папка названа с опечаткой — не переименовывай без запроса)
Localization/            LocalizationManager + en.lproj / ru.lproj / Localizable.strings
ViewComponents/          PostCard, ValidatedField, PostImageLabel, LanguageSettingsView, MainTabView, стили (CardStyle, FieldStyle)
```

## Архитектура

MVVM + слой сервисов.

```
View → ViewModel → Service (протокол) → Firebase
```

- **View** только отображает состояние и вызывает методы ViewModel. Бизнес-логики во View нет.
- **ViewModel**: `@MainActor final class ... : ObservableObject`. Сервисы приходят через init как протоколы с дефолтом `nil` → реальная реализация (`self.x = x ?? RealService()`). Этот паттерн сохраняй — он нужен для подмены сервисов в тестах.
- **Service**: у каждого есть `protocol XServiceProtocol` и `final class XService`. Только сервисы обращаются к Firebase напрямую (в ViewModel и View `import FirebaseFirestore` для запросов не нужен; исключения — `Post.swift` для `@DocumentID` и `AuthViewModel` для `AuthErrorCode`).
- **Валидация** — статические функции в `enum` (`AuthValidator`, `PostValidator`), бросают `AuthValidationError` / `PostValidationError`. Ошибка знает свою локализационную строку (`localizationKey`), а у `AuthValidationError` ещё и поле формы (`field`).
- **Общее состояние**: `AuthViewModel` создаётся один раз в `TwiTwitterApp` и раздаётся через `.environmentObject`. Остальные ViewModel создаются в View через `@StateObject`.

### Ключевые потоки

- **Регистрация**: `AuthValidator.validateSignUp` → `AuthService.createUser` → `UserService.createUser` (документ `users/{uid}`) → `userSession` и `currentUser`.
- **Вход**: `validateSignIn` → `AuthService.signIn` → `loadCurrentUser()` читает `users/{uid}`.
- **Лента**: `PostsViewModel.fetchFeed()` вешает snapshot-listener на `posts` (сортировка `createdAt desc`); `FeedView` включает его в `onAppear` и снимает в `onDisappear`.
- **Публикация**: `PostComposerViewModel.publish` → `PostValidator.validate` → (если есть фото) `StorageService.uploadPostImage` → `PostService.createPost`.
- **Профиль**: `UserProfileView(userId:)`; `userId == nil` означает профиль текущего пользователя. Переход в чужой профиль идёт через `NavigationLink(value: post.authorId)` + `.navigationDestination(for: String.self)` в `FeedView`.

## Данные в Firestore

| Коллекция | Документ | Поля |
|---|---|---|
| `users` | `{uid}` | `id`, `username`, `email`, `avatarURL?`, `createdAt` |
| `posts` | автоID | `authorId`, `authorUsername`, `authorAvatarURL?`, `caption`, `imageURL?`, `createdAt` |

- В `Post` автор денормализован (username и avatar копируются в пост). Если добавляешь редактирование профиля — учти, что старые посты не обновятся сами.
- Запрос `fetchUserPosts` (`authorId ==` + `order by createdAt`) требует **составной индекс** в Firestore. Без него запрос упадёт, а ошибка будет молча проглочена (`try?`) и профиль покажет 0 постов.
- Firebase Storage: `post_images/{UUID}.jpg`. Сейчас загрузка фото **временно недоступна** — не считай падение `uploadPostImage` багом в коде.

## Локализация

- Языки: `ru` (по умолчанию) и `en`. Файлы: `Localization/{ru,en}.lproj/Localizable.strings`.
- Весь пользовательский текст берётся через `loc.localized("key")` (`LocalizationManager`), **не** через `Text("литерал")` и не через `NSLocalizedString` напрямую — иначе язык не переключится на лету.
- Добавляя строку, добавляй ключ **в оба** `.strings`-файла.
- Ключи в `snake_case`, ошибки — с префиксом `error_`.
- View, использующие `loc`, должны получать `@EnvironmentObject var loc: LocalizationManager`, чтобы перерисовываться при смене языка.

## Правила кода

- Отступ 4 пробела, стиль как в существующих файлах (Xcode-форматирование).
- Каждое View — в отдельном файле; переиспользуемые компоненты — в `ViewComponents/`.
- Стили через модификаторы: `.authFieldStyle()`, `.postCardStyle()`. Акцентный цвет — `.purple`, градиент `.purple → .blue`.
- Ошибки пользователю показывай через локализованные строки: для форм — `authVM.fieldErrors[AuthField]`, для публикации — `errorMessage`.
- Новый файл нужно добавить в Xcode-проект (`TwiTwitter.xcodeproj/project.pbxproj`). Если проект использует синхронизированные папки — достаточно положить файл в директорию; проверь это перед ручной правкой `.pbxproj`. Ручных правок `.pbxproj` избегай.
- Не используй `@Observable`, `ObservableObject` не заменяй без запроса.

## Сборка и проверка

Открыть: `open TwiTwitter/TwiTwitter.xcodeproj` (Xcode, ⌘R).

Сборка из терминала (macOS):

```bash
xcodebuild -project TwiTwitter/TwiTwitter.xcodeproj -scheme TwiTwitter \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Название симулятора подставь из `xcrun simctl list devices available`.

Для запуска нужен `GoogleService-Info.plist` (он в `.gitignore`). Без него приложение упадёт на `FirebaseApp.configure()`.

## Чего не делать

- Не коммить `GoogleService-Info.plist` и `Secrets.plist`, не выводи их содержимое и не вставляй ключи в код.
- Не обращайся к Firebase из View.
- Не хардкодь строки интерфейса.
- Не глотай ошибки через `try?` в новом коде без причины (сейчас так сделано в нескольких местах — это долг, а не образец).
