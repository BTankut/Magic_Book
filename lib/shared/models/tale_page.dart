import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'tale_page.g.dart';

/// Masal sayfası modeli.
/// 
/// Bu sınıf, bir masalın sayfasını temsil eder.
@HiveType(typeId: 2)
class TalePage {
  /// Benzersiz tanımlayıcı.
  @HiveField(0)
  final String id;
  
  /// Sayfa numarası.
  @HiveField(1)
  final int pageNumber;
  
  /// Sayfa içeriği.
  @HiveField(2)
  final String content;
  
  /// Sayfa görseli (Base64 kodlanmış).
  @HiveField(3)
  final String? imageBase64;
  
  /// Sayfa ses dosyası yolu.
  @HiveField(4)
  final String? audioPath;
  
  /// Varsayılan constructor.
  TalePage({
    String? id,
    required this.pageNumber,
    required this.content,
    this.imageBase64,
    this.audioPath,
  }) : id = id ?? const Uuid().v4();
  
  /// JSON'dan oluşturur.
  factory TalePage.fromJson(Map<String, dynamic> json) {
    return TalePage(
      id: json['id'] as String?,
      pageNumber: json['pageNumber'] as int,
      content: json['content'] as String,
      imageBase64: json['imageBase64'] as String?,
      audioPath: json['audioPath'] as String?,
    );
  }
  
  /// JSON'a dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageNumber': pageNumber,
      'content': content,
      'imageBase64': imageBase64,
      'audioPath': audioPath,
    };
  }
  
  /// Ses dosyası yolunu güncellenmiş bir kopya oluşturur.
  @visibleForTesting
  TalePage copyWithAudioPath(String? audioPath) {
    return TalePage(
      id: id,
      pageNumber: pageNumber,
      content: content,
      imageBase64: imageBase64,
      audioPath: audioPath,
    );
  }
  
  /// Görsel Base64 kodunu güncellenmiş bir kopya oluşturur.
  @visibleForTesting
  TalePage copyWithImageBase64(String? imageBase64) {
    return TalePage(
      id: id,
      pageNumber: pageNumber,
      content: content,
      imageBase64: imageBase64,
      audioPath: audioPath,
    );
  }
  
  @override
  String toString() {
    return 'TalePage(id: $id, pageNumber: $pageNumber, content: $content, hasImage: ${imageBase64 != null}, hasAudio: ${audioPath != null})';
  }
}
