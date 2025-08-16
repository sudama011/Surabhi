## Project Documentation
#### 1. Architecture: Feature-First Clean Architecture
The project is structured using a **feature-first** approach combined with principles of **Clean Architecture**. This design separates the application into distinct layers while keeping all files related to a specific feature within a single, dedicated folder. This structure promotes:

- **Modularity:** Each feature is a self-contained unit.

- **Scalability:** New features can be added without affecting existing ones.

- **Testability:** Each layer can be tested in isolation.

The main layers are:

- **core/:** Contains app-wide logic and shared components.

- **features/:** Houses all feature-specific code, with each feature having its own `data/`, `domain/`, and `presentation/` sub-folders.

#### 2. Core Components
The core folder is the foundation of the application, containing shared functionality and dependencies.

##### Network Layer
- **api_client.dart:** The primary HTTP client using the Dio package. It is configured as a singleton to ensure a single, consistent instance for all API calls. It handles base URL configuration, timeouts, and standard headers.

- **api_interceptor.dart:** A custom interceptor that integrates with `ApiClient`. Its primary responsibilities are:

	- **Automated Authentication:** It intercepts every request and adds the access token to the headers.

	- **Token Refreshing:** It automatically handles 401 Unauthorized errors by attempting to refresh the access token using the refresh token before re-attempting the original request.

	- **Error Handling:** Converts HTTP status codes (401, 403) and network errors into specific, custom exceptions (AuthException, PermissionDeniedException).

##### Local Storage
- **preferences_service.dart:** A service that abstracts local data persistence. It correctly separates data based on sensitivity.

	- **FlutterSecureStorage:** Used for sensitive data like access and refresh tokens. It leverages platform-specific encryption to ensure data security.

	- **SharedPreferences:** Used for non-sensitive data such as user role, user JSON, and theme preferences.

##### Dependency Injection
- **injector.dart:** The main dependency management file using the get_it package. All core services, repositories, and BLoCs are registered here as either lazy singletons or factories. This approach ensures that dependencies are loosely coupled and that all components are easily testable and replaceable.

#### 3. Feature Structure
Each feature (e.g., `auth/`) adheres to the same layered structure:

- `data/`: Handles data retrieval and storage.

	- datasources/: Contains AuthRemoteDataSource for fetching data from the API and AuthLocalDataSource (if needed) for local persistence.

	- repositories/: The implementation of the repository interface. It orchestrates data flow by calling data sources and converting low-level exceptions into high-level failures.

- `domain/`: The business logic layer, completely independent of any framework.

	- entities/: Defines the business objects (e.g., UserEntity).

	- repositories/: Defines the abstract repository interfaces, which act as a contract for the data layer.

	- usecases/: Encapsulates specific business logic (e.g., LoginUseCase).

- `presentation/`: The user-facing layer.

	- bloc/: Contains the business logic components (e.g., AuthBloc) that manage the state for the UI.

	- pages/: The UI widgets and screens.

This project's architecture promotes a clear separation of concerns, making the codebase maintainable, scalable, and easy to navigate for any developer.