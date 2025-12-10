import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math' as math;

class AppColors {
  static const Color darkGreen = Color(0xFF0F2A1D);
  static const Color mediumDarkGreen = Color(0xFF375534);
  static const Color primary = Color(0xFF6B9071);
  static const Color lightGreen = Color(0xFFAEC3B0);
  static const Color offWhite = Color(0xFFE3EED4);
  static const Color buttonYellow = Color(0xFFF9C74F);
  static const Color buttonBlack = Colors.black;
  static const Color textFieldBorder = Colors.grey;
}

// ==================== PAGE DE CARTE OPENSTREETMAP ====================
class MapTrackingScreen extends StatefulWidget {
  const MapTrackingScreen({super.key});

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen>
    with SingleTickerProviderStateMixin {
  // Position de l'utilisateur (Cotonou, Bénin)
  final LatLng userPosition = LatLng(6.3703, 2.3912);

  // Position du livreur (sera animée)
  LatLng deliveryPosition = LatLng(6.3850, 2.4050);

  // Historique des positions du livreur (traînée)
  List<LatLng> deliveryTrail = [];

  Timer? _timer;
  final MapController _mapController = MapController();

  // Animation de rotation de la moto
  late AnimationController _rotationController;
  double _deliveryRotation = 0;

  @override
  void initState() {
    super.initState();
    deliveryTrail.add(deliveryPosition);
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startDeliveryAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  // Animation du mouvement du livreur
  void _startDeliveryAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        // Position précédente pour calculer l'angle
        LatLng oldPosition = deliveryPosition;

        // Déplacer le livreur vers l'utilisateur progressivement
        double deltaLat = (userPosition.latitude - deliveryPosition.latitude) * 0.08;
        double deltaLng = (userPosition.longitude - deliveryPosition.longitude) * 0.08;

        deliveryPosition = LatLng(
          deliveryPosition.latitude + deltaLat,
          deliveryPosition.longitude + deltaLng,
        );

        // Calculer l'angle de rotation basé sur la direction
        _deliveryRotation = _calculateBearing(oldPosition, deliveryPosition);

        // Ajouter à la traînée (garder les 15 dernières positions)
        deliveryTrail.add(deliveryPosition);
        if (deliveryTrail.length > 15) {
          deliveryTrail.removeAt(0);
        }

        // Centrer la carte entre les deux points
        _centerMapBetweenPoints();

        // Arrêter l'animation quand le livreur est proche
        double distance = _calculateDistance(userPosition, deliveryPosition);
        if (distance < 0.1) {
          timer.cancel();
        }
      });
    });
  }

  // Calculer l'angle entre deux points (bearing)
  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * math.pi / 180;
    double lat2 = end.latitude * math.pi / 180;
    double dLng = (end.longitude - start.longitude) * math.pi / 180;

    double y = math.sin(dLng) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    double bearing = math.atan2(y, x);

    return (bearing * 180 / math.pi + 360) % 360;
  }

  // Calculer la distance entre deux points
  double _calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  // Centrer la carte entre les deux points
  void _centerMapBetweenPoints() {
    double lat = (userPosition.latitude + deliveryPosition.latitude) / 2;
    double lng = (userPosition.longitude + deliveryPosition.longitude) / 2;
    _mapController.move(LatLng(lat, lng), 14.5);
  }

  @override
  Widget build(BuildContext context) {
    double distance = _calculateDistance(userPosition, deliveryPosition);
    int estimatedTime = (distance * 4).round();

    return Scaffold(
      body: Stack(
        children: [
          // Carte OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                (userPosition.latitude + deliveryPosition.latitude) / 2,
                (userPosition.longitude + deliveryPosition.longitude) / 2,
              ),
              initialZoom: 14.5,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              // Tuiles OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                maxZoom: 19,
              ),

              // Ligne de trajet principal
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [userPosition, deliveryPosition],
                    color: AppColors.primary.withOpacity(0.6),
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),

              // Traînée du livreur (historique des positions)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: deliveryTrail,
                    gradientColors: [
                      AppColors.buttonYellow.withOpacity(0.2),
                      AppColors.buttonYellow.withOpacity(0.8),
                      AppColors.buttonYellow,
                    ],
                    strokeWidth: 6,
                    borderStrokeWidth: 2,
                    borderColor: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),

              // Marqueurs
              MarkerLayer(
                markers: [
                  // Marqueur utilisateur
                  Marker(
                    width: 80,
                    height: 80,
                    point: userPosition,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Vous',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Colors.blue,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Marqueur livreur (moto animée)
                  Marker(
                    width: 100,
                    height: 100,
                    point: deliveryPosition,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.buttonYellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$estimatedTime min',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Transform.rotate(
                          angle: _deliveryRotation * math.pi / 180,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.buttonYellow,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.buttonYellow.withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.delivery_dining,
                              color: Colors.black87,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Cercle de zone de livraison autour de l'utilisateur
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: userPosition,
                    color: Colors.blue.withOpacity(0.1),
                    borderColor: Colors.blue.withOpacity(0.3),
                    borderStrokeWidth: 2,
                    radius: 100,
                  ),
                ],
              ),
            ],
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.arrow_back, color: AppColors.darkGreen),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'En livraison',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Arrivée dans ~$estimatedTime min',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${distance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contrôles de zoom
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              children: [
                _buildZoomButton(Icons.add, () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                }),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.remove, () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                }),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.my_location, () {
                  _centerMapBetweenPoints();
                }),
              ],
            ),
          ),

          // Panel d'informations en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Info livreur
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.mediumDarkGreen,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'KOFFI Albyn',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.star, size: 16, color: AppColors.buttonYellow),
                                        const SizedBox(width: 4),
                                        Text(
                                          '4.9',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Vérifié',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _buildActionButton(Icons.chat_bubble_outline, () {}),
                                  const SizedBox(width: 8),
                                  _buildActionButton(Icons.phone, () {}),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Informations de livraison
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _buildDeliveryInfo(
                                  Icons.location_on,
                                  'Point de départ',
                                  'Rue de la Paix, Cotonou',
                                ),
                                const SizedBox(height: 12),
                                Container(height: 1, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                _buildDeliveryInfo(
                                  Icons.home,
                                  'Destination',
                                  'Votre adresse, Cotonou',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Détails commande
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.schedule,
                                  title: 'Temps',
                                  value: '$estimatedTime min',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.straighten,
                                  title: 'Distance',
                                  value: '${distance.toStringAsFixed(1)} km',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.inventory_2_outlined,
                                  title: 'Commande',
                                  value: '#12345',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Bouton d'annulation
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => _showCancelDialog(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red[400]!, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Annuler la commande',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[400],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  Widget _buildDeliveryInfo(IconData icon, String title, String address) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Annuler la commande ?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGreen),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir annuler cette commande ? Des frais d\'annulation peuvent s\'appliquer.',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Non, continuer',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Tracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: AppColors.primary, fontFamily: 'Roboto'),
      home: const MapTrackingScreen(),
    );
  }
}