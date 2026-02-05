import 'package:movies_app/cinemas/domain/entities/cinema.dart';

/// Curated cinema-only images (high-quality, stable URLs from Unsplash)
/// Each brand has multiple unique cinema photos to ensure variety while staying consistent
const Map<String, List<String>> _cinemaImagesByBrand = {
  'XXI': [
    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?auto=format&fit=crop&w=1200&q=80',
  ],
  'CGV': [
    'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
  ],
  'Cinepolis': [
    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=1200&q=80',
  ],
  'IMAX': [
    'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
  ],
  'NNG': [
    'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
  ],
};

/// Fallback cinema-only images (for unknown brands)
const List<String> _fallbackCinemaImages = [
  'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?auto=format&fit=crop&w=1200&q=80',
];

/// Get stable, deterministic cinema image URL based on cinema name
/// Same cinema name = same image (NOT random)
String getCinemaImageUrl(Cinema cinema) {
  // Try to find matching brand
  for (final entry in _cinemaImagesByBrand.entries) {
    if (cinema.name.toUpperCase().contains(entry.key.toUpperCase())) {
      final idx = _deterministicIndex(cinema.name, entry.value.length);
      return entry.value[idx];
    }
  }

  // Fallback for unknown brands - still deterministic
  final idx = _deterministicIndex(cinema.name, _fallbackCinemaImages.length);
  return _fallbackCinemaImages[idx];
}

/// Generate deterministic index from cinema name
int _deterministicIndex(String input, int modulo) {
  final hash = _fnv1aHash(input.toLowerCase());
  return (hash & 0x7FFFFFFF) % modulo;
}

/// FNV-1a hash function (deterministic 32-bit hash)
int _fnv1aHash(String input) {
  const int fnvPrime = 16777619;
  const int fnvOffsetBasis = 2166136261;

  int hash = fnvOffsetBasis;
  final bytes = input.codeUnits;

  for (final byte in bytes) {
    hash ^= byte;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }

  return hash;
}

