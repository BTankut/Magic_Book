import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:magic_book/shared/models/tale_page.dart';

part 'tale.g.dart';

/// Masal modeli.
/// 
/// Bu sınıf, bir masalı temsil eder.
@HiveType(typeId: 1)
class Tale {
  /// Benzersiz tanımlayıcı.
  @HiveField(0)
  final String id;
  
  /// Masal başlığı.
  @HiveField(1)
  final String title;
  
  /// Masal teması.
  @HiveField(2)
  final String theme;
  
  /// Masal ortamı.
  @HiveField(3)
  final String setting;
  
  /// Masal kelime sayısı.
  @HiveField(4)
  final int wordCount;
  
  /// Kullanıcı ID'si.
  @HiveField(5)
  final String userId;
  
  /// Masal sayfaları.
  @HiveField(6)
  final List<TalePage> pages;
  
  /// Oluşturulma tarihi.
  @HiveField(7)
  final DateTime createdAt;
  
  /// Favori durumu.
  @HiveField(8)
  bool isFavorite;
  
  /// Çevrimdışı erişim durumu.
  @HiveField(9)
  bool _isAvailableOffline;
  
  /// Son indirme tarihi.
  @HiveField(10)
  DateTime? _lastDownloadedAt;
  
  /// Yeni bir masal oluşturur.
  Tale({
    String? id,
    required this.title,
    required this.theme,
    required this.setting,
    required this.wordCount,
    required this.userId,
    required this.pages,
    DateTime? createdAt,
    this.isFavorite = false,
    bool isAvailableOffline = false,
    DateTime? lastDownloadedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       _isAvailableOffline = isAvailableOffline,
       _lastDownloadedAt = lastDownloadedAt;
  
  /// Sayfa sayısını döndürür.
  int get pageCount => pages.length;
  
  /// Masalın tüm sayfalarının görsel ve ses dosyalarının indirilip indirilmediğini kontrol eder.
  bool get isFullyDownloaded {
    if (pages.isEmpty) return false;
    
    for (final page in pages) {
      // Görsel kontrolü
      if (page.imageBase64 == null || page.imageBase64!.isEmpty) {
        return false;
      }
      
      // Ses dosyası kontrolü
      if (page.audioPath == null || page.audioPath!.isEmpty) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Masalın bir kopyasını oluşturur.
  Tale copyWith({
    String? id,
    String? title,
    String? theme,
    String? setting,
    int? wordCount,
    String? userId,
    List<TalePage>? pages,
    DateTime? createdAt,
    bool? isFavorite,
    bool? isAvailableOffline,
    DateTime? lastDownloadedAt,
  }) {
    return Tale(
      id: id ?? this.id,
      title: title ?? this.title,
      theme: theme ?? this.theme,
      setting: setting ?? this.setting,
      wordCount: wordCount ?? this.wordCount,
      userId: userId ?? this.userId,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isAvailableOffline: isAvailableOffline ?? this._isAvailableOffline,
      lastDownloadedAt: lastDownloadedAt ?? this._lastDownloadedAt,
    );
  }
  
  /// Favori durumunu değiştiren bir kopya oluşturur.
  Tale copyWithFavorite(bool favoriteStatus) {
    return copyWith(isFavorite: favoriteStatus);
  }
  
  /// İndirme durumunu güncellenmiş bir kopya oluşturur.
  Tale copyWithDownloadStatus({
    required bool isFullyDownloaded,
    DateTime? lastDownloadedAt,
  }) {
    return copyWith(
      isAvailableOffline: isFullyDownloaded,
      lastDownloadedAt: lastDownloadedAt,
    );
  }
  
  /// Yeni bir sayfa ekler.
  void addPage(TalePage page) {
    pages.add(page);
  }
  
  /// JSON'dan oluşturur.
  factory Tale.fromJson(Map<String, dynamic> json) {
    return Tale(
      id: json['id'] as String?,
      title: json['title'] as String,
      theme: json['theme'] as String,
      setting: json['setting'] as String,
      wordCount: json['wordCount'] as int,
      userId: json['userId'] as String,
      pages: (json['pages'] as List<dynamic>)
          .map((e) => TalePage.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      isAvailableOffline: json['isAvailableOffline'] as bool? ?? false,
      lastDownloadedAt: json['lastDownloadedAt'] != null ? DateTime.parse(json['lastDownloadedAt'] as String) : null,
    );
  }
  
  /// JSON'a dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'theme': theme,
      'setting': setting,
      'wordCount': wordCount,
      'userId': userId,
      'pages': pages.map((e) => e.toJson()).toList(),
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'isAvailableOffline': _isAvailableOffline,
      'lastDownloadedAt': _lastDownloadedAt?.toIso8601String(),
    };
  }
  
  /// Çevrimdışı erişim için kullanılabilir olup olmadığını kontrol eder.
  bool get isAvailableOffline => _isAvailableOffline;
  
  /// Son indirme tarihini döndürür.
  DateTime? get lastDownloadedAt => _lastDownloadedAt;
  
  @override
  String toString() {
    return 'Tale(id: $id, title: $title, theme: $theme, setting: $setting, wordCount: $wordCount, pageCount: $pageCount, isFavorite: $isFavorite, isAvailableOffline: $_isAvailableOffline)';
  }
}
