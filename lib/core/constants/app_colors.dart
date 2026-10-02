import 'package:flutter/material.dart';

/// Tasarım rehberindeki renk paleti sabitleri.
/// AI kokusu oluşturacak mor/mavi gradyanlar veya jenerik tohum renkleri yerine
/// cami avlusu, el yazması mushaf ve doğal taş/pirinç hissini yansıtır.
abstract final class AppColors {
  // Açık Tema & Temel Renkler
  static const Color forestGreen = Color(0xFF0F3D2E); // Derin orman yeşili (ana)
  static const Color mossGreen = Color(0xFF2F6B4F);   // Yosun yeşili
  static const Color sageGreen = Color(0xFFA9C4B0);   // Adaçayı
  static const Color paleSage = Color(0xFFDCE7DD);    // Soluk adaçayı / kart zemini
  static const Color parchment = Color(0xFFF3EEE0);   // Parşömen kremi (açık tema zemini)
  static const Color parchmentWarm = Color(0xFFEBE4D2); // Hafif sıcak parşömen (kenarlık/kart)

  // Vurgu Renkleri
  static const Color brassGold = Color(0xFFB8934A);   // Mat pirinç/altın (tek vurgu)
  static const Color brassGlow = Color(0xFFD4B36A);   // Parlama anı için hafif açık pirinç
  static const Color clayAmber = Color(0xFFC27A3E);   // Kil/amber (yalnızca kerahat vakitleri)

  // Metin Renkleri (Açık Tema)
  static const Color ink = Color(0xFF14201A);         // Mürekkep siyahı-yeşili
  static const Color inkMuted = Color(0xFF4A5C52);    // İkincil metin

  // Koyu Tema Renkleri (Saf siyah ve saf beyaz KULLANILMAZ)
  static const Color darkBg = Color(0xFF0A1612);      // Koyu zemin
  static const Color darkSurface = Color(0xFF12251D); // Koyu yüzey
  static const Color darkSurfaceElevated = Color(0xFF183227); // Kart/Panel yüzeyi
  static const Color darkText = Color(0xFFE4EDE6);    // Koyu tema metin (kırık açık yeşil/krem)
  static const Color darkMuted = Color(0xFF8FA899);   // Koyu tema ikincil metin
  static const Color darkBorder = Color(0xFF1F3B2F);  // Koyu tema ince ayırıcı

  // Zaman Dilimi Dinamik Zemin Tonları
  static const Color dawnTint = Color(0xFF0B1914);    // İmsak öncesi derin ton
  static const Color noonTint = Color(0xFFF7F3E8);    // Öğlen aydınlık parşömen
  static const Color duskTint = Color(0xFFEFE8DC);    // Akşam sıcak parşömen
}
