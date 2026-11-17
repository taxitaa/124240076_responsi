# ShoppingHub

Flutter shopping app backed by the DummyJSON Products API.
GetX provides reactive state management and named navigation.

## Features

- Local SQLite login with SHA-256 password hashes and account creation.
- Product catalog with search and category filtering.
- Product details loaded by API product ID.
- Per-user wishlist persisted in SQLite.
- Loading, retry, and error states for API requests.

## Demo account

- Username: `demo`
- Password: `123456`

You can also create another local account from the login screen.

## Run

```shell
flutter pub get
flutter run
```

The app needs an internet connection to load product and category data.
