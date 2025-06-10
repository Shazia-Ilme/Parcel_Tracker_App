import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: TrackingPage(
        isDarkMode: isDarkMode,
        toggleTheme: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    );
  }
}

class TrackingPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  TrackingPage({required this.isDarkMode, required this.toggleTheme});

  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final TextEditingController _trackingController = TextEditingController();
  List<TrackingStep> _steps = [];
  bool showMap = false;
  bool showMapButton = false;
  gmap.GoogleMapController? mapController;

  String trackingCode = '';

  static const Map<String, gmap.LatLng> demoLocations = {
    '123S': gmap.LatLng(28.6139, 77.2090), // Delhi
    'H456': gmap.LatLng(19.0760, 72.8777), // Mumbai
    'DEL789': gmap.LatLng(12.9716, 77.5946), // Bangalore
  };

  final Map<String, List<TrackingStep>> mockData = {
    '123S': [
      TrackingStep(Icons.check_circle, 'Order Placed', '12 May, 9:00 AM',
          'Your order has been confirmed.'),
      TrackingStep(Icons.inventory_2, 'Shipped', '13 May, 2:00 PM',
          'Left the warehouse.'),
      TrackingStep(
          Icons.sync, 'In Transit', '14 May, 6:30 AM', 'Arrived at city hub.'),
      TrackingStep(Icons.delivery_dining, 'Out for Delivery',
          'ETA: 15 May, 10:00 AM', 'Delivery agent assigned.'),
      TrackingStep(
          Icons.lock_open, 'Delivered', 'Pending...', 'Awaiting confirmation.'),
    ],
    'H456': [
      TrackingStep(Icons.check_circle, 'Order Confirmed', '10 May, 11:00 AM',
          'We’ve received your order.'),
      TrackingStep(
          Icons.all_inbox, 'Packed', '11 May, 2:00 PM', 'Items packed.'),
      TrackingStep(Icons.local_shipping, 'Shipped', '12 May, 7:00 AM',
          'Shipment handed to courier.'),
      TrackingStep(Icons.directions_run, 'Out for Delivery',
          'ETA: 13 May, 9:30 AM', 'Agent is on the way.'),
      TrackingStep(
          Icons.lock_open, 'Delivered', 'Pending...', 'Awaiting confirmation.'),
    ],
    'DEL789': [
      TrackingStep(Icons.check_circle, 'Order Placed', '18 May, 10:00 AM',
          'Order received.'),
      TrackingStep(Icons.all_inbox, 'Processed', '18 May, 4:00 PM',
          'Prepared for dispatch.'),
      TrackingStep(Icons.flight_takeoff, 'Dispatched', '19 May, 8:00 AM',
          'Flight scheduled.'),
      TrackingStep(Icons.home, 'Arrived', '20 May, 9:45 AM',
          'At local distribution center.'),
      TrackingStep(
          Icons.lock_open, 'Delivered', '20 May, 3:00 PM', 'Delivered.'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print("Location permission granted");
    } else {
      print("Location permission denied");
    }
  }

  void _track() {
    final code = _trackingController.text.trim().toUpperCase();
    trackingCode = code;

    if (mockData.containsKey(code)) {
      setState(() {
        _steps = mockData[code]!;
        showMap = false;
        showMapButton = demoLocations.containsKey(code);
      });
    } else {
      setState(() {
        _steps = [];
        showMap = false;
        showMapButton = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid or unknown tracking number'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text("Parcel Tracker"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Lottie.asset(
                    'assets/delivery.json',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _trackingController,
                  decoration: InputDecoration(
                    labelText: 'Tracking Number',
                    hintText: 'Try: 123S, H456, DEL789',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _track,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.search, color: Colors.white),
                  label: Text(
                    'Track Shipment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (showMapButton)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showMap = true;
                      });
                    },
                    icon: Icon(Icons.pin_drop_rounded, color: Colors.white),
                    label: Text(
                      "View Parcel Location",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                if (showMap && demoLocations.containsKey(trackingCode))
                  Container(
                    height: 200,
                    margin: EdgeInsets.only(top: 16, bottom: 20),
                    child: gmap.GoogleMap(
                      initialCameraPosition: gmap.CameraPosition(
                        target: demoLocations[trackingCode]!,
                        zoom: 12,
                      ),
                      markers: {
                        gmap.Marker(
                          markerId: gmap.MarkerId("parcel_location"),
                          position: demoLocations[trackingCode]!,
                          infoWindow: gmap.InfoWindow(title: "Parcel Location"),
                        ),
                      },
                      onMapCreated: (controller) => mapController = controller,
                    ),
                  ),
                if (_steps.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: _steps
                          .map((step) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(step.icon,
                                        color: Colors.teal, size: 28),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${step.title} • ${step.date}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            step.description,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingStep {
  final IconData icon;
  final String title;
  final String date;
  final String description;

  TrackingStep(this.icon, this.title, this.date, this.description);
}
