# 🐰 ARNN.APPREM

---

## 👥 Nama Anggota Kelompok

| Nama | NIM |
|---|---|
| Muhammad Rizky Febrianto | 2409116045 |
| Chiqo Nanda Rial Pratama | 2409116046 |
| Daffa Syahrandy Husain | 2409116069 |
| Marcela Persa Linthin| 2409116072 |

---

## 📝 Deskripsi Aplikasi

Aplikasi mobile berbasis **Flutter** dan **Supabase** untuk manajemen penjualan akun premium, pelacakan masa aktif langganan, serta pengelolaan klaim garansi secara end-to-end.
Aplikasi ini dirancang untuk membantu reseller/owner akun premium dalam mengelola transaksi, memantau masa aktif pelanggan, dan memproses klaim garansi secara efisien. Terdapat dua peran utama:

- 👤 **Customer** — dapat mendaftar, melihat katalog produk, melakukan pembelian, memantau status pesanan, dan mengajukan klaim garansi.
- 👑 **Admin** — dapat mengelola produk dan varian, mengkonfirmasi pesanan, memproses klaim garansi, serta memantau laporan keuangan melalui dashboard.

Data disimpan secara real-time di **Supabase** (PostgreSQL), termasuk tabel `users`, `products`, `product_variants`, `orders`, `subscriptions`, `transactions`, dan `claims`.

---

## ✨ Fitur Aplikasi

### 👤 Customer
| Fitur | Keterangan |
|---|---|
| Register & Login | Autentikasi menggunakan Supabase Auth |
| Lihat Katalog Produk | Daftar aplikasi premium beserta harga dan varian |
| Filter Kategori | Filter produk berdasarkan Streaming, Music, Study, Editing |
| Pencarian Produk | Cari produk secara real-time dari database |
| Order Produk | Pilih durasi, isi email akun, upload bukti bayar |
| Cek Status Pesanan | Lihat status pending/approved/expired beserta progress bar |
| Lihat Masa Aktif | Countdown hari tersisa berdasarkan data subscriptions |
| Riwayat Pembelian | Daftar semua order dengan filter status |
| Klaim Garansi | Ajukan klaim dengan pilihan kendala, deskripsi, dan upload screenshot |
| Detail Garansi | Menampilkan detail klaim garansi secara lengkap |
| Edit Profil | Ubah nama, email, nomor WA, dan password |
| Dark Mode | Toggle tema gelap/terang |
| Rules & Terms | Ketentuan sebelum melakukan pembelian |
| Kontak & Sosial Media | Langsung buka WhatsApp, Instagram, X (Twitter) |

### 👑 Admin
| Fitur | Keterangan |
|---|---|
| Dashboard | Statistik total transaksi, pendapatan, pengguna, dan order pending |
| Grafik Pendapatan | Bar chart pendapatan per bulan menggunakan fl_chart |
| Kelola Produk | Tambah, edit, hapus produk beserta upload logo |
| Kelola Varian | Tambah, edit, hapus varian harga dan durasi per produk |
| Filter Kategori Produk | Filter produk berdasarkan kategori di halaman Market |
| Konfirmasi Pesanan | Approve order dengan input email & password akun, atau reject |
| Hitung Laba Otomatis | Profit dihitung otomatis (harga jual − modal) saat approve |
| Buat Subscription Otomatis | Data subscription dibuat otomatis saat order di-approve |
| Kelola Klaim Garansi | Lihat, approve, atau reject klaim garansi dengan catatan admin |
| Monitoring Klaim | Filter klaim berdasarkan status: pending, in progress, approved, rejected |
| Setting Admin | Ganti tema, lihat info aplikasi, logout dengan konfirmasi |

---

## 🧩 Widget yang Digunakan

### Structural Widgets
- `Scaffold`, `SafeArea`, `Column`, `Row`, `Expanded`, `Stack`
- `ListView`, `ListView.builder`, `SingleChildScrollView`, `GridView.count`

### Input & Interaction
- `TextField`, `GestureDetector`, `InkWell`, `RadioListTile`
- `DropdownButtonFormField`, `Switch`, `Slider`

### Display
- `Text`, `Icon`, `Image.network`, `Image.asset`, `Image.memory`
- `CircularProgressIndicator`, `LinearProgressIndicator`
- `ClipRRect`, `AnimatedContainer`, `AnimatedSwitcher`

### Navigation
- `Navigator.pushNamed`, `Navigator.pushReplacementNamed`
- `Navigator.pushNamedAndRemoveUntil`, `Navigator.pop`
- `ModalRoute.of(context)?.settings.arguments` 

### Overlay
- `showDialog`, `AlertDialog`, `Dialog`, `SnackBar`

### Animation
- `AnimationController`, `FadeTransition`, `SlideTransition`
- `ScaleTransition`, `CurvedAnimation`, `Tween`

### Custom Widgets (lib/widgets/)
| Widget | Fungsi |
|---|---|
| `PrimaryButton` | Tombol utama dengan gradient |
| `CustomBottomNavbar` | Navigasi bawah customer (Home, Products, Orders, Profile) |
| `StatusBadge` | Label status berwarna (pending, approved, expired, dll) |
| `PremiumProductTile` | Tile produk di halaman katalog |
| `PremiumOrderCard` | Card order dengan progress bar masa aktif |
| `PlanCard` | Card pemilihan varian/paket |
| `AppCard` | Container card umum dengan warna adaptif |
| `CheckoutItemCard` | Ringkasan produk di halaman checkout |
| `SectionHeader` | Header section dengan tombol "View All" opsional |
| `Space` | Helper jarak vertikal/horizontal konsisten |
| `SearchInput` | Input pencarian reusable |

---

## ➕ Nilai Tambah: Package Tambahan

Berikut package tambahan yang digunakan beserta penjelasannya:

### 1. `image_picker`
Digunakan untuk memilih gambar dari galeri perangkat. Diimplementasikan di:
- **Payment Page** — upload bukti pembayaran
- **Garansi Form Page** — upload screenshot bukti masalah
- **Admin Add Product Page** — upload logo produk

### 2. `url_launcher`
Digunakan untuk membuka URL eksternal dari dalam aplikasi. Diimplementasikan di:
- **Social Page** — membuka WhatsApp, Instagram, dan Twitter/X
- **Order Detail Page** — tombol "Hubungi Support" langsung ke WhatsApp dengan pesan otomatis
- **Rules Page** — tombol hubungi admin langsung dari halaman ketentuan

### 3. `fl_chart`
Digunakan untuk menampilkan grafik batang (bar chart) pendapatan bulanan di **Admin Dashboard**. Fitur yang dimanfaatkan:
- `BarChart` dengan warna gradient per batang
- Tooltip interaktif saat batang disentuh
- Animasi highlight saat batang dipilih


### 4. `provider`
Digunakan sebagai state management untuk fitur **dark/light mode** melalui `ThemeProvider` (extends `ChangeNotifier`). Memungkinkan perubahan tema berdampak ke seluruh halaman secara instan tanpa rebuild manual.

### 5. `intl`
Digunakan untuk:
- **Format mata uang** Rupiah (`NumberFormat.currency`) di Admin Dashboard

---

## 📁 Struktur Folder

```
lib/
├── core/
│   ├── constants.dart 
│   ├── routes.dart 
│   ├── theme.dart
│   └── theme_provider.dart
│
├── features/
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── admin/
│   │   ├── admin_main_page.dart
│   │   ├── admin_dashboard_page.dart
│   │   ├── admin_market_page.dart
│   │   ├── admin_order_page.dart
│   │   ├── admin_order_detail_page.dart
│   │   ├── admin_product_detail_page.dart
│   │   ├── admin_add_product_page.dart
│   │   ├── admin_add_variant_page.dart
│   │   ├── admin_garansi_page.dart
│   │   ├── admin_garansi_detail_page.dart
│   │   └── admin_setting_page.dart
│   └── customer/
│       ├── home_page.dart
│       ├── product_page.dart
│       ├── product_detail_page.dart
│       ├── checkout_page.dart
│       ├── payment_page.dart
│       ├── order_page.dart
│       ├── order_detail_page.dart
│       ├── profile_page.dart
│       ├── edit_profile_page.dart
│       ├── garansi_page.dart
│       ├── garansi_detail_page.dart
│       ├── garansiformpage.dart
│       ├── rules_page.dart
│       └── social_page.dart
│
├── services/
│   ├── auth_service.dart
│   ├── order_service.dart
│   ├── product_service.dart
│   ├── claims_service.dart
│   ├── admin_service.dart
│   └── supabase_service.dart
│
├── widgets/
│   ├── buttons/primary_button.dart
│   ├── inputs/search_input.dart
│   ├── navbar/bottom_navbar.dart
│   ├── shared/
│   │   ├── empty_state.dart
│   │   ├── section_header.dart
│   │   ├── section_title.dart
│   │   ├── spacing.dart
│   │   └── status_badge.dart
│   └── cards/
│       ├── admin_menu_card.dart
│       ├── app_card.dart
│       ├── app_logo.dart
│       ├── checkout_item_card.dart
│       ├── info_item.dart
│       ├── menu_item.dart
│       ├── order_card.dart
│       ├── payment_card.dart
│       ├── plan_card.dart
│       ├── premium_product_tile.dart
│       └── product_card.dart
│
└── main.dart
```

---

## 🗄️ Database (Supabase)

| Tabel | Fungsi |
|---|---|
| `users` | Data akun customer dan admin |
| `products` | Katalog aplikasi premium |
| `product_variants` | Varian harga dan durasi per produk |
| `orders` | Data pesanan customer |
| `subscriptions` | Masa aktif langganan (dibuat otomatis saat approve) |
| `transactions` | Catatan keuangan dan laba (dibuat otomatis saat approve) |
| `claims` | Pengajuan klaim garansi |


---

## 🖼️ Preview Aplikasi
<table>
  <tr>
    <th>Home Page</th>
    <th>Product Page</th>
  </tr>  
  <tr>
    <td><img width="320" height="695" alt="Screenshot 2026-04-20 113445" src="https://github.com/user-attachments/assets/a5435a7e-00d1-41a1-bc38-211c9d882347" /></td>
    <td><img width="320" height="698" alt="Screenshot 2026-04-20 112307" src="https://github.com/user-attachments/assets/85c0c3ce-69fe-4698-b00b-6ecb2bbc54e0" /></td>
  </tr>
  <tr>
    <th>Order Page</th>
    <th>Profile Page</th>
  </tr>  
  <tr>
    <td><img width="321" height="696" alt="Screenshot 2026-04-20 112354" src="https://github.com/user-attachments/assets/f379fde3-75c4-4688-b402-39d58d5238f3" /></td>
    <td><img width="317" height="696" alt="image" src="https://github.com/user-attachments/assets/2fca8679-3661-49b8-9df7-33ef3c3126ca" /></td>
  </tr>
  </table>
