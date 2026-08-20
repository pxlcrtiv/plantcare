# PlantCare App Testing Guide - macOS (Apple Silicon M1)

## Prerequisites

### 1. Install Flutter SDK
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Flutter using Homebrew
brew install flutter

# Or download and install manually:
# 1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/macos
# 2. Extract to desired location (e.g., ~/development/flutter)
# 3. Add to PATH in ~/.zshrc or ~/.bash_profile:
#    export PATH="$PATH:[PATH_TO_FLUTTER_SDK]/bin"
```

### 2. Install Xcode and Command Line Tools
```bash
# Install Xcode from App Store
# Or download from Apple Developer website

# Install command line tools
sudo xcode-select --install

# Accept license
sudo xcodebuild -license
```

### 3. Install iOS Simulator
```bash
# Open Xcode and install iOS Simulator:
# Xcode > Preferences > Platforms > iOS
# Download and install the iOS simulator runtime you want to test with
```

### 4. Verify Flutter Setup
```bash
flutter doctor
# All checks should pass, especially:
# [✓] Flutter (Channel stable, etc.)
# [✓] Xcode - develop for iOS and macOS
# [✓] iOS tools - develop for iOS
# [✓] iOS Simulator
```

## Project Setup

### 1. Clone and Navigate to Project
```bash
cd /path/to/plantcare
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Set Up Firebase
```bash
# 1. Create a Firebase project at https://console.firebase.google.com/
# 2. Add an iOS app to your Firebase project
# 3. Download the GoogleService-Info.plist file
# 4. Place it in the ios/Runner/ directory
```

### 4. Set Up PlantNet API Key
```bash
# 1. Get a PlantNet API key from https://my.plantnet.org/
# 2. Update the API key in lib/presentation/plant_identification_camera/plant_identification_camera.dart
# Find the _getPlantNetApiKey() method and replace the placeholder with your actual key
```

## Running the App

### 1. Check Available Devices
```bash
flutter devices
# Should show iOS Simulator devices
```

### 2. Run the App
```bash
# Option 1: Select device interactively
flutter run

# Option 2: Specify a device
flutter run -d "iPhone 14 Pro"  # or whatever simulator you have

# Option 3: Build and run debug version
flutter run --debug
```

### 3. For Apple Silicon (M1) Specific Issues
```bash
# If you encounter build issues related to CocoaPods:
cd ios
pod deintegrate
pod setup
pod install
cd ..

# Then run again:
flutter run
```

## Testing End-to-End Functionality

### 1. User Authentication
- [ ] Test sign up/login functionality
- [ ] Verify user data is stored correctly in Firebase
- [ ] Test Google Sign-In if implemented

### 2. Plant Identification
- [ ] Test camera functionality
- [ ] Take photo of a plant or use sample image
- [ ] Verify PlantNet API integration (should identify plant species)
- [ ] Check if results are displayed correctly
- [ ] Test gallery selection option

### 3. Plant Management
- [ ] Add a new plant (should save to Firestore)
- [ ] Verify plant appears in plant dashboard
- [ ] Test editing plant details
- [ ] Test deleting a plant (should remove from Firestore)

### 4. Care Tracking
- [ ] Water a plant (should update status and next watering date)
- [ ] Verify care history is logged properly
- [ ] Test adding care notes
- [ ] Test adding photos to plant profile
- [ ] Check if notifications are scheduled properly

### 5. Data Synchronization
- [ ] Verify real-time data updates from Firestore
- [ ] Test offline functionality (disable network and verify app behavior)
- [ ] Re-enable network and confirm synchronization

### 6. UI/UX Testing
- [ ] Test all screens for proper layout on iOS devices
- [ ] Verify responsive design works on different screen sizes
- [ ] Test navigation between screens
- [ ] Check all buttons and interactive elements work properly

### 7. Notifications
- [ ] Set up care reminders
- [ ] Verify notifications appear at scheduled times
- [ ] Test notification dismissal and interaction

## Troubleshooting for Apple Silicon M1

### Common Issues:

1. **CocoaPods Architecture Issues:**
```bash
# If getting architecture errors, try:
sudo arch -x86_64 gem install ffi
cd ios
arch -x86_64 pod install
```

2. **Rosetta Compatibility:**
```bash
# Run Flutter tools with Rosetta if needed:
softwareupdate --install-rosetta
arch -x86_64 flutter run
```

3. **Firebase Plugin Issues:**
```bash
# Clean and rebuild:
flutter clean
flutter pub get
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter run
```

4. **Simulator Performance:**
On M1 Macs, iOS simulator should perform well, but if you experience slowness:
- Reduce simulator graphics quality in settings
- Close other memory-intensive applications
- Use smaller iOS device simulators for testing

## Testing Checklist

### Core Functionality:
- [ ] App launches without errors
- [ ] Navigation between screens works
- [ ] All UI elements are responsive
- [ ] Data persists correctly in Firebase
- [ ] Plant identification works with PlantNet API
- [ ] Care scheduling and notifications work
- [ ] Photo capture and display works
- [ ] Offline mode functions properly

### Performance:
- [ ] App loads reasonably fast
- [ ] Transitions between screens are smooth
- [ ] No memory leaks or crashes during extended use
- [ ] Background processes work as expected

### Compatibility:
- [ ] App runs on iOS simulators
- [ ] App runs on different iOS versions (14.0+)
- [ ] App layout adapts to different screen sizes
- [ ] All features work as expected on M1 architecture

## Building for Release

```bash
# Build iOS app
flutter build ios --release

# Or build for simulator
flutter build ios --simulator --release
```

## Additional Notes for M1 Macs

- Flutter performance is significantly better on M1 Macs compared to Intel Macs
- iOS Simulator runs natively and efficiently on M1 Macs
- Some third-party plugins might require additional configuration for ARM64 architecture
- When building for real devices, ensure all dependencies support ARM64 architecture