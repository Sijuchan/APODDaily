# APODDaily

The app uses NASA’s Astronomy Picture of the Day (APOD) API:
https://github.com/nasa/apod-api

---

## What the app does

- Loads today’s APOD when the app starts
- Displays:
  - Title
  - Date
  - Image or video
  - Explanation
- Handles both image and video responses from the API
- Allows the user to pick any date and load that day’s APOD
- Caches the last successful response (including image)
- Falls back to cached data if a request fails

---

## Bonus features

- Works on iPhone and iPad
- Supports different orientations
- Dark Mode support
- Dynamic Type support for accessibility

---

## Architecture

The app follows a simple and clean structure using:

- **MVVM**
- **Repository pattern**
- **Coordinator pattern**

### Overview

- **View (SwiftUI)**
  - Displays UI and reacts to state changes

- **ViewModel**
  - Manages screen state (loading, content, error)
  - Calls the repository to fetch data

- **Repository**
  - Handles data fetching
  - Decides between API and cache

- **Service**
  - Makes API calls using URLSession

- **Mapper**
  - Converts API response into app model

- **Disk Cache**
  - Stores last successful APOD response and image

- **Coordinator**
  - Manages navigation and tab structure (Today / Explore)

---

## Key implementation notes

- App loads today’s APOD automatically on launch
- Video entries are handled separately from images
- Explore tab allows loading APOD for any selected date
- If network fails, cached data is used as fallback
- No third-party libraries are used (as required)

---

## Unit Tests

Unit tests are included to cover the main logic of the app.

### What is tested

**Date Formatting**
- Ensures API date strings are parsed and formatted correctly

**Mapping**
- Verifies correct mapping of image responses
- Verifies correct handling of video responses
- Checks fallback when `hdurl` is missing

**Disk Cache**
- Tests saving and loading of APOD data
- Ensures image data is cached and restored
- Confirms latest cached entry is returned

**ViewModel**
- Verifies initial state
- Ensures auto-load happens only once
- Tests successful loading updates state correctly
- Tests error handling
- Verifies cached results are flagged correctly
- Ensures selected date is passed correctly
- Confirms video content is handled correctly

The focus of the tests is on logic-heavy parts like mapping, caching, and state handling.

---

## Running the app

1. Open the project in Xcode
2. Run on iOS 18+ simulator or device
3. Add a NASA API key if needed

If no API key is provided, the app uses `DEMO_KEY`.

---

## Notes

This project was built as a take-home exercise with a focus on:

- Clean structure
- Readability
- Testability
- Stability

No confidential or third-party code has been used.
