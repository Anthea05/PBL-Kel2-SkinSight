# PRD SkinSight v2.0

**Versi:** 2.0 (Draft untuk review) | **Tanggal:** 10 Oktober 2026 | **Tim:** PBL Kelompok 2 | **Platform:** Flutter (>=3.3.0), Android/iOS | **Bahasa antarmuka:** Indonesia | **Mode:** Light only

**Status dokumen:** Draft. Poin bertanda *(usulan)* perlu divalidasi tim dan dosen pembimbing.

## Riwayat Versi

| Versi | Tanggal | Perubahan |
| --- | --- | --- |
| 1.1.0 | 2026 | Design System & UI/UX Spec (skor + metrik, tanpa model sendiri) |
| 2.0 | 10 Okt 2026 | Disusun ulang menjadi PRD lengkap. Output model berubah menjadi rekomendasi perawatan (JSON). Desain Result dirancang ulang. Palet dan token disederhanakan. |

## 1. Ringkasan Eksekutif

**SkinSight** adalah aplikasi mobile untuk skrining awal kondisi kulit wajah. Pengguna menjawab kuis singkat dan memindai wajah (kamera atau galeri). Model AI milik tim, yang saat ini masih dalam tahap pelatihan, menghasilkan tipe kulit, penjelasan, zat aktif yang disarankan dan dihindari, rutinitas pagi dan malam, serta saran perawatan tambahan. Hasil dapat disimpan ke riwayat.

SkinSight **bukan alat diagnosis medis**. Produk ini memberi edukasi dan panduan perawatan umum.

**Perubahan terbesar dari v1.1:** keluaran utama bergeser dari skor dan metrik angka menjadi **rekomendasi perawatan terstruktur**, sehingga layar Result, token warna, dan kontrak data harus dirancang ulang.

## 2. Latar Belakang dan Masalah

- Pengguna sulit mengenali tipe dan kondisi kulitnya secara objektif, lalu bingung memilih kandungan dan urutan perawatan.
- Informasi skincare di media sosial sering bertentangan dan tidak berbasis pedoman dermatologi.
- Konsultasi dokter tidak selalu terjangkau untuk pemula yang hanya ingin arah awal.
- Aplikasi sejenis cenderung terlalu "jualan" atau terlalu teknis.

**Peluang:** panduan awal yang tenang, berbahasa Indonesia sederhana, dan jujur soal batasannya.

## 3. Tujuan, Non-Tujuan, dan Metrik

### 3.1 Tujuan produk

1. Pengguna memahami tipe kulitnya dalam kurang dari 3 menit.
2. Pengguna mendapat rutinitas pagi dan malam yang bisa langsung dipraktikkan.
3. Pengguna tahu kandungan yang perlu dihindari dan kapan harus ke dokter.
4. Antarmuka nyaman, responsif di layar kecil, dan tidak terkesan template generik.

### 3.2 Non-tujuan (v2.0)

- Diagnosis penyakit kulit atau saran resep obat.
- Transaksi, e-commerce, dan rekomendasi merek berbayar.
- Dark mode dan multi-bahasa.
- Pelacakan progres kulit berbasis perbandingan foto (ditunda).

### 3.3 Metrik keberhasilan *(usulan target, divalidasi lewat uji pengguna 8-10 orang)*

| Metrik | Target | Cara ukur |
| --- | --- | --- |
| Penyelesaian alur Quiz → Scan → Result | ≥ 85% peserta uji | Uji kegunaan terpantau |
| Waktu penyelesaian alur | Median ≤ 3 menit (di luar waktu model) | Stopwatch / log event |
| Waktu tunggu respons model | p90 ≤ 10 detik | Log latensi |
| Hasil dipahami (tanpa bantuan) | ≥ 80% menjawab benar 3 pertanyaan pemahaman | Kuesioner pasca-uji |
| Kepuasan kenyamanan UI | ≥ 4/5 | Kuesioner (skala Likert) |
| Kegagalan render akibat JSON | 0 layar kosong; fallback tampil | Tes otomatis |

## 4. Pengguna dan Stakeholder

### 4.1 Persona

**Alea (21 th, mahasiswi)** Kebutuhan: tahu tipe kulit tanpa ke klinik, bahasa sederhana. Pain point: bingung urutan skincare, takut salah kandungan, bingung banyak saran bertentangan. Skenario: sebelum tidur, ia menjawab kuis, memotret wajah, lalu menyimpan rutinitas malam untuk dicoba.

**Raka (24 th, karyawan, pemula)** Kebutuhan: panduan singkat dan minim istilah. Pain point: merasa skincare "bukan untuknya", wajah berminyak dan berjerawat. Skenario: membuka hasil di sela kerja, hanya membaca rutinitas dan daftar yang dihindari.

### 4.2 Stakeholder

Dosen penguji PBL (kelengkapan alur dan dokumentasi), tim model AI (kontrak output), developer dan desainer penerus (token dan spesifikasi).

## 5. Ruang Lingkup dan Fase

| Fase | Isi | Catatan |
| --- | --- | --- |
| **A. Prototype (sekarang)** | Seluruh alur UI dengan data tiruan (mock JSON) yang mengikuti kontrak §8 | Label "Demo" jelas di UI |
| **B. Integrasi model** | Panggilan ke model, validasi skema, penanganan error | Setelah model stabil |
| **C. Rilis terbatas** | Uji pengguna, perbaikan, dokumen akhir | Setelah persetujuan privasi |

Modul dalam v2.0: Start, Masuk/Daftar (dummy), Beranda, Quiz 5 soal, Scan, Result, Riwayat, Bantuan, Profil.

## 6. Alur Pengguna

**Alur utama:** Start → Masuk → Beranda → Quiz (5 soal) → Scan (izin kamera → ambil foto/galeri) → Menyusun rekomendasi → Result → Simpan → Riwayat.

**Alur alternatif:**

- Beranda → Scan langsung (tanpa quiz): hasil memakai foto saja, dan UI menyatakan akurasi lebih rendah.
- Riwayat → pilih item → Result mode baca (tanpa tombol Simpan).
- Izin kamera ditolak → tombol "Pilih dari galeri" dan "Buka Pengaturan".
- Model gagal atau timeout → layar error dengan "Coba lagi" dan opsi mengulang foto.

**Perilaku tombol kembali:** dari Result ke Beranda (bukan ke kamera), dengan konfirmasi "Buang hasil?" bila belum disimpan. Dari tab utama ke Beranda, bukan keluar aplikasi.

## 7. Kebutuhan Fungsional

Prioritas: **M** = wajib, **S** = sebaiknya, **C** = bisa.

### 7.1 Onboarding dan Akun

| ID | Kebutuhan | P | Kriteria terima |
| --- | --- | --- | --- |
| FR-01 | Halaman Start menampilkan nilai produk dan CTA "Mulai" dan "Masuk" | M | Dua CTA terlihat tanpa scroll di 360×640 |
| FR-02 | Masuk/Daftar dengan validasi email dan sandi ≥ 8 karakter | M | Pesan error inline berbahasa Indonesia |
| FR-03 | Akun demo diberi label "Demo"; tombol Google nonaktif diberi label "Segera hadir" | M | Tidak ada fitur palsu tanpa label |

### 7.2 Quiz

| ID | Kebutuhan | P | Kriteria terima |
| --- | --- | --- | --- |
| FR-04 | 5 soal satu per layar dengan progres "Langkah n dari 5" | M | Jawaban tersimpan saat maju/mundur |
| FR-05 | Tidak ada jawaban terisi otomatis | M | Tombol "Lanjut" nonaktif sampai ada pilihan |
| FR-06 | Jawaban quiz dikirim sebagai konteks ke model | M | Payload memuat 5 jawaban terstruktur |

### 7.3 Scan

| ID | Kebutuhan | P | Kriteria terima |
| --- | --- | --- | --- |
| FR-07 | Kamera depan dengan panduan oval wajah dan petunjuk cahaya | M | Petunjuk "Hadap cahaya, lepas kacamata" tampil |
| FR-08 | Pilih foto dari galeri | M | Tombol galeri selalu terlihat |
| FR-09 | Penanganan: izin ditolak, kamera tidak tersedia, file > 10 MB, rotasi | M | Tiap kasus punya pesan dan aksi |
| FR-10 | Tombol ambil foto terkunci saat proses (tanpa tekan ganda) | M | Tidak ada pengiriman ganda |

### 7.4 Analisis Model

| ID | Kebutuhan | P | Kriteria terima |
| --- | --- | --- | --- |
| FR-11 | Aplikasi memanggil model dan menerima JSON sesuai §8 | M | Respons lolos validasi skema |
| FR-12 | Status loading dengan skeleton dan teks "Menyusun rekomendasi…" | M | Tidak memakai progres palsu |
| FR-13 | Timeout 20 detik dengan "Coba lagi" | M | Pengguna tidak terjebak |
| FR-14 | JSON tidak lengkap: tampilkan bagian valid, sembunyikan bagian rusak | M | Tidak ada layar kosong |
| FR-15 | Percobaan ulang dibatasi (maks. 3 per sesi) | S | Pesan jelas bila batas tercapai |

### 7.5 Result

| ID | Kebutuhan | P | Kriteria terima |
| --- | --- | --- | --- |
| FR-16 | Menampilkan tipe kulit dan penjelasan singkat | M | Maks. 3 baris + "Selengkapnya" |
| FR-17 | Toggle Pagi/Malam untuk rutinitas bernomor | M | Berpindah tanpa memuat ulang |
| FR-18 | Daftar zat aktif yang cocok (nama + fungsi) | M | Tampil 3 dulu, "Lihat semua" |
| FR-19 | Zat aktif yang dihindari sebagai chip beraksen ikon peringatan | M | Tidak bergantung pada warna saja |
| FR-20 | Perawatan tambahan dan referensi dalam accordion | M | Terlipat secara default |
| FR-21 | Disclaimer tetap (bukan hasil model) | M | Selalu terlihat di Result |
| FR-22 | Simpan hasil; mode baca menyembunyikan tombol Simpan | M | Item baru tampil teratas di Riwayat |

### 7.6 Riwayat, Bantuan, Profil

| ID | Kebutuhan | P | Kriteria terima |
| --- | --- | --- | --- |
| FR-23 | Riwayat dengan urut Terbaru/Terlama dan filter tanggal | M | Kondisi kosong memuat CTA "Mulai scan" |
| FR-24 | Hapus item riwayat dan foto terkait | M | Konfirmasi lalu data benar-benar terhapus |
| FR-25 | Bantuan/FAQ: cara scan, cahaya, privasi, arti hasil, kontak | M | Topik bisa dibuka-tutup |
| FR-26 | Profil (nama, kontak, foto) dengan badge Demo untuk data dummy | S | Tombol Keluar bergaya danger outline |

## 8. Kontrak Output Model

### 8.1 Struktur JSON

```json
{
  "schema_version": "1.0",
  "tipe_kulit": "Kombinasi (T-Zone)",
  "penjelasan_singkat": "...",
  "zat_aktif_rekomendasi": [{"nama": "...", "fungsi": "..."}],
  "zat_aktif_dihindari": ["...", "..."],
  "rutinitas_harian": {"pagi": ["..."], "malam": ["..."]},
  "perawatan_tambahan": ["..."],
  "sumber_referensi": [{"judul": "...", "tahun_atau_penerbit": "..."}]
}
```

### 8.2 Aturan dan batas

| Field | Aturan |
| --- | --- |
| `schema_version` | Wajib; ditambahkan agar UI aman saat model berubah |
| `tipe_kulit` | Enum: Normal, Kombinasi (T-Zone), Cenderung Berminyak, Cenderung Kering, Sensitif Ringan, Rentan Berjerawat |
| `penjelasan_singkat` | 1-3 kalimat, maks. 280 karakter |
| `zat_aktif_rekomendasi` | 3-5 item; `fungsi` maks. 120 karakter |
| `zat_aktif_dihindari` | 2-5 item, nama saja |
| `rutinitas_harian.pagi/malam` | 3-6 langkah; 1 kalimat per langkah, maks. 100 karakter |
| `perawatan_tambahan` | 2-4 item |
| `sumber_referensi` | 1-3 item; hanya dari daftar putih (§8.3) |

### 8.3 Penanganan referensi

Model bahasa dapat mengarang judul jurnal. Karena itu `sumber_referensi` **tidak ditampilkan sebagai sitasi terverifikasi**. Pilihan: (a) validasi terhadap daftar putih yang dikurasi manual (misalnya PERDOSKI, AAD), atau (b) tampilkan dengan label "Rujukan umum, belum diverifikasi". Keputusan di §17.

### 8.4 Validasi dan fallback

1. Aplikasi memvalidasi skema sebelum render.
2. Field di luar batas dipotong dan diberi "Selengkapnya".
3. Enum tidak dikenal → tipe ditampilkan sebagai "Belum dapat ditentukan" dan pengguna diarahkan mengulang foto.
4. Mode prototype memakai 3 contoh JSON (pendek, normal, panjang) untuk menguji UI.

### 8.5 Input ke model

Quiz (5 jawaban) dan foto menjadi input; `tipe_kulit` adalah output model. Skor quiz lama (`scoreQuiz`) dipertahankan hanya sebagai fitur pembanding selama masa transisi atau dihapus; keputusan di §17.

## 9. Desain UI/UX

### 9.1 Prinsip

1. **Tenang dan jelas:** pengguna datang untuk tenang, bukan dihibur berlebihan.
2. **Isi dulu, hiasan kemudian:** satu elemen visual khas per layar.
3. **Jujur:** batasan dan status demo selalu tampak.
4. **Bentuk mengikuti isi:** rutinitas berbentuk langkah, zat aktif berbentuk baris, peringatan berbentuk chip. Tidak semuanya kartu yang sama.
5. **Satu CTA utama per layar**, di area jangkauan jempol.

### 9.2 Zona visual

- **Hangat (Start, Masuk, Beranda, Bantuan):** gradien pastel lembut, maks. 1 ilustrasi hero.
- **Fungsional (Quiz, Scan, Result, Riwayat, Profil):** latar netral, tanpa stiker dan ilustrasi dekoratif.

### 9.3 Layout Result (atas ke bawah)

1. Header: tipe kulit sebagai judul + penjelasan singkat.
2. Rutinitas: toggle **Pagi | Malam**, langkah bernomor.
3. Zat aktif yang cocok: baris dengan divider.
4. Zat aktif yang dihindari: chip yang bisa turun baris, dengan ikon.
5. Perawatan tambahan: daftar singkat.
6. Referensi dan disclaimer: accordion di bawah.
7. Bar CTA tetap di bawah: "Simpan hasil" (utama) dan "Scan ulang" (sekunder). BottomNav disembunyikan di layar ini.

Elemen khas (signature) Result: **timeline rutinitas pagi/malam**, bukan cincin skor.

### 9.4 State yang wajib ada

| State | Isi |
| --- | --- |
| Loading | Skeleton + "Menyusun rekomendasi…" |
| Kosong | Ikon kecil + judul + 1 kalimat + 1 CTA |
| Error/timeout | Penyebab + aksi: "Koneksi terputus. Coba lagi atau ulangi foto." |
| Izin ditolak | "Izin kamera ditolak. Aktifkan di Pengaturan atau pilih dari galeri." |
| Sebagian data | Bagian valid tampil; bagian rusak disembunyikan |

### 9.5 Glosarium microcopy (konsisten)

| Hindari | Pakai |
| --- | --- |
| Home / History / Login | Beranda / Riwayat / Masuk |
| Scan Sekarang / Mulai Analisis / Ambil Foto / Coba | **Mulai scan** (satu aksi, satu nama) |
| Submit / OK | Aksi spesifik: "Simpan hasil", "Lanjut" |

Gaya: kalimat biasa (sentence case), aktif, singkat. Label BottomNav: **Beranda, Riwayat, Bantuan, Profil**.

## 10. Design Token

Warna ditulis 6 digit (untuk Figma); di Dart tambahkan `FF` di depan (`Color(0xFF168A78)`).

### 10.1 Proporsi warna di layar

| Peran | Porsi | Warna | Dipakai untuk |
| --- | --- | --- | --- |
| Netral dominan | \~60% | Latar `#F4F6F6`, kartu `#FFFFFF` | Latar layar dan kartu |
| Pendukung | \~30% | Teks `#13263A`, border `#E2E9E7`, krem/mint sangat tipis | Teks, garis, header |
| Aksen | ≤10% | `#087467` (teks/CTA), `#168A78` (ikon/progres) | CTA, tab aktif, progres |
| Semantik | ≤5% | coral, orange, sky versi lembut | Peringatan dan status saja |

Gradien hanya di header, maks. \~25% tinggi layar, lalu memudar ke latar netral.

### 10.2 Token inti

| Token | Hex | Peran |
| --- | --- | --- |
| `primary` | `#087467` | CTA, teks tautan, tab aktif |
| `primarySoft` | `#168A78` | Ikon aktif, progres, ilustrasi |
| `ink` | `#13263A` | Judul dan isi |
| `inkSecondary` | `#5A6D78` | Teks sekunder dan caption |
| `disabled` | `#9AA9B0` | Nonaktif (bukan teks penting) |
| `bg` | `#F4F6F6` | Latar layar |
| `surface` | `#FFFFFF` | Kartu |
| `surfaceWarm` | `#FFF8EB` | Latar hangat (Start/Beranda) |
| `border` | `#E2E9E7` | Border dan divider (satu saja) |
| `successSoft` | `#E3F4F0` | Latar terpilih / badge sukses |
| `warnChipBg` / `warnChipText` | `#FFF0F0` / `#B3303A` | Chip zat dihindari |
| `danger` | `#E6535F` | Keluar, error |
| `info` | `#35A9EE` | Info (grafis, bukan teks kecil) |

### 10.3 Aturan kontras *(hitungan kasar, wajib diverifikasi dengan alat uji)*

- Teks isi dan caption minimal 4,5:1; teks besar dan komponen grafis minimal 3:1.
- `#168A78` dengan teks putih sekitar 4,25:1, jadi **tidak dipakai untuk teks kecil**; gunakan `#087467` (sekitar 5,6:1).
- `#5A6D78` di atas putih sekitar 5,4:1. `#6B7E89` (warna lama) sekitar 4,2:1 sehingga digantikan.
- `#B3303A` di atas `#FFF0F0` sekitar 5,6:1.
- Makna tidak boleh bergantung pada warna saja: selalu sertakan ikon atau label.
- Varian hex lama di PRD 1.1 dianggap *legacy*: dilarang dipakai di komponen baru dan dimigrasi bertahap.

### 10.4 Tipografi

Plus Jakarta Sans (font dibundel sebagai asset, bukan diunduh runtime). Fallback: sans sistem.

| Peran | Ukuran / berat / tinggi baris |
| --- | --- |
| Display | 28 / 800 / 1.15 |
| H1 | 24 / 700 / 1.2 |
| H2 | 20 / 700 / 1.25 |
| Title | 16 / 700 / 1.3 |
| Body | 15 / 400 / 1.5 |
| Caption | 13 / 400 / 1.4 |
| Tombol | 16 / 700 |

Eyebrow "Langkah 2 dari 5" memakai 12 / 600, huruf biasa (bukan kapital semua). Satu nilai tetap per peran, tidak memakai rentang.

### 10.5 Spacing, bentuk, elevasi

- Spacing kelipatan 8: margin horizontal 16, antar-section 24, antar-kartu 12, padding kartu 16.
- Radius: input/chip 12, kartu 16, panel besar/modal 20.
- Bayangan kartu: warna `#087467` 6%, blur 12, offset (0,4); mati di atas gradien.
- Motion: transisi 150-250 ms, hormati *reduce motion*; satu momen animasi per layar.
- Ikon: Material rounded, 24 dp untuk navigasi, 20 dp untuk daftar; selalu dengan label di BottomNav.

## 11. Responsivitas dan Aksesibilitas

### 11.1 Breakpoint

| Lebar | Perlakuan |
| --- | --- |
| < 360 | Compact: margin 12, font hero turun 1-2 sp, scroll aman |
| 360-599 | Standar |
| ≥ 600 | Kolom tengah maks. 520, tidak melebar penuh |

Target uji: 360×640 tanpa overflow, 320 lebar tetap dapat dipakai.

### 11.2 Aturan kenyamanan

- Target sentuh minimal 48×48 dp.
- Aksi utama di bawah (zona jempol); bar CTA memakai `SafeArea`.
- Teks panjang maks. 3 baris sebelum "Selengkapnya".
- Teks mendukung skala sampai 1,3× tanpa terpotong; chip memakai `Wrap`, tidak ada tinggi tetap pada teks.
- Tidak ada scroll horizontal pada layar apa pun.

### 11.3 Aksesibilitas

- Semua gambar dan ikon bermakna punya `semanticLabel`.
- Urutan fokus mengikuti urutan baca; fokus keyboard terlihat.
- Chip "hindari" memakai ikon + teks, bukan warna saja.
- Animasi dikurangi saat pengguna mengaktifkan *reduce motion*.

## 12. Persyaratan Non-Fungsional

| Aspek | Persyaratan |
| --- | --- |
| Performa | Start-up dingin < 3 dd; layar utama 60 fps; model p90 ≤ 10 dd |
| Kompatibilitas | Android 8+ dan iOS 13+ *(usulan)* |
| Ukuran foto | Maks. 10 MB, dikompres sebelum kirim |
| Konektivitas | Tanpa internet: pesan jelas, riwayat lokal tetap bisa dibuka |
| Keandalan | Tidak ada layar kosong pada JSON rusak; error terlihat dan dapat dipulihkan |
| Aset | Gambar > 200 KB dikompres; sediakan resolusi 2×/3× bila buram |
| Kualitas kode | Satu sumber token; layar Beranda dipecah menjadi widget kecil |

## 13. Privasi, Etika, dan Disclaimer

- **Foto wajah adalah data pribadi.** Tampilkan persetujuan (consent) sebelum foto pertama, jelaskan tujuan, lokasi penyimpanan, dan lama simpan. Kepatuhan mengacu UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi.
- Pengguna dapat menghapus foto dan riwayat kapan saja (FR-24).
- Foto tidak digunakan untuk melatih model tanpa persetujuan terpisah.
- Pengguna di bawah umur: syarat usia ditampilkan saat daftar *(keputusan di §17)*.
- **Disclaimer tetap di UI:** "Hasil ini panduan umum, bukan diagnosis. Lakukan uji tempel. Hentikan pemakaian bila iritasi dan konsultasikan ke dokter, terutama bila hamil, menyusui, atau memiliki kondisi kulit tertentu."
- Prototype dengan data tiruan wajib berlabel "Demo". Tidak ada klaim akurasi sebelum model divalidasi.

## 14. Analitik *(usulan, dengan persetujuan pengguna)*

| Event | Kegunaan |
| --- | --- |
| `quiz_started`, `quiz_completed` | Penyelesaian quiz |
| `scan_started`, `scan_captured`, `scan_permission_denied` | Hambatan scan |
| `analysis_requested`, `analysis_success`, `analysis_failed` | Latensi dan kegagalan model |
| `result_viewed`, `routine_tab_switched`, `result_saved` | Penggunaan Result |
| `history_deleted` | Kontrol data pengguna |

Tidak ada pencatatan foto atau teks hasil mentah dalam analitik.

## 15. Pengujian dan Definition of Done

**Uji otomatis:** validasi skema JSON (3 contoh: pendek, normal, panjang; 1 rusak), uji widget responsif Result di 320/360/412, uji alur Quiz → Scan → Result → Riwayat.

**Uji manual:** kontras warna dengan alat, TalkBack/VoiceOver di Result, skala teks 1,3×, perangkat fisik kelas bawah.

**Definition of Done:**

- [ ] Semua layar lolos 360×640 tanpa overflow.
- [ ] Tidak ada warna hardcode di luar token §10.
- [ ] Font Plus Jakarta Sans tampil di Start, Beranda, Result (bundel asset, diperiksa tidak jatuh ke font bawaan).
- [ ] Result menangani 3 panjang konten dan 1 JSON rusak.
- [ ] Kontras memenuhi §10.3 (bukti hasil alat uji).
- [ ] Disclaimer dan consent tampil.
- [ ] Semua label berbahasa Indonesia sesuai glosarium §9.5.
- [ ] Dokumen versi ini disetujui dosen pembimbing.

## 16. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| Model belum stabil / salah saran | Tinggi | Fase prototype dengan data tiruan; disclaimer; daftar zat aktif divalidasi dermatolog atau literatur |
| Referensi jurnal dikarang model | Tinggi | Daftar putih atau label belum diverifikasi (§8.3) |
| Foto wajah bocor | Tinggi | Consent, enkripsi, hapus data, simpan seminimal mungkin |
| Konten JSON terlalu panjang | Sedang | Batas karakter + "Selengkapnya" + uji 3 panjang |
| Latensi model tinggi | Sedang | Skeleton, timeout, coba lagi |
| Rekomendasi tidak cocok untuk kondisi khusus (hamil, alergi) | Tinggi | Disclaimer + pertanyaan di quiz *(usulan)* |
| Waktu PBL terbatas | Sedang | Prioritas M dahulu, S/C menyusul |

## 17. Asumsi, Dependensi, dan Pertanyaan Terbuka

**Asumsi:** model dapat mengikuti kontrak §8; koneksi internet tersedia saat analisis; pengguna utama berusia ≥ 17 tahun.

**Dependensi:** model AI tim (status training), layanan penyimpanan (saat ini hanya memori lokal), paket `image_picker`, kamera dan izin perangkat.

**Pertanyaan terbuka:**

1. Apakah model juga akan mengeluarkan skor/metrik, atau tidak? (menentukan signature visual)
2. Apakah `scoreQuiz` lama dipertahankan, atau dihapus?
3. Referensi: daftar putih atau label "belum diverifikasi"?
4. Siapa yang memvalidasi isi zat aktif dan rutinitas (dermatolog / literatur)?
5. Di mana foto diproses dan disimpan (perangkat atau server)?
6. Batas usia minimum pengguna?
7. Apakah quiz perlu pertanyaan kondisi khusus (hamil, alergi)?

## 18. Roadmap

| Tahap | Fokus |
| --- | --- |
| Minggu 1-2 | Revisi UI Result, token, glosarium; mock JSON 3 panjang |
| Minggu 3-4 | Quiz tanpa prefill, state loading/error, consent dan disclaimer |
| Minggu 5-6 | Integrasi model, validasi skema, uji pengguna |
| Setelah PBL | Migrasi varian warna lama, dark mode, pelacakan progres |

## 19. Glosarium

| Istilah | Arti |
| --- | --- |
| Zat aktif | Kandungan skincare yang bekerja pada kulit (mis. niacinamide) |
| Uji tempel | Mencoba produk di area kecil sebelum dipakai ke seluruh wajah |
| Skeleton | Kerangka abu-abu sementara saat data dimuat |
| Enum | Daftar nilai tetap yang diizinkan untuk satu field |
| Fallback | Tampilan cadangan saat data gagal atau rusak |
