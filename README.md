# RideWaitZ

RideWaitZ is an Apple Watch app that provides real-time wait times for rides at various theme parks. This app uses the ThemeParks API from themeparks.wiki to fetch and display ride wait times and park hours for the following parks:
- Universal Studios Florida
- Universal Islands of Adventure
- Disney's Magic Kingdom
- Disney's Animal Kingdom
- Disney's Holywood Studios
- Epcot

## Features

- **Real-time Wait Times**: View current wait times for rides.
- **Park Hours**: See opening and closing times for the parks.
- **Interactive UI**: Tap on a park to view its details.

## API Attribution

This app uses the [ThemeParks API](https://themeparks.wiki/). Special thanks to the themeparks.wiki team for their epic API.

## Endpoints Used

- **Live Data Endpoint**: Fetches current ride wait times.
  - `https://api.themeparks.wiki/v1/entity/{parkId}/live`
- **Schedule Endpoint**: Fetches park hours.
  - `https://api.themeparks.wiki/v1/entity/{parkId}/schedule`

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/MarcusDLG/RideWaitZ.git
   ```
2. Open the project in Xcode.
3. Build and run the project on your Apple Watch simulator or device.

## Usage

1. Launch the app on your Apple Watch.
2. Tap on a park to view its ride wait times and operating hours.

## License

This project is licensed under the MIT License.

## Contact

For any questions or issues, please open an issue in the GitHub repository.

---

Feel free to modify this draft according to your preferences and additional details about your app.

