# 🔐 Two-Factor Authentication (2FA) Implementation Guide

## Overview

This document describes the complete implementation of the Login and Two-Factor Authentication (2FA) flow in the Surabhi application, following Clean Architecture principles with BLoC state management.

## 🎯 Authentication Flow

### Three-Stage Process

```
1. Login → 2. 2FA Choice → 3. OTP Verification → Dashboard
```

#### Stage 1: Login
- **Endpoint**: `POST /auth/login`
- **Request**: `{"email": "string", "password": "string"}`
- **Response**: `{"tokenType": "string", "accessToken": "string", "expiresIn": 0, "refreshToken": "string", "user": {...}}`
- **Action**: Tokens are immediately persisted to secure storage

#### Stage 2: 2FA Choice
- **Endpoint**: `POST /manage/2fa`
- **Request**: `{"method": "email" | "phone"}`
- **Response**: `{"message": "string", "method": "string"}`
- **Action**: OTP is sent to user's chosen method

#### Stage 3: OTP Verification
- **Endpoint**: `POST /auth/verify-2fa`
- **Request**: `{"otp": "string", "method": "string"}`
- **Response**: `{"message": "string", "verified": boolean}`
- **Action**: User is authenticated and redirected to dashboard

## 🏗️ Architecture

### Data Layer

#### Models
- **`AuthResponseModel`**: Login response with tokens and user data
- **`TwoFARequestModel`**: 2FA method selection request
- **`TwoFAResponseModel`**: 2FA request response
- **`VerifyOTPRequestModel`**: OTP verification request
- **`VerifyOTPResponseModel`**: OTP verification response

#### Data Sources

**Abstract Interface**: `AuthRemoteDataSource`
```dart
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginParams params);
  Future<void> logout();
  Future<TwoFAResponseModel> request2FA(String method);
  Future<VerifyOTPResponseModel> verifyOTP(String otp, String method);
}
```

**Real Implementation**: `AuthRemoteDataSourceImpl`
- Uses Dio HTTP client via `ApiClient`
- Makes actual API calls to backend
- Handles errors with comprehensive error messages

**Mock Implementation**: `AuthRemoteDataSourceMock`
- Simulates API responses with realistic delays (800ms)
- Provides test users with different roles and 2FA settings
- Fixed OTP: `123456` for testing
- No backend dependency required

#### Repository
**`AuthRepositoryImpl`** implements `AuthRepository`:
- Coordinates between data sources and domain layer
- Manages token persistence via `PreferencesService`
- Converts exceptions to domain failures

### Domain Layer

#### Use Cases
1. **`LoginUseCase`**: Handles user login
2. **`Request2FAUseCase`**: Requests OTP via chosen method
3. **`VerifyOTPUseCase`**: Verifies OTP and completes authentication

#### Repository Interface
```dart
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(LoginParams params);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, UserEntity>> checkAuthStatus();
  Future<Either<Failure, String>> request2FA(String method);
  Future<Either<Failure, bool>> verifyOTP(String otp, String method);
}
```

### Presentation Layer

#### BLoC States
- **`AuthInitial`**: Initial state
- **`AuthLoading`**: Loading during login/logout
- **`AuthAuthenticated`**: User fully authenticated
- **`AuthUnauthenticated`**: User not authenticated
- **`Auth2FARequired`**: User logged in but needs 2FA
- **`Auth2FALoading`**: Loading during 2FA operations
- **`Auth2FAOTPSent`**: OTP successfully sent
- **`Auth2FAError`**: Error during 2FA process

#### BLoC Events
- **`AppStarted`**: Check auth status on app start
- **`LoginRequested`**: User submits login credentials
- **`LogoutRequested`**: User logs out
- **`TwoFAMethodSelected`**: User selects 2FA method (email/phone)
- **`OTPVerificationRequested`**: User submits OTP for verification

#### UI Pages
1. **`LoginPage`**: Email/password login form
2. **`TwoFAChoicePage`**: Select OTP delivery method
3. **`TwoFAVerifyPage`**: Enter and verify OTP

## 🔧 Mock Toggle Configuration

### Switching Between Mock and Real API

In `lib/injector.dart`:

```dart
// 🔧 MOCK TOGGLE: Set to true to use mock data, false to use real API
const bool kMockAuth = true;
```

**When `kMockAuth = true`:**
- Uses `AuthRemoteDataSourceMock`
- No backend required
- Instant development and testing
- Console output: `🔧 Using MOCK Auth Data Source`

**When `kMockAuth = false`:**
- Uses `AuthRemoteDataSourceImpl`
- Requires backend API
- Real network calls
- Console output: `🌐 Using REAL Auth Data Source`

## 🧪 Testing with Mock Data

### Test Users

| Email | Password | Role | 2FA Enabled |
|-------|----------|------|-------------|
| admin@gmail.com | admin123 | admin | ✅ Yes |
| employee@gmail.com | employee123 | employee | ❌ No |
| preacher@gmail.com | preacher123 | preacher | ✅ Yes |

### Test OTP
**Fixed OTP for all mock tests**: `123456`

### Testing Flow

1. **Login with 2FA enabled user** (e.g., admin@gmail.com)
   - Enter credentials
   - Redirected to 2FA choice page

2. **Select 2FA method**
   - Choose Email or Phone
   - Click "Send OTP"
   - See success message

3. **Verify OTP**
   - Enter `123456`
   - Click "Verify OTP"
   - Redirected to role-specific dashboard

4. **Login with 2FA disabled user** (e.g., employee@gmail.com)
   - Enter credentials
   - Directly redirected to dashboard (no 2FA)

## 🛣️ Router Configuration

The `AppRouter` handles navigation based on auth states:

```dart
// 2FA flow redirects
if (is2FARequired && !isOn2FAPath) {
  return '/2fa/choice';
}

if (is2FAInProgress && !isOn2FAPath) {
  return '/2fa/choice';
}

// Authenticated users redirected to dashboard
if (isAuthenticated && (isGoingToPublicPath || isOn2FAPath)) {
  return _getDashboardPathForRole(loggedInRole);
}
```

## 📱 User Experience

### Visual Feedback
- ✅ Loading indicators during API calls
- ✅ Success messages with green color
- ❌ Error messages with red color
- ℹ️ Info boxes for testing hints
- 🔒 Security icons for 2FA pages

### Error Handling
- Network errors shown with user-friendly messages
- Invalid OTP shows specific error
- Expired sessions redirect to login
- Cancel buttons allow users to abort flow

## 🔒 Security Features

1. **Token Management**
   - Access tokens stored in secure storage
   - Refresh tokens for session management
   - Automatic token refresh on 401 errors

2. **2FA Protection**
   - OTP required for sensitive accounts
   - OTP expires after use
   - Method verification (email/phone match)

3. **Route Protection**
   - Unauthenticated users redirected to home
   - 2FA-required users can't bypass verification
   - Authenticated users can't access auth pages

## 🚀 Next Steps: Admin Devotee Management

After completing 2FA, implement Admin Devotee Management:

1. **CRUD Operations**
   - Create new devotees
   - View devotee list with pagination
   - Edit devotee details
   - Delete devotees

2. **Role-Based Access**
   - Check `AuthBloc` state for user role
   - Only admins can access devotee management
   - Show/hide UI elements based on role

3. **Implementation Pattern**
   - Follow same Clean Architecture
   - Use BLoC for state management
   - Implement mock data source for testing
   - Add to dependency injection

## 📚 Key Files

### Data Layer
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/data/datasources/auth_remote_datasource_mock.dart`
- `lib/features/auth/data/models/twofa_request_model.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`

### Domain Layer
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/domain/usecases/request_2fa_usecase.dart`
- `lib/features/auth/domain/usecases/verify_otp_usecase.dart`

### Presentation Layer
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/auth/presentation/bloc/auth_event.dart`
- `lib/features/auth/presentation/bloc/auth_state.dart`
- `lib/features/auth/presentation/pages/twofa_choice_page.dart`
- `lib/features/auth/presentation/pages/twofa_verify_page.dart`

### Configuration
- `lib/injector.dart` - Dependency injection with mock toggle
- `lib/routes/app_router.dart` - Navigation and route protection
- `lib/core/constants/api_constants.dart` - API endpoints

## 🎓 Learning Resources

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [GoRouter](https://pub.dev/packages/go_router)

