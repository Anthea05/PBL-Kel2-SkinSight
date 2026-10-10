# PRD SkinSight — Design System & UI/UX Specification

> **Versi:** 1.1.0+2 | **Platform:** Flutter (>=3.3.0) | **Tanggal:** 10 Okt 2026
> **Tim:** PBL Kelompok 2 | **Audiens:** Semua stakeholder (dosen, developer, desainer)
> **Bahasa:** Bahasa Indonesia | **Mode:** Light-mode only | **Scope:** Design System + UI/UX
> **Sumber kebenaran kode:** `lib/theme/app_tokens.dart`, `lib/pages/*`, `lib/data/quiz_scoring.dart`, `pubspec.yaml`

---

## 1. Konteks Produk (1 halaman)

### 1.1 Masalah & tujuan
Pengguna Indonesia kesulitan menilai kondisi kulitnya secara objektif (minyak, pori, jerawat, kemerahan, hidrasi) dan memilih perawatan yang tepat. **SkinSight** adalah prototype Flutter untuk skrining kondisi kulit yang ramah: onboarding hangat → quiz 5 langkah → scan kamera/galeri → hasil skor + metrik → riwayat.

Bukan alat diagnosis medis. Output berupa **skor 45–96 + tipe kulit** (`Normal`, `Kombinasi (T-Zone)`, `Cenderung Berminyak/Kering`, `Sensitif Ringan`, `Rentan Berjerawat`) + judul kondisi (`Breakout aktif`, `Kemerahan ringan`, dst).

### 1.2 Persona primer
1. **Alea (19–28 th, mahasiswa/karyawan awal)** — peduli skincare, aktif di luar 30 mnt–3 jam, ingin tahu tipe kulit tanpa ke klinik. Butuh bahasa sederhana, visual menenangkan, hasil bisa disimpan.
2. **Dosen penguji PBL** — menilai kelengkapan alur, konsistensi UI, dan keterbacaan dokumentasi.
3. **Developer/desainer penerus** — butuh token siap pakai, anatomi screen jelas, dan aturan kapan boleh menyimpang.

### 1.3 Job-to-be-done & success metric
- JTBD: "Kenali kondisi kulitmu untuk perawatan yang tepat" (copy eksisting di Start Page).
- Success: pengguna menyelesaikan Quiz → Scan → Result dalam < 3 menit tanpa error navigasi; skor tersimpan ke History; tidak ada scroll berlebih di HP kecil.

### 1.4 Ruang lingkup v1.1 (dikunci)
Masuk: Start, Login/Register (dummy), Home, Quiz 5 soal, Scan (kamera depan + galeri), Result, History (filter tanggal + sort), Help/FAQ, Profile.
Tidak masuk: dark mode, backend nyata (saat ini `SkinHistoryRepository` in-memory + delay 160–220 ms), ML on-device, checkout/commerce, multi-bahasa.

---

## 2. Prinsip Desain (Hybrid — jawaban C)

Dipilih **Hybrid**: profesional-tenang untuk area klinis, playful-hangat untuk area emosional. Ini sesuai temuan kode: komentar `AppTokens` menyebut "professional, not bubbly", tetapi aset memakai `cat_happy`, `bubbles`, `sparkles`.

| Zona | Screen | Ciri |
|------|--------|------|
| **Klinis** | Scan, Result, History | Tenang/presisi: putih + `pageBg`, kartu border tipis, 1 aksen metrik per bar, **tanpa sticker apapun** (termasuk sparkles/bubbles/kucing) |
| **Hangat** | Start, Login, Home hero, Help | Ramah: gradien pastel + 1 ilustrasi hero + maks 1 sticker opsional |
| **Fungsional-netral** | Quiz | Bersih tanpa ilustrasi hero/sticker; fokus keterbacaan opsi + progress |
| **Hangat-netral** | Profile | Gradien pastel + avatar; tanpa sticker; badge Demo untuk data dummy |

> Klarifikasi: "tanpa sticker" di zona klinis berarti nol sticker. Pengecualian tidak ada. §8.1 ("hapus sparkles/bubbles dari Result/Scan") mencakup History juga.

**Aturan anti AI-slop (wajib):**
1. Satu screen = satu signature element saja. Signature SkinSight adalah **cincin skor + bar metrik klinis** — bukan gradien ungu-biru generik, bukan cream + serif + terracotta, bukan dark + acid-green.
2. Jangan campur >2 metafora dalam satu screen (mis. foto realistis + sticker kucing + bubbles + sparkles sekaligus).
3. Copy spesifik, aktif, sentence case: "Ambil foto", bukan "Submit". Error menjelaskan sebab + aksi: "Izin kamera ditolak — aktifkan di Pengaturan atau pilih dari galeri".
4. Motion hemat: transisi 150–250 ms, hormati `reduced motion`. Satu momen orkestrasi (mis. animasi skor) lebih baik daripada banyak efek tersebar.
5. Referensi yang diadaptasi (bukan dicopy): TroveSkin (coach + diary + progress), L'Oréal Skin Genius (background terang agar warna kulit akurat), YouCam (overlay wajah stabil), pola Dribbble "DIOR Skincare" (light airy, spacing rapat untuk katalog). Lihat §8.

---

## 3. Fondasi: Warna (dipertahankan per-page, `AppTokens` sebagai acuan)

> Keputusan stakeholder #2: **pertahankan varian per-page apa adanya (freeze-tambah, bukan freeze-merge)**. `AppTokens` adalah acuan utama untuk komponen baru. Varian di bawah adalah legal hingga snapshot PBL selesai; merge/unifikasi hanya boleh setelah itu (lihat §8.7). Dilarang menambah hex hardcode baru (lihat §9.3).
> Konvensi hex: semua warna opaque. `#RRGGBB` = `#FFRRGGBB` = `Color(0xFFRRGGBB)`. Tabel di bawah memakai format 8-digit ARGB agar copy-paste ke Dart.

### 3.1 Token inti (`AppTokens`)

| Token | Hex ARGB | `Color()` | Peran |
|-------|----------|-----------|-------|
| `teal` | `#FF168A78` | `Color(0xFF168A78)` | Primary, CTA, ikon aktif, progress fill, metrik pori (kanonis) |
| `deepTeal` | `#FF087467` | `Color(0xFF087467)` | Primary-dark, teks tombol, tab aktif, shadow tint |
| `navy` | `#FF13263A` | `Color(0xFF13263A)` | Teks judul/body |
| `cream` | `#FFFFF8EB` | `Color(0xFFFFF8EB)` | Surface hangat (hero, footer gradien) |
| `pageBg` | `#FFF4F6F6` | `Color(0xFFF4F6F6)` | Background klinis default |
| `cardBorder` | `#FFE2E9E7` | `Color(0xFFE2E9E7)` | Border kartu/input |
| `muted` | `#FF6B7E89` | `Color(0xFF6B7E89)` | Teks sekunder/caption (kanonis; varian lain di §3.2 adalah alias) |
| `coral` | `#FFFF6B70` | `Color(0xFFFF6B70)` | Danger + kanonis metrik Kemerahan & Jerawat |
| `orange` | `#FFFFB43B` | `Color(0xFFFFB43B)` | Warning + kanonis metrik Minyak |
| `sky` | `#FF35A9EE` | `Color(0xFF35A9EE)` | Info + kanonis metrik Hidrasi |

### 3.2 Varian legal per-page (jangan dihapus tanpa diskusi)

| Varian | Hex | Dipakai di | Aturan pakai |
|--------|-----|------------|--------------|
| `_deepTeal` gelap | `#FF064E48` | Start, Login | Hanya untuk teks brand di atas background terang `#FFF7FBF7`. Alias, bukan token baru. |
| `_teal` login | `#FF168F7C` | Login | Alias `teal`, boleh migrasi ke `AppTokens.teal` saat senggang |
| `_navy` login | `#FF142D35` | Login | Judul login saja (alias navy) |
| `_muted` login | `#FF73898B` | Login | Label form login saja (alias muted) |
| `_muted` start | `#FF8BA7A2` | Start | Subtitle start saja (alias muted) |
| `_sky` cerah | `#FF2FC1ED` | Help, Profile | Top gradien `[#FF2FC1ED → #FFE9F8F3/#FFE6F7F3 → cream]`, stop 0 / .28–.30 / 1. Alias sky. |
| `_sky` ilustrasi | `#FF36A7E8` | Help topic icon | 1 ikon topik saja (alias sky) |
| `_coral` result | `#FFFF6674` | Result | Alias coral (kanonis tetap `#FFFF6B70`) |
| `_coral` profil | `#FFE6535F` | Profile logout | Border + teks logout (alias coral, khusus logout) |
| `_coral` home | `#FFFF5C63` | Home badge | Badge peringatan saja (alias coral) |
| `_orange` result | `#FFFFAB26` | Result | Alias orange (kanonis tetap `#FFFFB43B`) |
| `_cream` scan | `#FFFFFBF2` | Scan | Background scan |
| `_cream` history | `#FFFFFAF1` | History | Ujung gradien history |
| Google blue | `#FF4285F4` | Login | Logo "G" saja, jangan untuk CTA lain |
| Ungu topik | `#FF9B75D6` | Help | 1 ikon topik saja |
| divider | `#FFE4E8E7`, `#FFD7E4E1`, `#FFDCEBE7`, `#FFD8E7E3`, `#FFE8ECEC`, `#FFE7ECEC`, `#FFDCEDEA`, `#FFE5EBEA` | Berbagai list | Pilih 1 per screen, jangan campur 3 divider dalam 1 list |
| teks sekunder skala | `#FF718392`, `#FF6C7F8D`, `#FF6A7F8B`, `#FF78878A`, `#FF819093`, `#FF6F8085`, `#FF829194`, `#FF526E78`, `#FF5B737C`, `#FF6D808A`, `#FF9AAAB6`, `#FF65798C`, `#FF559B92` | Caption/meta | Alias `muted`. Klaim kontras: wajib uji manual min 4.5:1 untuk body dan 3:1 untuk large text; teks ≤12sp dilarang di atas pastel (sky/mint) tanpa uji. Lihat checklist §9.3. |
| surface sukses | `#FFE3F4F0`, `#FFE1F5EF`, `#FFE6F4EF`, `#FFDDF6E7`, `#FFE2F4EF`, `#FFE5F7F2`, `#FFF0FBF8`, `#FFE9F7F4`, `#FFE1F7F5` | Badge/selected state | Latar badge sukses / jawaban quiz terpilih |
| gradien klinis | `#FFDDF5FF → cream → #FFFFFBF3` | Result | top → mid (.23) → bottom |
| gradien home | `#FFE3F4F0 → cream` | Home hero | — |
| gradien history | `#FFE1F7F5 → cream → #FFF2FAF5` | History header | — |
| CTA gradien | `#FF55C69E → #168A78` | Home scan CTA | Hanya 1 CTA primer per screen |

### 3.3 Aturan pemakaian warna (kanonis vs alias)
- CTA primer selalu `deepTeal #FF087467` (teks putih) atau gradien CTA; jangan pakai sky/coral untuk CTA utama.
- Satu metrik = satu warna kanonis (jangan tukar antar screen):
  - Kemerahan: `#FFFF6B70` (alias terdokumentasi `#FFFF6470` hanya di Home `_Metric`, akan dimigrasi post-PBL)
  - Minyak: `#FFFFB43B` (alias `#FFFFB131` hanya di Home, migrasi post-PBL)
  - Hidrasi: `#FF35A9EE` (alias `#FF2DA6F2` hanya di Home, migrasi post-PBL)
  - Pori: `teal #FF168A78`
  - Jerawat: `coral #FFFF6B70`
- Teks di atas warna: putih di atas `deepTeal/teal` lolos; `muted` hanya untuk ≥12sp di atas putih/krem, bukan di atas sky tanpa uji kontras.
- Light-only: tidak ada token dark. Jangan meniru dark-mode dengan menumpuk hitam transparan.

---

## 4. Tipografi, Spacing, Bentuk, Elevasi

### 4.1 Tipografi — dikunci ke Plus Jakarta Sans (jawaban 3A)
Dependensi `google_fonts` sudah ada tetapi belum dipakai. Migrasi wajib ke **Plus Jakarta Sans** (geometris modern, x-height tinggi, cocok Bahasa Indonesia, desainer Tokotype). Fallback: sistem sans.

Skala (dari kode, dipertahankan + tambahan display untuk hero):

| Role | Size / Weight / Height | Pakai untuk |
|------|------------------------|-------------|
| Display | 28–32 / 800 / 1.15 | Angka skor besar, hero Start/Home |
| H1 | 24 / 800 / 1.15 (`AppTokens.h1`) | Judul screen |
| H2 | 20 / 800 / 1.2 (`AppTokens.h2`) | Judul section |
| Title | 16 / 700 | Judul kartu, nama pengguna |
| Body | 14 / 400–500 / 1.4 | Paragraf, opsi quiz |
| Caption | 12 / 400–500 / 1.35, `muted` | Meta, timestamp, helper |
| Button | 16–18 / 800 | Label CTA |
| Overline/eyebrow | 11–12 / 700, tracking +0.5, uppercase, teal | Label kecil ("LANGKAH 2 DARI 5", "HASIL ANALISIS") |

Aturan: sentence case untuk semua label Indonesia; jangan uppercase paragraf; batasi 1–2 baris judul kartu; angka metrik tabular (fontFeature `tnum`) agar tidak goyang.

Snippet migrasi (lampiran §9): `GoogleFonts.plusJakartaSansTextTheme()` + `ThemeExtension` untuk token.

### 4.2 Spacing, radius, elevasi, layout
- Spacing: `4/8/12/16/20` (eksisting) + `24/28` untuk antar-section. Padding horizontal: `16` standar, `14` saat compact, `18–20` untuk hero.
- Radius: `r12` input/chip, `r16` kartu (default `AppTokens.card`), `r20` hero/modal. Jangan >24 kecuali sticker lingkaran. Komentar kode "professional, not bubbly" tetap berlaku untuk zona klinis.
- Shadow kartu: `deepTeal 7% , blur 14, offset (0,6)`, border 1 `cardBorder`, bg putih. Di atas gradien pastel, shadow boleh dimatikan agar tidak kotor.
- Layout responsif (jawaban #5 — responsif sesuai device): konten tengah `maxWidth: 520`, `compact = width < 350` → kecilkan `hPad` dan font hero 1–2sp, `SingleChildScrollView/CustomScrollView` + `ClampingScrollPhysics` + `SafeArea`. Target: 360×640 lolos tanpa overflow; <350 tetap bisa scroll; tablet/web center-column, bukan stretch penuh.

---

## 5. Ikonografi, Ilustrasi, Brand

### 5.1 Ikon
Material rounded, outline untuk nav, filled untuk status. Ukuran 20 (list), 22–24 (nav/CTA), 25 (khusus history icon eksisting). Aktif `deepTeal`, nonaktif `#78878A`. Selalu sertakan label teks di BottomNav (jangan ikon saja).

### 5.2 Ilustrasi & aset (14 PNG eksisting — terkunci dari `lib/assets/images/`)
`skin_girl`, `skin_magnifier`, `skin_analyze_title`, `cat_happy`, `city_background`, `clouds`, `bubbles`, `leaves_flowers`, `sparkles`, `hero_decor`, `try_now_sticker`, `description_sticker`, `start_avatar`, `start_background`.

Aturan profesional (jawaban #6):
- 1 screen = maks 1 ilustrasi hero + 1 sticker opsional (zona hangat/fungsional). Zona klinis (Scan, Result, History) = 0 sticker.
- `city_background/start_background` hanya untuk Start/Login (top, `BoxFit.cover`, overlay konten terbaca).
- Semua aset harus punya `semanticLabel` (alt-text) untuk screen reader; kompres <200 KB per file; sediakan `@2x/@3x` bila blur di device padat.
- Jangan upscale ilustrasi kecil menjadi hero besar (pecah = terlihat AI-slop). Jika butuh, pakai gradien + pola halus, bukan tambah sticker.

### 5.3 Logo
Pakai logo eksisting (jawaban #9): wordmark teal di atas krem/putih, lockup `skin_analyze_title.png` untuk header analisis. Clear space = tinggi huruf "S"; ukuran min 24 px digital; jangan di atas foto ramai tanpa scrim; jangan ubah hue ke sky/coral.

---

## 6. Komponen UI (spesifikasi siap dev)

> Konvensi hex §6–7: semua kode 6-digit (`#DCEBE7`) dibaca opaque — tambah `FF` di depan saat ke Dart (`Color(0xFFDCEBE7)`). Kode 8-digit sudah ARGB penuh.

### 6.1 Button
- **Primary:** bg `deepTeal`, teks putih 16/800, tinggi 52–56, radius 16, min width 160, state loading → spinner putih + label tetap (jangan geser layout). Contoh: "Mulai Analisis", "Ambil Foto", "Simpan Hasil".
- **Secondary outline:** bg putih, border `#D8E7E3`, teks `deepTeal`. Contoh: "Pilih dari Galeri".
- **Google:** bg putih, border `#D8E7E3`, ikon "G" `#4285F4`, teks navy 16/800.
- **Danger outline (logout):** border `#E7A5AA`, teks `#E6535F`, bg `#FFF2F2` saat pressed.
- Touch target min 44×44, fokus keyboard visible (outline teal 2px).

### 6.2 Card & list
`AppTokens.card(radius: r16)`: putih, border 1, radius 16, padding 14–16, shadow di atas. Judul 16/700 navy + caption 12 muted + chevron kanan bila bisa diklik. Divider 1px (pilih 1 token per screen). Jangan lebih dari 2 level nesting kartu.

### 6.3 Input & form (Login/Profile)
`TextField`: radius 12–14, border `#DCEBE7`, focus `teal`, error `coral` + pesan 12sp di bawah. Label 14/600 navy, hint `muted`. Password ada eye-toggle. Validasi inline Bahasa Indonesia. Keyboard type sesuai (email, phone, text).

### 6.4 BottomNav (pill floating)
Container putih radius 20–24, shadow lembut, margin `16/8/16/12`. 4 item: Home, History (`open-history`), Bantuan, Profil. Ikon + label 11–12sp. Aktif `deepTeal` + dot/pill kecil; nonaktif `#78878A`. Key widget untuk testing dipertahankan (`Key('open-history')`).

### 6.5 Quiz (5 langkah)
Header: eyebrow "LANGKAH n DARI 5" + progress bar (track `#E2E9E7`, fill teal, tinggi 6–8, radius penuh) + tombol Back. Opsi jawaban: kartu putih radius 16, border `#DCE4E9`; selected → bg `#F0FBF8`, border teal, radio teal terisi; unselected → radio outline `#9AAAB6`. Judul opsi 14–15/700 navy + deskripsi 12–13 muted (`#65798C`). CTA "Lanjut" disabled sampai opsi dipilih; langkah terakhir "Lihat Hasil" → Scan. State `_answers = [0,null,null,null,null]` dipertahankan (Q0 prefill) — dokumentasikan di Help agar tidak dianggap bug.

### 6.6 Scan
Frame kamera rounded 20, overlay oval wajah + garis bantu, tombol shutter 68 bulat teal + tombol flip + tombol galeri. Mode otomatis/manual (`_automaticMode`). Error permission: ilustrasi kecil + teks + 2 CTA ("Buka Pengaturan", "Pilih dari Galeri"). Selama `_isCapturing`, kunci tombol ganda. Lifecycle: dispose saat inactive, init ulang saat resumed (kode eksisting sudah benar).

### 6.7 Result & metrik
Header gradien + tombol back + badge tanggal. Kartu skor: angka display 32/800 navy + cincin progress teal + label tipe kulit + judul kondisi. Bar metrik (0–100): track `#E4E8E7/#E7ECEC`, fill sesuai §3.3, label 13/700 + nilai tabular. Rekomendasi: list 3–4 kartu ringkas (jangan paragraf panjang). CTA: "Simpan" (primary), "Scan Ulang" (secondary), "Lihat Riwayat" (text). Background painter (`_ResultBackgroundPainter`) halus, jangan menimpa teks.

### 6.8 History, Help, Profile
- **History:** header gradien + search tanggal (`showDatePicker` 2024–2030, helpText "Pilih tanggal scan") + toggle sort Terbaru/Terlama + chip tanggal aktif + kartu riwayat (skor, judul, tanggal jam, mini bar). Empty: ilustrasi + "Belum ada scan" + CTA "Mulai Scan". Key `history-scroll` dipertahankan.
- **Help:** header + `_WelcomeCard` + `_HelpTopicsPanel` (expansion tile, iconColor `#718392`, divider `#E8ECEC`), topik: cara scan, pencahayaan, privasi foto, arti skor, hubungi, **catatan "Q0 terisi awal (prefill) — bukan bug"** (lihat §6.5 `_answers = [0,null,null,null,null]`). CTA bawah "Mulai Quiz" → `SkinQuizPage`.
- **Profile:** header avatar (initial/foto, bg `#E2F4EF`) + nama 16–18/800 + kontak 13 (`#5B737C`) + field nama/telepon/email (editable via `ProfileData` Provider) + foto (`ImagePicker`) + tombol Keluar (danger outline). Default dummy `Alea Kucing / +62 812-3456-7890 / alea.kucing@email.com` diberi badge "Demo" agar jelas bukan data nyata.

---

## 7. IA, Route & User Flow

### 7.1 Peta screen (eksisting, dikunci — jawaban #7 revisi, bukan rombak)
> Total **9 screen = 7 named routes di `main.dart` + 2 via push (quiz & scan)**.

| # | Route / cara buka | Screen | Akses dari |
|---|-------------------|--------|------------|
| 1 | `/` (named) | `SkinStartPage` | launch |
| 2 | `/login` (named) | `SkinLoginPage` | Start "Masuk" |
| 3 | `/home` (named) | `SkinHomePage` | Login sukses, Start "Coba" |
| 4 | push | `SkinQuizPage` | Home "Mulai Analisis", Help, History empty |
| 5 | push | `SkinScanPage` (`enableCamera`, `quizAnswers`) | Quiz selesai, Home "Scan" |
| 6 | `/result` (named) | `SkinResultPage` (`analysis`, `selfieBytes`, `archived`) | Scan sukses |
| 7 | `/history` (named) | `SkinHistoryPage` | Home kartu, BottomNav, Result |
| 8 | `/help` (named) | `SkinHelpPage` | BottomNav |
| 9 | `/profile` (named) | `SkinProfilePage` | BottomNav |

BottomNav selalu 4: Home, History, Bantuan, Profil. Back behavior Android: back dari Result → Scan (konfirmasi "Buang hasil?"), back dari tab → Home, bukan keluar app.

### 7.2 Flow utama (happy path)
`Start (brand + hero + CTA) → Login (atau lewati via Coba) → Home (hero + kartu Scan + kartu History + aktivitas terakhir) → Quiz 5/5 → Scan (izin → frame → capture) → Result (skor + metrik + simpan) → History (item baru di atas)`.

Alt flow: Home → Scan langsung (pakai skor default `saveLatest`: 82/Kombinasi) → Result; History → klik item (`archived=true`) → Result read-only; Help/Profile → Quiz.

### 7.3 Anatomi per screen (ringkas, siap QA)

**Start:** bg `#F7FBF7` + `start_background.png` top; brand teal gelap; judul journey 22–24/800; subtitle muted 2 baris; avatar/hero; CTA primer "Mulai" + sekunder "Masuk"; footer kecil privasi. Key `start-scroll`.

**Login:** form `GlobalKey`, prefill demo `alea@skinsight.id / skinsight123` (beri label Demo); mode login/register toggle (`_registerMode`, field nama hanya saat register); tombol "Masuk" → `pushNamedAndRemoveUntil('/home')`; divider "atau" + Google; scroll ke 0 saat toggle (220 ms). Validasi: email format, password ≥8.

**Home (1029 baris, paling kompleks):** hero gradien + ilustrasi + sapaan + CTA "Scan Sekarang" (gradien `#55C69E→teal`); section "Aktivitas" + `_ScanCard` + `_HistoryCard` (klik → `/history`); strip metrik terakhir (Kemerahan coral, Minyak orange, Hidrasi sky); riwayat mini 7 item (`fetchLatest`). Jangan tambah kartu ke-4 tanpa menghapus 1 — jaga tanpa scroll berlebih di 640px.

**Quiz:** 5 soal Bahasa Indonesia (Q0 pagi, Q1 sensitivitas, Q2 pori, Q3 prioritas, Q4 matahari). Opsi 4 each (lihat §6.5). Navigasi depan/belakang menyimpan jawaban; skor via `scoreQuiz()` deterministik di `lib/data/quiz_scoring.dart`:
```
oil = [65,85,25,45][Q0] (+5 jika Q3==0)
redness = [20,35,55,70][Q1] (+4 jika Q3==1) (+2*Q4)
pores = [25,45,60,75][Q2]
hydration = [70,60,45,82][Q0] (-8 jika Q3==2) (-2*Q4)
acne = {Q3==0:62, Q3==1:35, Q3==2:25, else:30}
clamp oil/pores/acne/redness 5..95, hydration 30..95
penalty = max(0,oil-60)*0.4 + max(0,pores-40)*0.3 + acne*0.15 + redness*0.12 + clamp(80-hydration,0,40)*0.2 + Q4*1.0
score = clamp(round(95-penalty), 45, 96)
tipe = acne>=60 ? 'Rentan Berjerawat' : redness>=55 ? 'Sensitif Ringan' : ['Kombinasi (T-Zone)','Cenderung Berminyak','Cenderung Kering','Normal'][Q0]
```

**Scan:** izin kamera → preview → (otomatis/manual) → capture/gallery (`ImagePicker`) → `scoreQuiz(quizAnswers)` atau `saveLatest` → Result. Tangani: kamera null, permission denied, file >10 MB, rotasi.

**Result:** skor + tipe + 5 metrik (oil, pores, acne, redness, hydration default 78) + rekomendasi + CTA. Jika `archived`, sembunyikan tombol Simpan.

**History:** sort `_newestFirst`, filter `_selectedDate`, `FutureBuilder` + skeleton; simpan via `saveAnalysis` (id `scan-<microseconds>`, insert 0).

**Help/Profile:** sesuai §6.8.

---

## 8. Rekomendasi Revisi (berbasis referensi, bukan rombak total)

Karena jawaban #2 mempertahankan varian, revisi di bawah **non-breaking** dan bisa dikerjakan bertahap. **3 utama (kerjakan dulu): ★1, ★2, ★3.**

1. ★ **Kunci 1 signature, rapikan 2 zona.** Jadikan cincin skor Result sebagai signature di semua promo/screenshot. Hapus `sparkles/bubbles` dari Scan/Result/History (tetap boleh di Start/Home; Login tanpa sticker, Help maks 1 sticker). Dampak: terlihat klinis-tepercaya seperti L'Oréal Skin Genius, bukan template AI.
2. ★ **Migrasi font ke Plus Jakarta Sans (1 PR).** Tambah `GoogleFonts.plusJakartaSansTextTheme` di `MaterialApp.theme` + `ThemeExtension<AppTokensExtension>`. Uji di Start (hero) dan Result (angka) dulu. Alasan: font default membuat visual terasa "Flutter generik"; Jakarta Sans memberi identitas Indonesia + keterbacaan.
3. ★ **Rapikan skala muted (tanpa hapus varian).** Bekukan tambah varian baru; untuk komponen baru selalu pakai `AppTokens.muted #FF6B7E89`. Pakai tabel §3.2 sebagai lint manual. Target: body ≥4.5:1, large text ≥3:1; teks ≤12sp dilarang di atas pastel tanpa uji.
4. **Satu pola empty/error/loading.** Samakan ilustrasi kecil + judul 16/700 + deskripsi 14 muted + 1 CTA primer di History-empty, kamera-denied, dan quiz-belum-lengkap. Contoh dari TroveSkin: empty = undangan bertindak, bukan dead-end.
5. **Stabilkan scan seperti YouCam.** Tambah hint pencahayaan ("Hadap cahaya, lepas kacamata"), oval guide adaptif, dan fallback galeri selalu terlihat (jangan sembunyi di menu). Catat di Help.
6. **Tambah Gallery/Storybook internal** (saran FlutterGems): satu route `/gallery` (debug only) berisi semua tombol/kartu/metrik agar QA visual tidak perlu keliling screen.
7. **Siapkan unifikasi bertahap (post-PBL):** petakan `#FF064E48→#FF087467` untuk teks kecil (kontras lebih aman), `#FF2FC1ED→#FF35A9EE` untuk ikon (konsisten info), varian coral → `#FFFF6B70` kecuali logout `#FFE6535F`. Lakukan setelah snapshot PBL agar tidak merusak penilaian.

Yang **tidak** diubah: struktur 9 screen (7 named + 2 push), logika `scoreQuiz`, model `SkinAnalysis`, `maxWidth 520 + compact <350`.

---

## 9. Lampiran Dev-Ready

### 9.1 Contoh `ThemeData` + Plus Jakarta Sans
> Getter yang dipakai di snippet (`AppTokens.h1/h2/title/body/caption`, `r12/r16/r20`, `card()`, `pageBg/teal/deepTeal/coral`) sudah ada di `lib/theme/app_tokens.dart` baris 18–83 — snippet ini hanya menunjukkan cara memakainya di `MaterialApp.theme`, bukan definisi baru.
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_tokens.dart';

ThemeData buildSkinSightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
  return base.copyWith(
    scaffoldBackgroundColor: AppTokens.pageBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppTokens.teal,
      primary: AppTokens.teal,
      secondary: AppTokens.deepTeal,
      surface: Colors.white,
      error: AppTokens.coral,
    ),
    textTheme: text.copyWith(
      displayLarge: AppTokens.h1.copyWith(fontSize: 32),
      headlineMedium: AppTokens.h1,
      titleLarge: AppTokens.h2,
      titleMedium: AppTokens.title,
      bodyMedium: AppTokens.body,
      bodySmall: AppTokens.caption,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppTokens.deepTeal,
        foregroundColor: Colors.white,
        minimumSize: const Size(160, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
  );
}
```

### 9.2 Do / Don't cepat (tempel di Figma/PR)
- Do: 1 CTA primer per screen; 1 ilustrasi hero; metrik warna konsisten; sentence case; touch 44dp; alt-text aset.
- Don't: tambah warna hex baru tanpa token; uppercase paragraf; >2 sticker; teks muted kecil di atas sky; copy "Submit" generik.

### 9.3 Kriteria terima (Definition of Done)
- [ ] Semua screen lolos 360×640 tanpa overflow (compact <350 bisa scroll).
- [ ] Tidak ada hex hardcode baru di luar §3 (cek `grep Color(0xFF`).
- [ ] Font Jakarta Sans tampil di Start, Home, Result (screenshot).
- [ ] Quiz 5/5 → Scan → Result → History tersimpan (test manual + `quiz_scoring_test`, `scan_result_responsive_test` hijau).
- [ ] Empty/error/loading mengikuti pola §8.4.
- [ ] Aset >200 KB dikompres; semua Image punya semanticLabel.

---

*Disusun dari pembacaan langsung kode v1.1.0+2 + referensi Mobbin/Dribbble skincare 2025–2026 + design system `clean`/`friendly` Open Design + prinsip anti-slop frontend-design. Keputusan stakeholder (hybrid C, pertahankan varian, Jakarta Sans, light-only, responsif device, profesional, revisi referensi, sertakan konteks, pakai logo eksisting, tanpa template kampus) telah dikunci di dokumen ini.*
