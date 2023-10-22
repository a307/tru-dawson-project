import 'package:flutter/material.dart';
import 'google_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapField extends StatefulWidget{
  // This class represents the main screen of the app where the Google Map is displayed.
  const MapField({super.key});

  @override
  State<MapField> createState() => _MapFieldState();
}

class _MapFieldState extends State<MapField> {
  // A Future to load the user's current coordinates from the view model. 
  // This Future is used to fetch location information asynchronously.
  late final Future<LatLng> _mapLoadedFuture;

  // An instance of the GoogleMapViewModel class, responsible for managing map-related functionality.
  final viewModel = GoogleMapViewModel();

  @override
  void initState() {
    super.initState();

    // Initialize the mapLoadedFuture by loading the user's current coordinates
    _mapLoadedFuture = viewModel.loadCurrentUserCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: FutureBuilder(
              future: _mapLoadedFuture,
              builder: (context, snapshot) {
                // Check the connection state of the Future
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Display a loading indicator while waiting for the coordinates.
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  // Handle and display an error message if an error occurs during fetching.
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                    ),
                  );
                }

                // Once the coordinates are available, create a GoogleMapWidget to display the map.
                return GoogleMapWidget(
                  currentUserLocation: snapshot.data as LatLng,
                  onMapCreated: (controller) {
                    viewModel.controller.complete(controller);
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class GoogleMapWidget extends StatelessWidget {
  // This class represents the widget responsible for displaying the Google Map.
  const GoogleMapWidget({
    required this.onMapCreated,
    required this.currentUserLocation,
    super.key,
  });

  // Callback function to handle when the map is created.
  final void Function(GoogleMapController) onMapCreated;
  
  // The user's current location on the map.
  final LatLng currentUserLocation;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        // Set the initial camera position to focus on the user's current location.
        target: currentUserLocation,
        zoom: 18, // Zoom level for initial map view.
      ),
      onMapCreated: onMapCreated,
      markers: {
        Marker(
          // Create a marker to represent the user's current location on the map.
          markerId: const MarkerId('current_location'),
          position: currentUserLocation,
          onTap: () {
            // Show a dialog with the latitude and longitude when the marker is tapped.
            showDialog(
              context: context,
              builder: (_) => MarkerCoordinatesDialog(
                latitude: currentUserLocation.latitude,
                longitude: currentUserLocation.longitude,
              ),
            );
          },
        ),
      },
    );
  }
}

class MarkerCoordinatesDialog extends StatelessWidget {
  // This class represents a dialog that displays the latitude and longitude of a marker.
  const MarkerCoordinatesDialog({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  // Latitude and longitude values to be displayed in the dialog.
  final double latitude, longitude;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("User's Current Location"),
      content: Text(
        // Display the latitude and longitude in the content of the dialog.
        'Latitude: $latitude, Longitude: $longitude',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
