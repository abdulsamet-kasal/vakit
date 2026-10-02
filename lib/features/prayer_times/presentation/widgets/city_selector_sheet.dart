import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/city_model.dart';
import '../../domain/district_data.dart';

/// İl ve İlçe seçimi alt sayfası (BottomSheet).
/// - 81 ili ve 972 ilçeyi doğrudan arama (örn: "Kadıköy", "Alanya", "Çankaya")
/// - İl seçildiğinde o ile ait ilçeleri listeleyen akıcı hiyerarşik geçiş
/// - GPS ile anında il ve ilçe tespiti
/// - Tamamen çevrimdışı (offline-first) güvencesi
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
  
  // Seçili il (null ise 81 il listelenir, doluysa o ilin ilçeleri listelenir)
  CityModel? _selectedParentCity;
  List<DistrictSearchResult> _searchResults = [];
  bool _isSearching = false;
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
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    } else {
      setState(() {
        _isSearching = true;
        _searchResults = DistrictData.search(query);
      });
    }
  }

  Future<void> _handleSelection({
    required CityModel baseCity,
    String? districtName,
  }) async {
    final navigator = Navigator.of(context);
    final isMerkez = districtName == null || districtName == 'Merkez' || districtName.isEmpty;
    final finalDistrict = isMerkez ? null : districtName;

    // Hızlı UI tepkisi için tabanı hazırla
    var finalCity = baseCity.copyWith(district: finalDistrict);

    // İnternet varsa ilçenin daha hassas koordinatlarını çekmeyi dene
    if (!isMerkez) {
      try {
        final locations = await Geocoding().locationFromAddress(
          '$districtName, ${baseCity.name}, Türkiye',
        );
        if (locations.isNotEmpty) {
          final loc = locations.first;
          finalCity = finalCity.copyWith(
            latitude: loc.latitude,
            longitude: loc.longitude,
          );
        }
      } catch (_) {
        // Çevrimdışıysa il merkezinin koordinatları güvenle kullanılır
      }
    }

    widget.onCitySelected(finalCity);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.parchment;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Tutamaç Çizgisi
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Başlık ve Geri / Kapat Butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (_selectedParentCity != null && !_isSearching) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'İllere Dön',
                    onPressed: () {
                      setState(() {
                        _selectedParentCity = null;
                        _searchController.clear();
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedParentCity!.name} İlçeleri',
                          style: AppTypography.headlineMedium(
                            color: isDark ? AppColors.darkText : AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'İlçe seçerek yerel vakitleri görüntüleyin',
                          style: AppTypography.bodySmall(
                            color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSearching ? 'Konum Arama' : 'Konum Seçimi',
                          style: AppTypography.headlineMedium(
                            color: isDark ? AppColors.darkText : AppColors.ink,
                          ),
                        ),
                        Text(
                          'Mevcut: ${widget.currentCity.displayName}',
                          style: AppTypography.bodySmall(
                            color: AppColors.brassGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // GPS ile Konumumu Bul Butonu (Yalnızca il listesindeyken)
          if (_selectedParentCity == null && !_isSearching) ...[
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
                              SnackBar(
                                content: const Text(
                                  'Konum alınamadı. Lütfen GPS iznini kontrol edin veya listeden il/ilçe seçin.',
                                ),
                                action: SnackBarAction(
                                  label: 'Ayarlar',
                                  onPressed: () {
                                    Geolocator.openAppSettings();
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.sageGreen : AppColors.forestGreen)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark ? AppColors.sageGreen : AppColors.forestGreen)
                          .withValues(alpha: 0.25),
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
                        'GPS ile İl ve İlçe Tespit Et',
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
          ],

          // Arama Kutusu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _selectedParentCity != null
                    ? '${_selectedParentCity!.name} ilçesi ara...'
                    : 'İl veya ilçe ara (örn: Kadıköy, Alanya, Bursa)...',
                hintStyle: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
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

          // Liste Görünümü (Arama Sonuçları | İlçe Listesi | 81 İl Listesi)
          Expanded(
            child: _buildListContent(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(BuildContext context, bool isDark) {
    // 1. Durum: Arama yapılıyorsa
    if (_isSearching) {
      if (_searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 40, color: AppColors.clayAmber),
              const SizedBox(height: 10),
              Text(
                'Eşleşen il veya ilçe bulunamadı.',
                style: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => Divider(
          color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.08),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final res = _searchResults[index];
          final baseCity = CityModel.findByName(res.cityName) ?? CityModel.defaultCity;
          final isSelected = baseCity.name == widget.currentCity.name &&
              (res.districtName == widget.currentCity.district ||
                  (res.districtName == null && widget.currentCity.district == null));

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
            title: Text(
              res.districtName != null ? res.districtName! : res.cityName,
              style: AppTypography.bodyLarge(
                color: isSelected
                    ? AppColors.brassGold
                    : (isDark ? AppColors.darkText : AppColors.ink),
              ).copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            subtitle: Text(
              res.subtitle,
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check, color: AppColors.brassGold, size: 20)
                : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            onTap: () {
              _handleSelection(
                baseCity: baseCity,
                districtName: res.districtName,
              );
            },
          );
        },
      );
    }

    // 2. Durum: Bir il seçilmiş ve o ilin ilçeleri listeleniyorsa
    if (_selectedParentCity != null) {
      final city = _selectedParentCity!;
      final districts = DistrictData.getDistricts(city.name);

      return ListView.separated(
        itemCount: districts.length + 1, // +1: İl Merkezi seçeneği
        separatorBuilder: (context, index) => Divider(
          color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.08),
          height: 1,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = widget.currentCity.name == city.name &&
                (widget.currentCity.district == null || widget.currentCity.district == 'Merkez');
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              leading: const Icon(Icons.location_city_rounded, color: AppColors.brassGold, size: 22),
              title: Text(
                'İl Merkezi (Tüm İl)',
                style: AppTypography.bodyLarge(
                  color: isSelected
                      ? AppColors.brassGold
                      : (isDark ? AppColors.darkText : AppColors.ink),
                ).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.brassGold, size: 20)
                  : null,
              onTap: () {
                _handleSelection(baseCity: city, districtName: null);
              },
            );
          }

          final district = districts[index - 1];
          final isSelected = widget.currentCity.name == city.name &&
              widget.currentCity.district == district;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
            title: Text(
              district,
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
              _handleSelection(baseCity: city, districtName: district);
            },
          );
        },
      );
    }

    // 3. Durum: Standart 81 İl Listesi
    return ListView.separated(
      itemCount: CityModel.turkishCities.length,
      separatorBuilder: (context, index) => Divider(
        color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.08),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final city = CityModel.turkishCities[index];
        final isSelected = city.name == widget.currentCity.name;
        final districtCount = DistrictData.getDistricts(city.name).length;

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
          subtitle: Text(
            '$districtCount İlçe',
            style: AppTypography.bodySmall(
              color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Text(
                  widget.currentCity.district ?? 'Merkez',
                  style: AppTypography.labelSmall(color: AppColors.brassGold),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.check, color: AppColors.brassGold, size: 18),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
            ],
          ),
          onTap: () {
            // İle tıklandığında o ilin ilçelerini aç
            setState(() {
              _selectedParentCity = city;
            });
          },
        );
      },
    );
  }
}
