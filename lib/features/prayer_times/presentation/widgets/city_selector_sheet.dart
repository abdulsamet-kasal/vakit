import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/city_model.dart';

/// Şehir seçimi alt sayfası (BottomSheet).
/// 81 ili filtreleyerek arama ve GPS ile anında konum tespiti sunar.
class CitySelectorSheet extends StatefulWidget {
  final CityModel currentCity;
  final ValueChanged<CityModel> onCitySelected;
  final Future<bool> Function() onDetectGps;

  const CitySelectorSheet({
    super.key,
    required this.currentCity,
    required this.onCitySelected,
    required this.onDetectGps,
  });

  @override
  State<CitySelectorSheet> createState() => _CitySelectorSheetState();
}

class _CitySelectorSheetState extends State<CitySelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CityModel> _filteredCities = CityModel.turkishCities;
  bool _isGpsLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = CityModel.turkishCities;
      } else {
        _filteredCities = CityModel.turkishCities.where((city) {
          return city.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.parchment;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Tutamaç çizgisi
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Başlık
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Şehir Seçimi',
                  style: AppTypography.headlineMedium(
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // GPS ile Konumumu Bul Butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isGpsLoading
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      setState(() => _isGpsLoading = true);
                      final success = await widget.onDetectGps();
                      if (mounted) {
                        setState(() => _isGpsLoading = false);
                        if (success) {
                          navigator.pop();
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Konum alınamadı. Lütfen GPS iznini kontrol edin veya listeden seçin.'),
                            ),
                          );
                        }
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.sageGreen : AppColors.forestGreen).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isDark ? AppColors.sageGreen : AppColors.forestGreen).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    if (_isGpsLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        Icons.my_location,
                        size: 20,
                        color: isDark ? AppColors.sageGreen : AppColors.forestGreen,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      'GPS ile Konumumu Tespit Et',
                      style: AppTypography.labelLarge(
                        color: isDark ? AppColors.sageGreen : AppColors.forestGreen,
                        isBold: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Arama Kutusu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Şehir adı ara (örn: Ankara, Bursa)...',
                hintStyle: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.paleSage.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Şehir Listesi
          Expanded(
            child: ListView.separated(
              itemCount: _filteredCities.length,
              separatorBuilder: (context, index) => Divider(
                color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.08),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                final isSelected = city.id == widget.currentCity.id;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                  title: Text(
                    city.name,
                    style: AppTypography.bodyLarge(
                      color: isSelected
                          ? AppColors.brassGold
                          : (isDark ? AppColors.darkText : AppColors.ink),
                    ).copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.brassGold, size: 20)
                      : null,
                  onTap: () {
                    widget.onCitySelected(city);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
