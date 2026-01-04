# Photo App
A Flutter application that allows users to update and browse photos of potholes and other signs of local urban decay. 

---

# Design Patterns

### 1. Singleton Design Pattern 
**Implementation:** Allows for LoggerService logs to have only one instance that can be used globally for all actions.
**Single Responsibility** Centralizes logging into one instance so other classes don't have to manage it.
**Location:** `data/services/logger_service.dart` 

### 2. Adapter Design Pattern
**Implementation:** Allows incompatible raw text to be wrapped with formatted hashtags that can be saved/used.
**Location:** `domain/patterns/hashtag_processor.dart` - `presentation/pages/gallery/photo_details_page.dart`

### 3. Decorator Design Pattern
**Implementation:** Adds new amber-color selection functionality to photo objects dynamically without changing their structure.
**Open/Closed** Open for UI extensions, but closed for modification of core image object
**Location:** `presentation/widgets/photo_component.dart` - `presentation/pages/gallery/gallery_page.dart` 

### 4. Strategy Design Pattern
**Implementation:** Defines a family of image filter strategies that are interchangeable when user selects filter type.
**Location:** `domain/patterns/image_strategy.dart` - `presentation/pages/gallery/photo_details_page.dart` 

### 5. Facade Design Pattern
**Implementation:** Provides a simplified interface to complex subsystem of editing options for photos.
**Location:** `lib/domain/patterns/photo_facade.dart` - `presentation/pages/gallery/photo_details_page.dart`

### 6. Command Design Pattern
**Implementation:** Encapsulates actions into separate objects, so you can execute them without directly calling a function.
**Location:** `domain/patterns/command_actions.dart` - `presentation/pages/profile/profile_page.dart`

### 7. Proxy Design Pattern
**Implementation:** Displays a loading placeholder, delegating rendering to real image only once it becomes available.
**Liskov Substitution**Placeholder objects can replacea image objects without without breaking the Gallery.
**Location:** `lib/data/datasources/image_proxy.dart` - `presentation/pages/gallery/gallery_page.dart`

### 8. Chain of Responsibility Design Pattern
**Implementation:** Passes requests related to uploading a post along a chain of handlers until one processes it.
**Location:** `domain/patterns/upload_validation_chain.dart` - `presentation/pages/upload/upload_page.dart`

---