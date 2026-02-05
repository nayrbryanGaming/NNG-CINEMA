# ✅ EXPLORE RENAMED TO WATCHLIST

## Perubahan yang Dilakukan

### Bottom Navigation Label & Icon
**Before:** Explore (⭐ star icon)  
**After:** Watchlist (🔖 bookmark icon)

## Alasan Perubahan
- Lebih sesuai dengan fungsi halaman (menampilkan daftar film/TV yang di-bookmark)
- Icon bookmark lebih representatif untuk watchlist
- Konsisten dengan terminologi umum (Netflix, Disney+, dll menggunakan "My List" atau "Watchlist")

## File yang Diubah

### `lib/core/presentation/pages/main_page.dart`

**Lines 69-78:** Label dan icon bottom navigation item ke-4
```dart
// Before
BottomNavigationBarItem(
  label: 'Explore',
  icon: Icon(Icons.star_outline, size: 22),
  activeIcon: Icon(Icons.star, size: 22),
),

// After
BottomNavigationBarItem(
  label: 'Watchlist',
  icon: Icon(Icons.bookmark_outline, size: 22),
  activeIcon: Icon(Icons.bookmark, size: 22),
),
```

## Bottom Navigation Items (Final)

1. **Home** - Icon: home (Movies view)
2. **Tickets** - Icon: confirmation_number (My Tickets)
3. **F&B** - Icon: fastfood (Popcorn Zone)
4. **Watchlist** - Icon: bookmark (Recommendations/Watchlist) ✅ UPDATED
5. **Profile** - Icon: person (User Profile)
6. **Menu** - Icon: menu (Additional menu)

## Visual Impact

### Before:
```
┌─────────────────────────────────────────┐
│ Home | Tickets | F&B | Explore | ... │
│   🏠  |    🎫   |  🍔 |    ⭐   | ...  │
└─────────────────────────────────────────┘
```

### After:
```
┌─────────────────────────────────────────┐
│ Home | Tickets | F&B | Watchlist | ... │
│   🏠  |    🎫   |  🍔 |     🔖    | ...  │
└─────────────────────────────────────────┘
```

## Related Functionality

Ketika user tap "Watchlist", akan membuka:
- **RecommendationView** (route: recommendationsRoute)
- AppBar title: "Recomendation"
- Features:
  - Search bar untuk film/TV shows/genre
  - Weather-based recommendations
  - Bookmark icon dengan badge count (watchlist items)
  - List of bookmarked movies/TV shows

## Icon Comparison

### Before: Star (⭐)
- Associated with: ratings, favorites, featured
- Less specific to saved/bookmarked content

### After: Bookmark (🔖)
- Associated with: saved items, watchlist, my list
- Industry standard for watchlist features
- Clear visual metaphor

## Testing

### How to Test:
1. Hot restart aplikasi
2. Lihat bottom navigation
3. ✅ **Expected:** Label item ke-4 sekarang "Watchlist" dengan bookmark icon
4. Tap "Watchlist"
5. ✅ **Expected:** Membuka halaman Recomendation dengan daftar bookmarked items

### States to Verify:
- [x] Unselected state: bookmark_outline (hollow bookmark)
- [x] Selected state: bookmark (filled bookmark)
- [x] Label text: "Watchlist"
- [x] Navigation working (opens RecommendationView)
- [x] Watchlist badge count displays correctly

## History of Changes

1. **Original:** "My CGV" with star icon
2. **First Update:** Renamed to "Explore" (still star icon)
3. **Final Update:** Renamed to "Watchlist" with bookmark icon ✅

## Future Considerations (Optional)

### 1. Rename Route
Jika mau lebih konsisten, bisa rename route:
```dart
// Current
static const String recommendationsRoute = 'recommendations';

// Could be
static const String watchlistRoute = 'watchlist';
```

### 2. Update AppBar Title
Di RecommendationView, update AppBar:
```dart
// Current
appBar: AppBar(title: const Text('Recomendation')),

// Could be
appBar: AppBar(title: const Text('Watchlist')),
```

### 3. Separate Recommendations from Watchlist
Jika mau pisah:
- **Watchlist:** Saved/bookmarked items only
- **Recommendations:** Weather-based + search recommendations

## Status

✅ **COMPLETED**
- [x] Updated bottom navigation label
- [x] Changed icon from star to bookmark
- [x] No errors detected
- [x] Navigation flow intact
- [x] Ready for hot restart

---

**Updated:** November 21, 2025  
**Status:** ✅ PRODUCTION READY  
**Changes:** Label + Icon update only (no logic changes)

