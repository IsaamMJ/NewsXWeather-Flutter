import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/weather_controller.dart';
import '../../domain/entities/location_suggestion.dart';
import '../../../../core/theme/app_colors.dart';

class LocationChangeDialog extends StatefulWidget {
  const LocationChangeDialog({Key? key}) : super(key: key);

  @override
  State<LocationChangeDialog> createState() => _LocationChangeDialogState();
}

class _LocationChangeDialogState extends State<LocationChangeDialog> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherController _weatherController = Get.find<WeatherController>();
  List<LocationSuggestion> _suggestions = [];
  bool _isSearching = false;
  String _searchError = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _searchError = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = '';
    });

    try {
      // Debouncing - wait 500ms after user stops typing
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if the search query is still the same (user hasn't typed more)
      if (query != _searchController.text) return;

      final suggestions = await _weatherController.searchLocations(query);
      setState(() {
        _suggestions = suggestions;
        _isSearching = false;
        if (suggestions.isEmpty) {
          _searchError = 'No locations found';
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchError = 'Search failed. Please try again.';
        _suggestions = [];
      });
    }
  }

  void _selectLocation(LocationSuggestion location) {
    _weatherController.setManualLocation(location);
    Navigator.of(context).pop();
  }

  void _useCurrentLocation() {
    _weatherController.useCurrentLocation();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Title
            Text(
              'Change Location',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 20),

            // Current Location Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getAccent(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Divider with "OR" text
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for a city...',
                hintStyle: TextStyle(
                  color: AppColors.getTextSecondary(context),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.getTextSecondary(context),
                ),
                suffixIcon: _isSearching
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.getTextSecondary(context).withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.getAccent(context),
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
              ),
            ),

            // Error Message
            if (_searchError.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _searchError,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],

            // Search Results
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Select a location:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      title: Text(
                        suggestion.name,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${suggestion.state != null ? '${suggestion.state}, ' : ''}${suggestion.country}',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                      leading: Icon(
                        Icons.location_on,
                        color: AppColors.getAccent(context),
                      ),
                      onTap: () => _selectLocation(suggestion),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: AppColors.getCardColor(context).withOpacity(0.3),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Close Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}