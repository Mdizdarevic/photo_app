# Photo App
A Flutter application that allows users to update and browse photos of potholes and other signs of local urban decay. 

---

# Advanced Programming Paradigms (Learning Outcomes)

### Learning Outcome 1
**Describe programming testing concepts:**
**Implementation:** Unit testing (verifies individual parts of a program, like functions or classes, to ensure they work correctly on their own), integration testing (checks whether different components work together properly), functional testing (verifies whether the app features work as expected based on specific requirements), regression testing (ensures that new changes don't break existing functionality by re-running previous tests after updates). Test-Driven Development would've worked if I started this project from scratch, but this is my existing project from last semester.
**Location:** `test/test_suite.dart` 

### Learning Outcome 2, Learning Outcome 3
**Add unit, integration, UI tests:**
**Implementation:** Implemented 10 tests (3 unit tests, 1 integration, and 6 ui/widgets tests).
**Location:** `test/test_suite.dart` 

### Learning Outcome 4
**Describe testing and improving programming solution:**
**Implementation:** Unit tests verified individual classes and functions, integration tests checked communication between components, and widget tests verified the user interface behavior. Possible solutions to decrease time and allocate memory for testing could be: reuse the same provider setup instead of rebuilding it for every test, run unit tests at the same time (parallel) instead of waiting for each one, stop recreating the same mock data over and over again, and break down big widgets (i.e. consumption tracker) into smaller pieces so they don't take too long to load. 
**Location:** `test/test_suite.dart` 

### Learning Outcome 6
**Add aspects using aspect-oriented programming:**
**Implementation:** AuditAspect was implemented to handle logging and auditing across multiple advices/actions (authentication, user management, and package management service). PerformanceAspect tracks execution time and metrics for database and image actions.
**Location:** `lib/di.dart` - `data/services/metrics_service.dart` - `data/services/logger_service.dart`

### Learning Outcome 7
**Demonstrate version control workflow you use when implementing features or refactoring:**
**Implementation:** My project has 6 branches (main + 5 features). Each feature and/or learning outcome has its own branch before being merged into the main branch. I didn't implement a development branch for feature branches to branch into because it was just me working, not a team, so no worries about merge conflicts.
**Location:** `git branch in terminal` 

### Learning Outcome 8
**Apply refactoring best practices to improve your existing code:**
**Implementation:** Implemented refactoring with 4 principles from SOLID: Single Responsibility Principle (parsing raw text strings from hashtags into clean arrays), Open/Closed Principle (package tiers are open for extension, but closed for modification), Liskov Substitution Principle (package strategy interface allows you to swap packages, while keeping same properties), Dependency Inversion Principle (proxy used as a middleman to automatically run background logging)
**Location:** `domain/patterns/hashtag_processor.dart` - `presentation/pages/profile/consumption_tracker.dart` - `domain/models/package_config.dart` - `data/services/logger_service.dart`

### Learning Outcome 9
**Add metrics and demonstrate how you can monitor your application health and performance:**
**Implementation:** Built a metrics system to monitor 5 metrics: Active Session Duration (how long app has been active), Average Auth Latency (login response time), Firestore Write Success (what percent of db requests worked), Image Processing Speed (how long it took to process images of diff sizes), Tier Package Breaches (how many times restricted users hit their subscription limits).
**Location:** `data/services/metrics_service.dart`  

### Learning Outcome 5
**Reduce coupling in code by using functional programming paradigm:**
**Implementation:** Implemented .map() and .where() operators to handle converting raw Firebase documents into UserEntity objects, parsing hashtag strings of any extra symbols or spaces, and replacing a switch case that matches data based on what tier is selected
**Location:** `presentation/pages/admin/admin_dashboard.dart` - `presentation/pages/upload/upload_page.dart` - `presentation/pages/auth/login_page.dart` 

### Learning Outcome 8
**Demonstrate how to package and run your app as a container:**
**Implementation:** Packaged as a container, built a docker image that runs on localhost:8080
**Location:** `docker build -t photo-admin-app .` - `docker run -d -p 8080:80 --name photo_app_container photo-admin-app` 

---