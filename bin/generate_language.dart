import 'dart:convert';
import 'dart:io';
import 'package:translator/translator.dart';

void main() async {
  final translator = GoogleTranslator();

  // 1. Lokasi file Bahasa Utama (Inggris)
  final File enFile = File('assets/translations/en-US.json');
  
  // 2. Daftar Bahasa Target
  final Map<String, String> targets = {
    // Asia
    'id-ID': 'id', // Indonesia
    'ja-JP': 'ja', // Jepang
    'ms-MY': 'ms', // Malaysia
    'zh-CN': 'zh-cn', // China
    'ko-KR': 'ko', // Korea
    'th-TH': 'th', // Thailand
    'hi-IN': 'hi', // Hindi
    // Timur Tengah
    'ar-SA': 'ar', // Arab
    'tr-TR': 'tr', // Turki
    // Eropa
    'es-ES': 'es', // Spanyol
    'fr-FR': 'fr', // Prancis
    'de-DE': 'de', // Jerman
    'it-IT': 'it', // Italia
    'ru-RU': 'ru', // Rusia
  };

  print("🔄 Sedang membaca file Inggris...");
  if (!enFile.existsSync()) {
    print("❌ File assets/translations/en-US.json tidak ditemukan!");
    return;
  }

  String jsonString = enFile.readAsStringSync();
  if (jsonString.trim().isEmpty) return;
  
  final Map<String, dynamic> enData = jsonDecode(jsonString);

  for (var entry in targets.entries) {
    String fileName = entry.key; 
    String langCode = entry.value; 
    
    print("⏳ Sedang memproses: $fileName ($langCode)...");
    
    File targetFile = File('assets/translations/$fileName.json');
    Map<String, dynamic> targetData = {};

    if (targetFile.existsSync()) {
      try {
        String content = targetFile.readAsStringSync();
        if (content.trim().isNotEmpty) targetData = jsonDecode(content);
      } catch (e) {
        targetData = {};
      }
    }

    bool adaPerubahan = false;

    for (var key in enData.keys) {
      if (!targetData.containsKey(key)) {
        
        // --- FITUR ANTI-BLOKIR (DELAY) ---
        // Istirahat 500ms (setengah detik) setiap kata
        await Future.delayed(Duration(milliseconds: 500)); 
        // --------------------------------

        try {
          var translation = await translator.translate(enData[key], to: langCode);
          targetData[key] = translation.text;
          print("   ✅ [Baru] $key -> ${translation.text}");
          adaPerubahan = true;
        } catch (e) {
          // --- PERBAIKAN LOGIKA ERROR ---
          // Jangan simpan Inggris! Biarkan kosong biar dicoba lagi nanti.
          print("   ❌ Gagal (Skip dulu): $key"); 
        }
      }
    }

    if (adaPerubahan) {
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      targetFile.writeAsStringSync(encoder.convert(targetData));
      print("   🎉 Disimpan: $fileName.json");
    } else {
      print("   👌 Data sudah lengkap.");
    }
    print(""); 
  }

  print("✅ SEMUA SELESAI!");
}