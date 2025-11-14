# PlantCare App Deployment and Testing Guide - Apple Silicon MacBook Air

## Prerequisites

### 1. Install Flutter SDK
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Flutter using Homebrew
brew install --cask flutter

# Or download and install manually:
# 1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/macos
# 2. Extract to desired location (e.g., ~/development/flutter)
# 3. Add to PATH in ~/.zshrc (for Apple Silicon):
#    echo 'export PATH="$PATH:[PATH_TO_FLUTTER_SDK]/bin"' >> ~/.zshrc
#    source ~/.zshrc
```

### 2. Install Xcode and Command Line Tools
```bash
# Install Xcode from App Store (recommended)
# Or download from Apple Developer website

# Install command line tools
sudo xcode-select --install

# Accept Xcode license
sudo xcodebuild -license
```

### 3. Install iOS Simulator
```bash
# Launch Xcode and install iOS Simulator:
# Xcode > Preferences > Platforms > iOS
# Download and install the iOS simulator runtime you want to test with

# Or using command line:
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -runFirstLaunch
```

### 4. Verify Flutter Setup
```bash
flutter doctor
# Ensure all checks pass, especially:
# [✓] Flutter (Channel stable)
# [✓] Xcode - develop for iOS and macOS
# [✓] iOS tools - develop for iOS
# [✓] iOS Simulator
```

## Project Setup

### 1. Clone or Navigate to Project
```bash
cd /path/to/plantcare
```

### 2. Install Dependencies
```bash
# Get Flutter packages
flutter pub get

# Check that all dependencies are properly installed
flutter doctor -v
```

### 3. Firebase Project Setup
```bash
# 1. Create a Firebase project at https://console.firebase.google.com/
# 2. Add an iOS app to your Firebase project
#    - Use your bundle ID (e.g., com.yourcompany.plantcare)
#    - Download the GoogleService-Info.plist file
# 3. Place GoogleService-Info.plist in the ios/Runner/ directory
# 4. Enable Authentication methods you want to use (Email, Google, etc.)
# 5. Enable Firestore and set up security rules
# 6. Enable Cloud Functions if needed
```

### 4. PlantNet API Setup
```bash
# 1. Get a PlantNet API key from https://my.plantnet.org/
# 2. Update the API key in lib/presentation/plant_identification_camera/plant_identification_camera.dart
#    Find the _getPlantNetApiKey() method and replace the placeholder:
#    return "your_actual_plantnet_api_key_here";
```

## Running the App on iOS Simulator

### 1. Check Available Devices
```bash
flutter devices
# Should show iOS Simulator devices like:
# iPhone 14 • iOS 16.0 • (your MacBook Air)
# iPhone 13 Pro • iOS 15.5 • (your MacBook Air)
```

### 2. Run the App
```bash
# Option 1: Run with default device
flutter run

# Option 2: Specify a specific iOS simulator
flutter run -d "iPhone 14"

# Option 3: List all devices and select
flutter devices
flutter run -d <device-id>
```

### 3. Apple Silicon M1/M2 Specific Considerations
```bash
# If you encounter any architecture-related issues:
cd ios
pod deintegrate
pod setup
pod install --repo-update
cd ..

# Then try running again:
flutter run
```

## Building for iOS Device (Optional)

### 1. Connect iOS Device
```bash
# Connect your iPhone/iPad via USB
# Trust the computer when prompted on your device
# Ensure device appears in flutter devices
```

### 2. Configure Code Signing
```bash
# In Xcode:
# 1. Open ios/Runner.xcworkspace
# 2. Select your team in Signing & Capabilities
# 3. Ensure bundle identifier is unique
# 4. Enable required permissions (Camera, Photos, etc.)
```

### 3. Build for Device
```bash
# Build IPA for iOS device
flutter build ios --release

# Or directly run on connected device
flutter run --release
```

## Testing End-to-End Functionality

### 1. Core Features Testing
- [ ] **App Launch**: App starts without errors
- [ ] **Authentication**: Sign up/in works with Firebase
- [ ] **Camera**: Camera captures images properly
- [ ] **Plant Recognition**: API calls return plant identification results
- [ ] **Add Plant**: Plants are saved to Firestore
- [ ] **Plant Dashboard**: Shows plants from database
- [ ] **Care Features**: Watering, logging care events
- [ ] **Notifications**: Care reminders work
- [ ] **Photos**: Add/edit photos functionality
- [ ] **Offline Mode**: App works without internet

### 2. Performance Testing
- [ ] App loads within 3 seconds
- [ ] UI is responsive (no freezes/jank)
- [ ] Plant identification returns results in < 10 seconds
- [ ] No memory leaks during extended use
- [ ] Background processes work properly

### 3. User Flow Testing
- [ ] Complete onboarding process
- [ ] Add first plant via camera identification
- [ ] Add plant manually
- [ ] Set up care reminders
- [ ] Add care notes and photos
- [ ] Navigate between all screens
- [ ] Test all interactive elements

## Deployment Preparation

### 1. Update App Settings
```yaml
# In pubspec.yaml, update:
name: plantcare  # Your app name
description: A plant care companion app

# Make sure version is updated:
version: 1.0.0+1  # format: major.minor.patch+build
```

### 2. Update iOS Settings
```bash
# In ios/Runner/Info.plist, add permissions:
# - Camera usage description
# - Photo library usage description
# - Notification permissions
```

### 3. Build for App Store
```bash
# Clean build
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release

# The built app will be in:
# build/ios/iphoneos/Runner.app
```

## Troubleshooting for MacBook Air M1/M2

### Common Issues and Solutions:

1. **CocoaPods Architecture Issues:**
```bash
# If encountering architecture errors:
sudo arch -x86_64 gem install ffi
cd ios
arch -x86_64 pod install
```

2. **Rosetta Compatibility (if needed):**
```bash
# Run Flutter with Rosetta if necessary:
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
- Close other memory-intensive applications
- Use smaller iOS device simulators for faster performance
- Ensure MacBook Air has adequate cooling

5. **Dependency Issues:**
```bash
# If getting dependency errors:
flutter pub cache repair
flutter pub get
```

## Optimization for MacBook Air

### Memory and Performance Tips:
- Close unnecessary applications while testing
- Use iPhone SE simulator for faster performance if needed
- Enable "Low Power Mode" simulation in simulator settings if needed
- Monitor Activity Monitor for resource usage

### Charging During Testing:
- Keep MacBook Air plugged in during extended testing sessions
- This ensures consistent performance during testing

## Final Verification Checklist

Before final testing:

- [ ] Flutter doctor shows no issues
- [ ] Firebase project is properly configured
- [ ] PlantNet API key is set
- [ ] iOS provisioning profiles are valid
- [ ] All app icons and launch screens are set
- [ ] Privacy descriptions are added to Info.plist
- [ ] Camera and photo permissions are configured

## iOS Simulator Optimization for MacBook Air

### Recommended Simulator Settings:
- Select iPhone SE or similar smaller device for better performance
- Enable "Low Resolution" in simulator settings (if needed)
- Use iOS 15+ for best M1 compatibility
- Disable unused device features in simulator settings

### Performance Settings:
```bash
# In simulator menu:
# Device > Erase All Content and Settings (for fresh test)
# Hardware > Device > select smaller device for better performance
```

This guide should help you successfully deploy and test the PlantCare application on your Apple Silicon MacBook Air with optimal performance.