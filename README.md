# Vintage Radio App (iOS)

## Description

Welcome to the Vintage Radio App for iOS! This application brings you a curated collection of classic hits from the 50s, 60s, 70s, 80s, 90s, and 2000s. Experience a nostalgic journey through music with a custom-themed UI that simulates a vintage radio player. The app streams music directly from YouTube.

## Features

- **Decade-Based Playlists:** Select your favorite decade and listen to a shuffled playlist of iconic songs from that era.
- **Custom Player UI:** A unique user interface designed to feel like a vintage radio.
- **Interactive Decade Slider:** A custom slider component to easily switch between decades.
- **YouTube Integration:** Leverages the YouTube IFrame Player API to stream video content.
- **Robust Error Handling:** The player automatically detects unavailable videos and skips to the next song.
- **Built with SwiftUI:** A modern, declarative UI framework for building iOS apps.

## How to Build and Run

Since this project was developed in an environment without direct Xcode access, the `.xcodeproj` project file is not included. To run this application, you will need to create a new Xcode project and add the provided source files.

**Prerequisites:**
- A Mac computer with the latest version of Xcode installed.

**Steps:**

1.  **Create a New Xcode Project:**
    - Open Xcode and select `File > New > Project...`.
    - Choose the **iOS App** template.
    - Name the product `VintageRadioApp`, select **SwiftUI** for the Interface, and **Swift** for the Language.
    - Save the project to your desired location.

2.  **Add Source and Resource Files:**
    - In the Xcode Project Navigator (the left-hand panel), right-click on the main project folder and select **"Add Files to 'VintageRadioApp'..."**.
    - Navigate to the `VintageRadioApp` directory containing the source code.
    - Select all the `.swift` files and the `resources` directory (`ids.txt` and `youtube_player.html`).
    - **Important:** In the options dialog, ensure that **"Copy items if needed"** is checked and that your app's target is selected in the **"Add to targets"** list. This is crucial for the resource files to be included in the app bundle.
    - Click **Add**.

3.  **Run the App:**
    - At the top of the Xcode window, select an iOS Simulator (e.g., "iPhone 15 Pro") as the run destination.
    - Click the **Run** button (the play icon) or press `Cmd + R`.

## Project Structure

The project is organized into the following main directories:

-   `/data`: Contains the `Song` data model and the `SongParser` for loading song data from the text file.
-   `/resources`: Contains the `ids.txt` data file and the `youtube_player.html` used for the embedded player.
-   `/ui`: Contains all SwiftUI views (`VideoPlayerView`, `DecadeSlider`), the `VideoPlayerViewModel` for state management, and the `YouTubePlayer` wrapper.

## Dependencies

This project is self-contained and does not have any external binary dependencies (like CocoaPods or Swift Package Manager). It uses Apple's standard frameworks (SwiftUI, Foundation, WebKit) and the web-based YouTube IFrame Player API.
