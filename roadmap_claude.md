# Magic Book App Development Roadmap

## Overview

This document outlines the development roadmap for "Magic Book," an interactive fairy tale application for children aged 0-12. The app will generate personalized fairy tales based on user input, complete with images and audio narration. Built with Flutter for cross-platform compatibility, the application will feature a modern interface with an authentic book-like reading experience.

## Project Specifications

- **App Name**: Magic Book
- **Target Audience**: Children 0-12 years old
- **Platforms**: iOS and Android (Flutter)
- **AI Integration**: 
  - Gemini 2.0 Flash for tale generation
  - DALL-E 3 for image creation
- **Core Features**:
  - Personalized fairy tale generation
  - User profile customization
  - Favorites system (max 5 tales)
  - Text-to-speech narration
  - Offline access to saved tales

## Phase 1: Project Setup and Architecture

### 1.1 Project Initialization
- Create a new Flutter project
- Set up the project structure following modular architecture
- Configure version control (Git)
- Set up development, staging, and production environments

### 1.2 Dependency Management
- Add essential packages:
  - `dio` or `http` for API communication
  - `hive` or `sqflite` for local storage
  - `provider` or `riverpod` for state management
  - `flutter_tts` for text-to-speech
  - `page_turn` for book page animation
  - `lottie` for animations
  - `cached_network_image` for image caching
  - `shared_preferences` for simple storage
  - `get_it` for dependency injection

### 1.3 Architectural Setup
- Implement Clean Architecture with:
  - Feature-first folder structure
  - Repository pattern for data access
  - Service layer for business logic
  - Presentation layer for UI components

## Phase 2: Core Services Implementation

### 2.1 API Services
- Create `GeminiApiService` for tale generation:
  - Implement authentication
  - Create tale generation methods with proper prompting
  - Add error handling and retries
- Create `DalleApiService` for image generation:
  - Implement authentication
  - Create image generation methods with context-aware prompting
  - Implement caching for generated images

### 2.2 Local Storage
- Implement user profile storage
- Create favorites storage system
- Implement offline content caching (text, images, audio)

### 2.3 Text-to-Speech Service
- Create audio service for tale narration
- Implement play, pause, and stop functionality
- Configure voice options and speech rate

## Phase 3: User Interface Development

### 3.1 App Theme and Design System
- Create a consistent color palette (child-friendly, modern)
- Design custom typography system (readable yet magical)
- Implement shared UI components (buttons, inputs, cards)
- Create day/night theme support

### 3.2 Onboarding Flow
- Design welcome screens
- Create user profile creation screens (name, gender, age, hair color, hair type, skin tone)

### 3.3 Settings Screen
- Implement user profile management
- Create tale generation preferences UI:
  - Word count selector (dropdown with 100, 200, 300, 400, 500 options + custom input)
  - Character, location, and theme inputs

### 3.4 Favorites Management
- Design favorites list with thumbnails
- Implement metadata display (character, location, theme, creation date/time)
- Create favorite management actions (view, delete)

### 3.5 Tale Book Interface
- Create antique book design with page-turning animation
- Implement split view (text on left page, image on right)
- Add audio control buttons (play, pause, stop)
- Create "Add to Favorites" functionality
- Implement page navigation controls

## Phase 4: Tale Generation Workflow

### 4.1 Tale Creation Process
- Implement user input collection and validation
- Create tale generation workflow:
  - User parameters processing
  - API request formation
  - Response handling
  - Content segmentation into pages (50 words max per page)

### 4.2 Image Generation Process
- Implement context-aware prompt creation:
  - Extract key elements from page text
  - Incorporate user character attributes
  - Generate scene description
- Create image processing and optimization

### 4.3 Audio Generation
- Implement text-to-speech conversion
- Create audio file management
- Implement audio playback controls

## Phase 5: Offline Capabilities

### 5.1 Favorites Caching
- Implement complete tale storage (text, images, audio)
- Create metadata indexing
- Implement efficient loading mechanism

### 5.2 State Persistence
- Save user preferences
- Implement session restoration

## Phase 6: Testing and Optimization

### 6.1 Unit Testing
- Test all service classes
- Validate data processing functions
- Test API integrations

### 6.2 Integration Testing
- Test end-to-end tale generation
- Verify offline capabilities
- Validate state management

### 6.3 Performance Optimization
- Optimize image loading and caching
- Enhance app startup time
- Reduce memory usage

### 6.4 Error Handling
- Implement comprehensive error management
- Create user-friendly error messages
- Add retry mechanisms for critical operations

## Phase 7: Finalization and Deployment

### 7.1 Final UI Polish
- Refine animations and transitions
- Ensure consistent styling
- Optimize for different screen sizes

### 7.2 Documentation
- Create internal code documentation
- Prepare user documentation
- Document API integration details

### 7.3 App Store Preparation
- Create app icons and splash screens
- Prepare screenshots and marketing materials
- Write app descriptions

### 7.4 Deployment
- Configure CI/CD pipeline
- Deploy to TestFlight and Google Play Beta
- Prepare for production release

## Technical Requirements Details

### Modular Structure
```
lib/
├── core/
│   ├── apis/
│   │   ├── gemini_api.dart
│   │   └── dalle_api.dart
│   ├── services/
│   │   ├── audio_service.dart
│   │   ├── storage_service.dart
│   │   └── logging_service.dart
│   └── utils/
│       ├── logger.dart
│       └── validators.dart
├── features/
│   ├── onboarding/
│   ├── user_profile/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   ├── tale_generation/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   ├── tale_viewer/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   └── favorites/
│       ├── models/
│       ├── repositories/
│       ├── screens/
│       ├── widgets/
│       └── services/
├── shared/
│   ├── models/
│   │   ├── user_profile.dart
│   │   ├── tale.dart
│   │   └── tale_page.dart
│   ├── widgets/
│   │   ├── book_page.dart
│   │   ├── audio_controls.dart
│   │   └── custom_inputs.dart
│   └── constants/
│       ├── theme.dart
│       ├── strings.dart
│       └── api_constants.dart
├── app.dart
└── main.dart
```

### Tale Generation Specifications
- Each tale should be generated based on:
  - User profile (name, gender, age, hair color, hair type, skin tone)
  - Tale parameters (character, location, theme)
  - Word count (100-500 words, or custom count)
- Text will be split into pages of maximum 50 words each
- Each page will have an accompanying image reflecting:
  - The content of that specific page
  - The user's character attributes
- Each tale must have audio narration synced with page content

### Favorites System
- Maximum 5 tales can be saved
- Each saved tale must store:
  - Complete text content
  - All generated images
  - Audio narration files
  - Metadata (creation date/time, parameters)
- Favorites must be accessible offline

### UI Requirements
- Modern, clean interface for settings and navigation
- Authentic antique book appearance for tale viewing:
  - Leather-bound look with texture
  - Parchment-like page appearance
  - Realistic page-turning animations
  - Split view layout (text left, image right)
- Audio controls at the bottom of the book interface
- Add to favorites button near audio controls

### API Integration
- Gemini 2.0 Flash for tale text generation
  - Proper prompting to ensure child-friendly content
  - Context management for coherent storytelling
- DALL-E 3 for image generation
  - Context-aware prompt engineering
  - Character consistency across images

## Key Milestones
1. Project setup and core architecture
2. API integration and service layer
3. Basic UI implementation
4. Tale generation workflow
5. Book interface and page navigation
6. Favorites system and offline capabilities
7. Testing and optimization
8. Final polish and deployment preparation

This roadmap provides a comprehensive guide to developing the Magic Book application with all required features. The modular approach will ensure code maintainability and allow for parallel development of different components.