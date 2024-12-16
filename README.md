## Tempestas

### In ancient Roman religion, Tempestas (Latin tempestas: "season, weather; bad weather; storm, tempest") is a goddess of storms or sudden weather.

## A simple weather app.

### Features:

- written from scratch
- no third party code / libraries
- open weather API to get weather location
- using direct geocoding to get lon/lat by name
- using reverse geocoding api to get name by lon/lat
- core location to get the current location
- SwiftUI
- simple persistance model (good enough for this small test app)
- both ObservableObject and Observable is tried and supported (you'd need to go through the code and comment/uncomment the corresponding chunks, look for "MARK: Observation variant", there'll be about two dozen of those)
- an example of pixel-perfect UI (reveal the mock screen for comparison, and use the debug button with options). For best results use the device or simulator that matches mock screens (iPhone 14, light mode).
- weather info is updated every two minutes. Bonus point: time in the list is updated every minute.

### Known issues:
- To investigate later why Observable recreated the "@State" model. Using a singleton as a workaround.
- Search experience is not perfect (the app doesn't do life search as you type the name partially, it only starts searching once you press continue)
- More attention should be drawn to error handling (network on/off, weather api errors, core location errors)
- Not all features of the weather API are utilized in the app. Features like weather alerts, hourly/minutely forecasts, wind data, etc., are available in the API but not displayed in the app.
- The API key will eventually expire or be disabled, so this test app may not work indefinitely.

### Not in scope:
- localizaton
- Adaptation for Swift 6 (when available) is not in scope.
- Unit / UI testing
- platforms other than iOS. The macOS build would require UI adjustments and minor changes for compatibility. The app works under catalyst but the UI is quite poor.
