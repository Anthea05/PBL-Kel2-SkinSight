# SkinSight Backend

REST API untuk aplikasi mobile **SkinSight** (PBL Kelompok 2, Politeknik Negeri Malang).
Fitur yang dilayani: autentikasi, kuis kondisi kulit & gaya hidup, scan foto kulit berbasis ML,
rekomendasi bahan aktif + produk yang **mengecualikan alergi pengguna**, katalog produk dengan filter
harga, serta edukasi tips harian dan nutrisi.

> Hasil analisis SkinSight **bukan diagnosis medis**. Setiap respons hasil scan dan rekomendasi
> menyertakan field `disclaimer`.

## Teknologi

| Bagian | Pilihan |
| --- | --- |
| Bahasa & framework | Python 3.11+ (image Docker: 3.12), FastAPI, Uvicorn |
| Database | PostgreSQL 17, SQLAlchemy 2.0 (mode **sync**), Alembic |
| Validasi & konfigurasi | Pydantic v2, pydantic-settings (semua konfigurasi dari environment) |
| Keamanan | JWT access + refresh token (PyJWT), hash password Argon2 (argon2-cffi) |
| Gambar & ML | Pillow (validasi), Ultralytics/PyTorch untuk `ML_MODE=local`, httpx untuk `ML_MODE=remote` |
| Testing | pytest + database PostgreSQL terpisah |

## Arsitektur

```text
Flutter (Dio)
   │  HTTP JSON / multipart, header Authorization: Bearer <access_token>
   ▼
routers/        tipis: terima request -> panggil service -> bungkus ke format respons standar
   │
   ▼
services/       logika bisnis (auth, scan, rekomendasi, ml_service, impor produk, ...)
   │
   ▼
repositories/   SATU-SATUNYA lapisan yang menjalankan query database
   │
   ▼
PostgreSQL      tabel didefinisikan di models/, perubahan skema lewat alembic/
```

- `app/services/ml_service.py` dibuat & dimuat **sekali saat startup** (lifespan di `app/main.py`).
- `app/core/` berisi konfigurasi, keamanan JWT/password, dependency injection, exception handler,
  middleware (request id, log request, batas ukuran body), dan rate limiter.

## Struktur folder

```text
backend/
├── app/
│   ├── main.py            # rakit aplikasi: logging, middleware, CORS, exception handler, router
│   ├── core/              # config, constants, security, dependencies, exceptions, middleware, rate_limit
│   ├── db/                # base model, session, seed data
│   ├── models/            # tabel SQLAlchemy
│   ├── schemas/           # skema Pydantic request/response
│   ├── routers/           # auth, users, quiz, scans, products, ingredients, education, health
│   ├── services/          # logika bisnis (ml_service.py, recommendation_service.py, ...)
│   └── repositories/      # akses database
├── alembic/               # migrasi (0001_initial_schema.py)
├── data/                  # seed: kondisi kulit, ingredients, mapping, produk contoh, edukasi
├── ml_models/             # tempat file model ML (tidak di-commit)
├── scripts/import_products.py   # impor CSV produk (dataset Female Daily)
├── tests/                 # pytest
├── Dockerfile, docker-compose.yml
├── requirements.txt, requirements-ml.txt
└── .env.example
```

## Menjalankan dengan Docker (disarankan)

Jalankan semua perintah dari folder `backend/`.

1. Buat file konfigurasi, lalu isi `POSTGRES_PASSWORD` dan `JWT_SECRET_KEY`:

   ```bash
   cp .env.example .env            # PowerShell: Copy-Item .env.example .env
   python -c "import secrets; print(secrets.token_urlsafe(48))"   # contoh membuat JWT_SECRET_KEY
   ```

2. Jalankan service `db` dan `api`:

   ```bash
   docker compose up -d --build
   ```

3. Buat tabel (migrasi), lalu isi data awal:

   ```bash
   docker compose exec api alembic upgrade head
   docker compose exec api python -m app.db.seed
   ```

4. Buka dokumentasi interaktif di <http://localhost:8000/docs>. Spesifikasi OpenAPI tersedia di
   <http://localhost:8000/openapi.json> dan bisa diimpor ke Postman (Import → Link).

5. Jalankan test (database `<POSTGRES_DB>_test` dibuat otomatis):

   ```bash
   docker compose exec api pytest
   ```

Seed aman dijalankan berulang (idempotent). Untuk menghapus seluruh data: `docker compose down -v`.

## Menjalankan tanpa Docker

Butuh Python 3.11+ dan server PostgreSQL yang sudah berjalan. Nilai bawaan `.env.example` mengarah ke
service `db` dari docker-compose di `localhost:5433` (host port 5433 dipilih agar tidak bentrok dengan
PostgreSQL lokal yang umumnya memakai 5432). Jika memakai PostgreSQL lokal sendiri, ubah host, port,
user, dan password di `DATABASE_URL` serta `TEST_DATABASE_URL` (user test butuh hak `CREATE DATABASE`).

```bash
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env               # sesuaikan DATABASE_URL, TEST_DATABASE_URL, JWT_SECRET_KEY
alembic upgrade head
python -m app.db.seed
uvicorn app.main:app --reload      # http://localhost:8000/docs
pytest
```

## Testing

- Test memakai database **terpisah** dari `TEST_DATABASE_URL` (urutan baca: environment → `.env` →
  default `.../skinsight_test`). Database dibuat otomatis bila belum ada, dan namanya **wajib**
  mengandung kata `test` (pengaman agar database development tidak terhapus).
- Setiap test dimulai dari tabel kosong + seed data referensi. Semua test memakai `ML_MODE=mock`.

| File | Cakupan |
| --- | --- |
| `test_auth.py` | register, login, refresh, token kedaluwarsa/salah, semua endpoint terproteksi tanpa token → 401 |
| `test_users.py` | profil, PATCH sebagian, email bentrok |
| `test_quiz.py` | simpan kuis, normalisasi alergi, kuis terbaru |
| `test_products.py` | filter harga (batas inklusif), kategori, kondisi kulit, pencarian, urutan, detail |
| `test_scans.py` | alur scan mode mock, riwayat (paginasi, urutan, tanggal), validasi gambar, ukuran file, privasi foto, 503 saat ML mati, akses data user lain |
| `test_recommendations.py` | pengecualian alergi (bahan & produk, termasuk alias seperti "Parfum"), urutan, filter harga |
| `test_education_ingredients.py` | tips, nutrisi per kondisi, daftar & detail ingredient |
| `test_health_and_errors.py` | health check, OpenAPI, format error global, error 500 tanpa bocor detail, rate limit, importer CSV |

## Mode Machine Learning

Interface tunggal di `app/services/ml_service.py`:
`predict(image_bytes, body_area) -> [{label, confidence}, ...]` (urut dari confidence tertinggi).

| `ML_MODE` | Perilaku |
| --- | --- |
| `mock` (default) | Hasil dummy **deterministik** (gambar + area sama → hasil sama). Bukan hasil model sungguhan. |
| `local` | Memuat file `ML_MODEL_PATH` sekali saat startup. `.pt` → Ultralytics; `.keras`/`.h5` → TensorFlow. |
| `remote` | `POST` multipart ke `ML_API_URL` lewat httpx. |

Temuan dari branch **Rafazl** (`Tr_Oilness_PBL.ipynb`):

- Model **YOLOv8n-cls** (Ultralytics 8.4.175, PyTorch), dilatih dengan
  `yolo task=classify mode=train model=yolov8n-cls.pt data=/content/Oily-1 epochs=40 imgsz=224`.
- Kelas: `combination`, `dry`, `normal`, `oily`. Ukuran input `imgsz=224`.
- Preprocessing ditangani Ultralytics saat `model.predict(...)`, jadi backend tidak menulis ulang
  preprocessing untuk model `.pt`.

Langkah memakai model asli (`local`):

1. Salin `runs/classify/train/weights/best.pt` ke `backend/ml_models/best.pt`.
2. Di `.env`: `ML_MODE=local`, `INSTALL_ML=true`.
3. `docker compose up -d --build` (image akan memasang Ultralytics + PyTorch CPU).
4. Cek `GET /api/v1/health` → `ml.ready` harus `true`. Jika model gagal dimuat, API tetap jalan
   tetapi `POST /scans` membalas `503 ML_UNAVAILABLE` (detail error ada di log server).

Kontrak API ML untuk mode `remote` (perlu diimplementasikan tim ML):

```text
POST {ML_API_URL}        multipart/form-data: image=<file JPEG/PNG>, body_area=<wajah|tangan|punggung|kaki>
200 OK                   {"predictions": [{"label": "oily", "confidence": 0.87}, ...]}
```

Label yang dikembalikan model harus sama dengan kolom `code` di tabel `skin_conditions`
(`data/skin_conditions.json`). Label yang tidak dikenal tetap disimpan, tetapi rekomendasinya kosong.

## Format respons

```json
{"success": true, "data": {}, "message": "Login berhasil."}
```

```json
{"success": false, "error": {"code": "VALIDATION_ERROR", "message": "Data yang dikirim tidak valid.",
  "details": [{"field": "email", "message": "value is not a valid email address: ..."}]}}
```

Endpoint daftar mengembalikan `data` berbentuk
`{"items": [...], "page": 1, "page_size": 20, "total": 42, "total_pages": 3}`.

| HTTP | `error.code` | Arti |
| --- | --- | --- |
| 401 | `UNAUTHORIZED`, `INVALID_TOKEN`, `TOKEN_EXPIRED`, `INVALID_CREDENTIALS` | token tidak ada / salah / kedaluwarsa (panggil `/auth/refresh`), atau login salah |
| 404 | `NOT_FOUND`, `SCAN_NOT_FOUND`, `PRODUCT_NOT_FOUND`, `INGREDIENT_NOT_FOUND`, `CONDITION_NOT_FOUND`, `QUIZ_NOT_FOUND` | data tidak ada |
| 409 | `EMAIL_ALREADY_REGISTERED` | email sudah dipakai |
| 413 | `FILE_TOO_LARGE` | gambar melebihi `MAX_UPLOAD_SIZE_MB` |
| 415 | `UNSUPPORTED_MEDIA_TYPE` | bukan gambar JPEG/PNG yang valid |
| 422 | `VALIDATION_ERROR`, `EMPTY_FILE` | input tidak valid (lihat `details`) |
| 429 | `RATE_LIMITED` | terlalu banyak request; lihat header `Retry-After` |
| 500 | `INTERNAL_SERVER_ERROR` | kesalahan server (detail hanya di log) |
| 503 | `ML_UNAVAILABLE` | service ML belum siap / gagal |

Setiap respons membawa header `X-Request-ID` yang juga tercatat di log server (memudahkan debug).

## Daftar endpoint (prefix `/api/v1`)

| Method | Path | Login | Keterangan |
| --- | --- | --- | --- |
| GET | `/health` | - | status API, database, service ML |
| POST | `/auth/register` | - | daftar + langsung mendapat token (rate limit) |
| POST | `/auth/login` | - | login email & password (rate limit) |
| POST | `/auth/refresh` | - | tukar refresh token dengan pasangan token baru (rate limit) |
| GET | `/users/me` | ✓ | profil |
| PATCH | `/users/me` | ✓ | ubah `name`, `phone`, `email` (sebagian) |
| POST | `/quiz` | ✓ | simpan jawaban kuis |
| GET | `/quiz/latest` | ✓ | kuis terbaru |
| POST | `/scans` | ✓ | multipart `image` + `body_area` → hasil analisis (rate limit) |
| GET | `/scans` | ✓ | riwayat: `page`, `page_size`, `date=YYYY-MM-DD`, `newest_first=true` |
| GET | `/scans/{id}` | ✓ | detail scan |
| DELETE | `/scans/{id}` | ✓ | hapus data scan (+ foto jika tersimpan) |
| GET | `/scans/{id}/recommendations` | ✓ | bahan aktif + produk tanpa alergen: `min_price`, `max_price`, `limit` |
| GET | `/products` | - | `min_price`, `max_price`, `category`, `concern`, `q`, `sort`, `page`, `page_size` |
| GET | `/products/{id}` | - | detail produk + ingredient |
| GET | `/ingredients` | - | daftar bahan: `q`, `page`, `page_size` |
| GET | `/ingredients/{id}` | - | detail bahan + kondisi kulit yang cocok |
| GET | `/education/tips` | - | tips harian, opsional `condition=oily` |
| GET | `/education/nutrition` | - | saran nutrisi, opsional `condition=oily` |

`sort` produk: `price_asc` (default), `price_desc`, `name_asc`, `newest`.
`concern` / `condition` memakai kode kondisi: `combination`, `dry`, `normal`, `oily`.
Endpoint `/scans` membatasi semua akses ke data milik user sendiri (data user lain → 404).

## Contoh request & response

Register (`POST /api/v1/auth/register`, respons `201`):

```json
{"name": "Alea Kucing", "email": "alea@skinsight.id", "password": "skinsight123"}
```

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOi...",
    "refresh_token": "eyJhbGciOi...",
    "token_type": "bearer",
    "expires_in": 1800,
    "user": {"id": "a3fc49b6-5b3e-4d1a-b5b9-c7115584e68d", "name": "Alea Kucing", "email": "alea@skinsight.id", "phone": null, "created_at": "2026-10-10T08:17:25.700000Z"}
  },
  "message": "Registrasi berhasil."
}
```

Login (`POST /auth/login`) memakai body `{"email", "password"}` dengan respons yang sama.
Refresh (`POST /auth/refresh`) memakai body `{"refresh_token": "..."}` dan mengembalikan token baru
(tanpa `user`).

Scan (`POST /api/v1/scans`, `multipart/form-data`, respons `201`):

```bash
curl -X POST http://localhost:8000/api/v1/scans \
  -H "Authorization: Bearer <access_token>" \
  -F "image=@wajah.jpg;type=image/jpeg" \
  -F "body_area=wajah"
```

```json
{
  "success": true,
  "data": {
    "id": "68102b91-3893-499c-81f4-1e047311c402",
    "body_area": "wajah",
    "label": "dry",
    "confidence": 0.359,
    "title": "Kulit Kering",
    "skin_type": "Kulit Kering",
    "predictions": [
      {"label": "dry", "confidence": 0.359},
      {"label": "combination", "confidence": 0.3474},
      {"label": "oily", "confidence": 0.2164},
      {"label": "normal", "confidence": 0.0771}
    ],
    "model_version": "mock-v1",
    "image_stored": false,
    "analyzed_at": "2026-10-10T08:17:38.744545Z",
    "disclaimer": "Hasil analisis SkinSight bukan diagnosis medis dan tidak menggantikan pemeriksaan oleh dokter spesialis kulit (dermatolog). Segera konsultasikan ke tenaga medis jika keluhan berlanjut, terasa nyeri, atau memburuk."
  },
  "message": "Analisis kulit berhasil."
}
```

Rekomendasi (`GET /api/v1/scans/{id}/recommendations?limit=2`, pengguna alergi `fragrance`; dipersingkat):

```json
{
  "success": true,
  "data": {
    "scan_id": "68102b91-3893-499c-81f4-1e047311c402",
    "condition": {"code": "dry", "name": "Kulit Kering", "description": "Kulit terasa kencang atau ketarik, ..."},
    "allergies": ["fragrance"],
    "ingredients": [
      {"id": 5, "name": "Ceramide", "slug": "ceramide", "description": "Lipid alami penyusun skin barrier ...", "caution": null, "note": "Memperbaiki skin barrier dan mengunci kelembapan.", "priority": 1}
    ],
    "excluded_ingredients": [],
    "products": [
      {"id": 5, "name": "Ceramide Overnight Mask", "brand": "Kirana Lab", "category": "mask", "price": 115000, "image_url": null, "matched_ingredients": ["Ceramide", "Glycerin", "Panthenol", "Shea Butter", "Squalane"]}
    ],
    "excluded_products_count": 7,
    "disclaimer": "Hasil analisis SkinSight bukan diagnosis medis ..."
  },
  "message": "Rekomendasi berhasil dimuat."
}
```

Katalog (`GET /api/v1/products?max_price=60000&page_size=2`):

```json
{
  "success": true,
  "data": {
    "items": [
      {"id": 25, "name": "Hydrating Sheet Mask Hyaluronic", "brand": "Puspa Derm", "category": "mask", "price": 25000, "description": "Sheet mask hidrasi untuk perawatan mingguan.", "image_url": null},
      {"id": 18, "name": "Aloe Vera Soothing Gel", "brand": "Lestari Botanika", "category": "moisturizer", "price": 35000, "description": "Gel lidah buaya untuk hidrasi ringan.", "image_url": null}
    ],
    "page": 1,
    "page_size": 2,
    "total": 6,
    "total_pages": 3
  },
  "message": null
}
```

Error tanpa token (`401`):

```json
{"success": false, "error": {"code": "UNAUTHORIZED", "message": "Token akses diperlukan. Kirim header 'Authorization: Bearer <access_token>'."}}
```

## Kode jawaban kuis

Lima pertanyaan mengikuti `skin_quiz_page.dart`. Di Flutter jawaban disimpan sebagai indeks 0-3;
kirim ke API sebagai kode berikut (urutan sama dengan indeks).

| Field | Pertanyaan | Indeks 0 | Indeks 1 | Indeks 2 | Indeks 3 |
| --- | --- | --- | --- | --- | --- |
| `skin_feel` | Rasa kulit saat bangun pagi | `oily_t_zone` | `oily_all_over` | `dry_tight` | `balanced` |
| `sensitivity` | Seberapa sering kulit sensitif | `rarely` | `sometimes` | `often` | `very_often` |
| `pore_visibility` | Kondisi pori-pori | `barely_visible` | `visible_nose` | `visible_t_zone` | `visible_many_areas` |
| `main_concern` | Masalah kulit utama | `acne_blackheads` | `dull_uneven` | `dry_dehydrated` | `fine_lines` |
| `outdoor_exposure` | Durasi di luar ruangan | `lt_30_min` | `30_to_60_min` | `1_to_3_hours` | `gt_3_hours` |

Field tambahan: `allergies` (list teks, mis. `["fragrance", "niacinamide"]`, maks. 20),
`diet_pattern` (teks bebas, opsional), `habits` (list teks, opsional).

## Cara kerja rekomendasi & alergi

1. Kondisi kulit diambil dari label hasil scan, lalu bahan aktif diambil dari `condition_ingredients`.
2. Alergi dari **kuis terbaru** dicocokkan per kata/frasa utuh (huruf besar/kecil & tanda baca diabaikan)
   terhadap nama, slug, dan alias bahan. Contoh: alergi `salicylic` cocok dengan *Salicylic Acid*;
   alergi `parfum` cocok dengan *Fragrance*.
3. Bahan yang cocok dipindah ke `excluded_ingredients` beserta alasannya (`matched_allergy`).
4. Produk dikecualikan jika ingredient-nya **atau** teks komposisinya (`ingredients_text`) memuat
   bahan alergen, termasuk alias. Contoh: alergi `fragrance` juga membuang produk berkomposisi "Parfum".
5. Pencocokan sengaja konservatif: alergi `alcohol` juga membuang produk dengan *Cetyl Alcohol*.

## Privasi & keamanan

- Foto kulit **tidak disimpan** secara default (`SAVE_SCAN_IMAGES=false`). Foto hanya diproses di
  memori, file sementara upload langsung ditutup/dihapus, dan yang disimpan hanya hasil + metadata.
- Jika `SAVE_SCAN_IMAGES=true`, foto disimpan di `SCAN_IMAGE_DIR/<user_id>/<scan_id>.<ext>` dan ikut
  dihapus saat `DELETE /scans/{id}`. Menghapus user juga menghapus kuis & scan miliknya (cascade).
- Upload divalidasi: `Content-Type` harus `image/jpeg`/`image/png`, isi file dicek dengan Pillow
  (bukan gambar → 415), ukuran maksimal `MAX_UPLOAD_SIZE_MB`, resolusi maksimal 25 MP.
- Password di-hash Argon2id. Pesan login salah dibuat sama untuk email salah maupun password salah.
- ID user, kuis, dan scan berupa UUID (tidak bisa ditebak). Data scan user lain selalu dibalas 404.
- Error tak terduga dibalas pesan umum; stack trace hanya tercatat di log server.
- Rate limit per IP untuk `/auth/*` dan `/scans/*` (disimpan di memori proses; lihat batasan di bawah).

## Data contoh & impor Female Daily

- `data/skin_conditions.json` memakai label kelas dari model branch Rafazl.
- `data/ingredients.json`, `data/condition_ingredients.json`, `data/education_articles.json` berisi
  informasi perawatan kulit umum (bukan saran medis) dan perlu ditinjau tim sebelum dipakai publik.
- **`data/products.csv` adalah data CONTOH FIKTIF** (merek, nama, dan harga rekaan) untuk demo dan test,
  bukan produk asli. Produk asli diimpor dari dataset Female Daily:

```bash
python scripts/import_products.py --csv data/female_daily.csv --dry-run          # cek dulu
python scripts/import_products.py --csv data/female_daily.csv \
  --column name="Product Name" --column price=Harga --column ingredients=Ingredients
# Docker: docker compose exec api python scripts/import_products.py --csv data/female_daily.csv
```

Importer melakukan upsert berdasarkan `(brand, name)`, menormalkan harga ("Rp 125.000" → 125000)
dan kategori (huruf kecil), lalu menautkan teks komposisi ke tabel ingredients. Jalankan seed lebih
dulu agar tabel ingredients terisi. Untuk Docker, file CSV perlu ada di dalam image/container
(mis. taruh di `data/` lalu build ulang).

## Batasan yang diketahui

- Refresh token bersifat stateless: belum ada logout/pencabutan token di server (logout = hapus
  token di aplikasi). Token habis sendiri sesuai `ACCESS_TOKEN_EXPIRE_MINUTES` / `REFRESH_TOKEN_EXPIRE_DAYS`.
- Rate limiter disimpan di memori satu proses. Jika memakai banyak worker/instance, pindahkan ke Redis.
  Jika API dipasang di belakang reverse proxy (nginx, dsb.), jalankan uvicorn dengan
  `--forwarded-allow-ips` agar rate limit memakai IP asli klien, dan batasi juga ukuran body di proxy.
- Model branch Rafazl hanya memprediksi jenis kulit (4 kelas) dan di notebook hanya diuji dengan foto
  wajah; validitasnya untuk area tangan/punggung/kaki belum dikonfirmasi tim ML.
