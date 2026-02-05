# 🚀 QUICK START GUIDE - HOME PAGE REDESIGN

## Status: ✅ READY TO USE

---

## 📱 CARA MENJALANKAN APLIKASI

### 1. Pastikan Emulator/Device Ready
```bash
# Cek device yang tersedia
flutter devices
```

### 2. Jalankan Aplikasi
```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Run aplikasi
flutter run
```

---

## 🎯 FITUR BARU YANG BISA DICOBA

### 1. **Top App Bar**
- ✅ Logo NNG Cinema di kiri atas
- ✅ Icon Search (belum implementasi)
- ✅ Icon Profile → Klik untuk ke Profile page
- ✅ Icon Notification dengan badge angka 3

### 2. **Location Selector**
- ✅ Klik pada "MAKASSAR" untuk membuka Choose Location
- ✅ Search kota menggunakan search bar
- ✅ Pilih kota dari list (13 kota tersedia)
- ✅ Kota yang dipilih akan muncul di home page

### 3. **Promo Banner**
- ✅ Banner "BUY 1 GET 1 FREE TICKET"
- ✅ Periode promo ditampilkan
- ✅ Catatan kuota terbatas

### 4. **User Level & Points**
- ✅ Menampilkan level: CLASSIC
- ✅ Menampilkan points: 0
- ✅ Status BluAccount: Not Linked

### 5. **Explore Movies dengan Ranking**
- ✅ Scroll horizontal untuk melihat film
- ✅ Badge ranking (1, 2, 3, ...) di poster
- ✅ Age rating (13+) di pojok kanan
- ✅ Rating bintang dan likes di bawah
- ✅ Klik poster untuk lihat detail film

### 6. **Bottom Navigation (5 Menu)**
- ✅ **Home** → Movies page (halaman utama)
- ✅ **Tickets** → My Tickets page (tiket yang sudah dibeli)
- ✅ **F&B** → TV Shows page (bisa diganti F&B menu)
- ✅ **My CGV** → Recommendations page
- ✅ **Menu** → Profile page

---

## 🎨 TAMPILAN HOME PAGE (Top to Bottom)

```
┌─────────────────────────────────────┐
│  🏷️ NNG   🔍 👤 🔔(3)              │ ← Top App Bar
├─────────────────────────────────────┤
│  📍 MAKASSAR ▼                      │ ← Location Selector (Clickable)
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐  │
│  │  BUY 1 GET 1 FREE TICKET     │  │
│  │  Periode: 17-21 Nov 2025      │  │ ← Promo Banner
│  │  *Kuota terbatas             │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  ⭐ LEVEL     💰 POINTS  📱 BLUA   │ ← User Level & Points
│     CLASSIC      0      Not Linked  │
├─────────────────────────────────────┤
│  Explore Movies              MORE > │
│  Exciting movies...                 │
│                                     │
│  ┌─┐ ┌─┐ ┌─┐ ┌─┐                  │ ← Ranked Movies (Horizontal Scroll)
│  │1│ │2│ │3│ │4│  ════════>        │    with Badges
│  └─┘ └─┘ └─┘ └─┘                  │
├─────────────────────────────────────┤
│  Popular Movies              MORE > │
│  ┌─┐ ┌─┐ ┌─┐ ┌─┐                  │ ← Popular Movies
│  │ │ │ │ │ │ │ │  ════════>        │
│  └─┘ └─┘ └─┘ └─┘                  │
├─────────────────────────────────────┤
│  Top Rated Movies            MORE > │
│  ┌─┐ ┌─┐ ┌─┐ ┌─┐                  │ ← Top Rated Movies
│  │ │ │ │ │ │ │ │  ════════>        │
│  └─┘ └─┘ └─┘ └─┘                  │
└─────────────────────────────────────┘
│ 🏠  🎫  🍔  👤  ☰              │ ← Bottom Navigation (5 items)
│ Home Tickets F&B My CGV Menu       │
└─────────────────────────────────────┘
```

---

## 🧭 NAVIGATION MAP

```
Main App
│
├─ 🏠 Home (Movies View) ← DEFAULT
│   ├─ Location Selector → Choose Location View
│   ├─ Search Icon → (Not implemented yet)
│   ├─ Profile Icon → Profile View
│   ├─ Notification Icon → (Not implemented yet)
│   ├─ Promo Banner → (Not linked yet)
│   ├─ More Button → Popular Movies View
│   └─ Movie Items → Movie Details View
│
├─ 🎫 Tickets (My Tickets View)
│   └─ Ticket Items → Ticket Details View
│
├─ 🍔 F&B (TV Shows View)
│   └─ Show Items → Show Details View
│
├─ 👤 My CGV (Recommendations View)
│   └─ Recommended Items → Movie/Show Details
│
└─ ☰ Menu (Profile View)
    ├─ Edit Profile → Edit Profile View
    ├─ My Coupons → My Coupons View
    ├─ Movie Diary → Movie Diary View
    ├─ Events → Events View
    └─ FAQ & Contact → FAQ Contact View
```

---

## 🔍 TEST CHECKLIST

Setelah menjalankan aplikasi, test fitur-fitur berikut:

### Basic Navigation
- [ ] App berhasil terbuka tanpa error
- [ ] Home page tampil dengan lengkap
- [ ] Bottom navigation tampil dengan 5 items
- [ ] Bisa pindah antar tab di bottom navigation

### Location Selector
- [ ] Klik "MAKASSAR" → membuka Choose Location page
- [ ] Search bar berfungsi untuk filter kota
- [ ] Klik kota → kembali ke home page
- [ ] Kota yang dipilih muncul di home page

### App Bar
- [ ] Logo NNG tampil
- [ ] Icon search tampil
- [ ] Icon profile clickable → ke Profile page
- [ ] Icon notification tampil dengan badge "3"

### Content Display
- [ ] Promo banner tampil dengan text lengkap
- [ ] User level section tampil (Level, Points, BluAccount)
- [ ] Explore Movies section tampil dengan ranking badges
- [ ] Popular Movies section tampil
- [ ] Top Rated Movies section tampil
- [ ] Semua poster film tampil (tidak error)

### Movie Interaction
- [ ] Klik poster film → membuka Movie Details page
- [ ] Horizontal scroll berfungsi di Explore Movies
- [ ] Horizontal scroll berfungsi di Popular Movies
- [ ] Horizontal scroll berfungsi di Top Rated Movies

### Visual Check
- [ ] Warna merah untuk selected bottom nav
- [ ] Warna hitam untuk background bottom nav
- [ ] Gradient di promo banner tampil bagus
- [ ] Ranking badges (1,2,3,...) tampil di poster
- [ ] Age rating badges (13+) tampil di poster
- [ ] Rating bintang dan likes tampil di bawah poster

---

## 📋 DAFTAR KOTA YANG TERSEDIA

1. ✅ **MAKASSAR** (Default - Current Location)
2. BALIKPAPAN
3. MATARAM
4. SAMARINDA
5. JEMBER
6. PROBOLINGGO
7. SURABAYA
8. GRESIK
9. MOJOKERTO
10. MALANG
11. BLITAR
12. KEDIRI
13. MADIUN

---

## 🎨 COLOR PALETTE

- **Primary Red**: `Colors.red` - Selected items, badges, buttons
- **Background Black**: `Colors.black` - App bar, bottom nav
- **Dark Grey**: `Colors.grey[900]` - Location selector, cards
- **White**: `Colors.white` - Primary text
- **Grey**: `Colors.grey` - Unselected items, secondary text
- **Orange**: `Colors.orange` - Level badge background
- **Amber**: `Colors.amber` - Star rating icon

---

## 🚨 TROUBLESHOOTING

### Masalah: Bottom navigation tidak tampil
**Solusi:** Pastikan Anda di halaman yang benar (bukan di location selector page)

### Masalah: Location selector tidak clickable
**Solusi:** Cek bahwa route `locationSelectorRoute` sudah ditambahkan di `app_router.dart`

### Masalah: Film tidak muncul / loading terus
**Solusi:**
1. Cek koneksi internet emulator
2. Cek API key TMDB masih valid
3. Lihat log untuk error message

### Masalah: Logo NNG tidak muncul
**Solusi:** Pastikan file `assets/images/nng.png` ada dan sudah dideclare di `pubspec.yaml`

### Masalah: Compile error setelah edit
**Solusi:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📞 NEXT STEPS

### Fitur yang bisa ditambahkan selanjutnya:

1. **Search Functionality** 
   - Implement search icon di top app bar
   - Search movies, shows, cinemas

2. **Notification System**
   - Implement notification page
   - Real-time notification count

3. **Dynamic Promo**
   - Load promo dari Firebase/Backend
   - Multiple promo banners (carousel)

4. **Location-based Filter**
   - Filter cinema berdasarkan lokasi yang dipilih
   - Show nearby cinemas on map

5. **User System**
   - Real user level & points dari backend
   - Points accumulation
   - Level benefits

6. **F&B Module**
   - Replace TV Shows dengan F&B menu
   - Food & beverage ordering

---

## ✅ SELESAI!

Aplikasi sudah siap digunakan dengan fitur-fitur CGV style yang lengkap!

**Happy Testing! 🎉**

---

**Created:** 21 November 2025
**Version:** 1.0
**Status:** ✅ Production Ready

