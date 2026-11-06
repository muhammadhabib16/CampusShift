# Kontrak API Backend CampuShift (PRD v1.3)

Dokumen ini adalah acuan endpoint backend untuk seluruh modul. Aturan bisnis (BR), siklus status (PRD 2.6), dan parameter sistem (PRD 2.12) diterapkan di server. Daftar nilai enum ada di `src/config/constants.js`.

*Terakhir diperbarui: 5 November 2026 (gabungan pembaruan Modul 1, 4, 5 dan endpoint `/sync`).*

## Konvensi Umum

- **Base URL:**
  - Production (Cloudflare Tunnel): `https://campusshift-api.habibdev.site/api`. Ini default di `lib/services/api_config.dart`.
  - Homelab LAN: `http://<IP-homelab>:5000/api` (container `campusshift_api`, port 5000 → 3000).
  - Lokal: `http://localhost:5000/api`. Dari Android Emulator: `http://10.0.2.2:5000/api`.
  - Cek server: `GET /health` (tanpa token) → `{ "status": "success", "message": "API is running smoothly" }`.
- **Auth:** semua endpoint kecuali `POST /auth/register`, `POST /auth/login`, dan `GET /health` wajib header `Authorization: Bearer <token>`.
  - Tanpa header → `401 Unauthorized, token is missing`.
  - Token tidak valid/kedaluwarsa atau akun sudah tidak ada → `401 Sesi berakhir, silakan login kembali` (BR-A4).
- **Format response:**
  - Sukses: `{ "success": true, "message"?: "...", "data": ... }`
  - Gagal: `{ "success": false, "message": "...", "errors"?: [{ "path", "msg" }] }`. `message` selalu berisi pesan yang siap ditampilkan di SnackBar.
- **Kode status:** `400` validasi, `401` sesi, `403` bukan pihak yang berhak, `404` tidak ditemukan, `405` operasi dilarang (hapus ulasan), `409` konflik status/aturan bisnis (termasuk dua transaksi bersamaan), `410` QR kedaluwarsa, `429` terlalu banyak request.
- **Rate limit:** 1000 request/15 menit per IP untuk seluruh `/api` (`RATE_LIMIT_MAX`). Login + register 20 request/15 menit (`AUTH_RATE_LIMIT_MAX`).
- **Upload foto:** `multipart/form-data`, maksimal 5 MB per foto, format **JPEG atau PNG** saja (ekstensi `.jpg/.jpeg/.png` atau Content-Type `image/jpeg`/`image/png`). File `application/octet-stream` (bawaan `http.MultipartFile.fromPath`) tetap diterima selama ekstensinya sesuai. URL foto di response sudah berupa URL lengkap.
- **Waktu:** ISO 8601 (UTC). Aplikasi menampilkannya dalam zona waktu perangkat.
- **Alias:** beberapa endpoint punya alias (penamaan PRD, PATCH, camelCase). Alias memanggil handler yang sama, jadi bentuk response identik. Untuk kode baru pakai endpoint utama (kolom pertama).
- **Barang ditolak/dibatalkan otomatis:** server menutup permintaan lain saat barang tidak lagi Available (lihat `src/utils/item-requests.js`).

## Modul Pendukung: Auth & Profil

| Method | Endpoint | Body | Keterangan |
|---|---|---|---|
| POST | `/auth/register` | `full_name, nim, email, password` (JSON) | BR-A1/A2: NIM 10 digit, email `@student.unand.ac.id` (ubah lewat env `CAMPUS_EMAIL_DOMAIN`), password ≥ 8 dengan huruf + angka. Duplikat → `409` dengan `errors[0].path` = `email`/`nim`. |
| POST | `/auth/login` | `email` (boleh berisi email **atau** NIM; alias field `identifier`/`nim`), `password` | `data: { token, user }`. JWT berlaku 24 jam (`JWT_EXPIRES_IN`). Gagal → `401 Email/NIM atau kata sandi salah`. |
| GET | `/users/me` | — | Profil + `reputation`. Alias lama: `GET /auth/profile`. |
| PUT | `/users/me` | multipart: `full_name?`, `phone?`, file `photo?` | BR-A5: telepon diawali 08/+62, 10–14 digit. |
| PUT | `/users/me/password` | `current_password, new_password` | FR-A04 [O]. Password lama salah → `400`. |
| GET | `/users/:id` (alias `/users/:id/profile`) | query `page?` (default 1), `limit?` (default 20, maks 100) | Profil publik: `id, full_name, nim, profile_photo_url, joined_at, completed_deals, reputation { average, count, label }, score, reviewCount, reviews[]`. `score`/`reviewCount` = `reputation.average`/`reputation.count`. `reviews[]` dipaginasi. |

## Modul 1: Listing (`/items`)

Field mengikuti `ItemModel.fromJson`: `item_id, owner_user_id, owner_name, judul, deskripsi, kategori, tipe_listing, harga, terbuka_untuk_barter, kondisi, url_foto[], status, created_at, updated_at, last_listing_update_at`.

`last_listing_update_at` diperbarui saat listing dibuat atau disunting. Dipakai untuk menjadwalkan Listing Stale Alert 14 hari (FR-05).

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/items?search=&category=&type=&min_price=&max_price=` | Katalog: Available milik orang lain, terbaru dulu. `type` menerima `Jual…`, `Hibah…`, atau teks yang memuat `Barter` (tidak peka huruf besar/kecil). Alias query: `q`, `listingType`, `minPrice`, `maxPrice`. |
| GET | `/items/me?status=&type=` (alias `/items/mine`) | Barang Saya + `deal_path` (`Jual`/`Barter`/`Hibah`) untuk barang Reserved/Completed. |
| GET | `/items/:id` | Detail. Barang milik orang lain hanya terlihat selama **Available**; selain itu `404`. Pemilik selalu dapat melihat barangnya. |
| POST | `/items` | multipart: `judul, deskripsi, kategori, tipe_listing, harga, terbuka_untuk_barter, kondisi` + file `fotos` 2–3 kali. Hibah otomatis harga 0 dan tidak terbuka barter. |
| PUT | `/items/:id` | Sama seperti POST; `fotos` opsional (bila dikirim, seluruh foto diganti). Hanya Available/Archived tanpa permintaan aktif. |
| PUT/PATCH | `/items/:id/archive` | Available → Archived; ajakan Diajukan dibatalkan, tawaran & klaim menunggu ditolak. |
| PUT/PATCH | `/items/:id/activate` | Archived → Available. |
| DELETE | `/items/:id` | Hapus permanen (BR-04). Tidak bisa untuk barang yang pernah Completed atau masih punya permintaan aktif (`409`). |
| GET | `/items/:id/claims?status=` | Antrean klaim, khusus donatur (Modul 5). |

**Alias field form (POST/PUT):** `title`, `description`, `category`, `listingType` (`Jual`/`Hibah`/`hibah`), `price`, `condition`, `isOpenForBarter`, dan file `photos`. Bila nama Indonesia dan alias dikirim bersamaan, nama Indonesia yang dipakai. Total foto (`fotos` + `photos`) tetap 2–3.

## Modul 2: Safe-Meet Point & Pertemuan

`GET /safe-meet-points`, `GET /safe-meet-points/:id`: field mengikuti `SafeMeetPoint.fromJson`. Data berasal dari `prisma/seed.js`; tidak ada endpoint tambah titik temu.

Field pertemuan mengikuti `Meetup.fromJson`. `item_type` = jalur transaksi (`Jual`/`Barter`/`Hibah`), `item_price` berupa angka, ditambah `deal_id`, `claim_id`, `updated_at`.

| Method | Endpoint | Body | Keterangan |
|---|---|---|---|
| POST | `/meetups` | salah satu dari `item_id` (Jual) / `deal_id` (Barter Locked, oleh Pengaju) / `claim_id` (klaim Approved, oleh pemohon) + `point_id, scheduled_time, notes?` | BR-07 (1 jam – 14 hari), BR-08. |
| GET | `/meetups/me?role=requester\|owner&status=` | — | Tanpa `role` = keduanya. |
| GET | `/meetups/:id` | — | |
| PUT | `/meetups/:id` | `point_id?, scheduled_time?, notes?` | Peminat, selama Diajukan. |
| DELETE | `/meetups/:id` | — | Peminat, selama Diajukan (BR-13). |
| PUT | `/meetups/:id/confirm` | — | Pemilik. Jalur Jual: barang Reserved, ajakan lain Dibatalkan. |
| PUT | `/meetups/:id/reject` | `reason?` | Pemilik → Ditolak. |
| PUT | `/meetups/:id/cancel` | `reason?` | Salah satu pihak, Dikonfirmasi → Dibatalkan (BR-10). QR aktif ikut tidak berlaku. |

Ajakan Diajukan yang waktunya lewat otomatis Dibatalkan saat data pertemuan dibaca (BR-09).

## Modul 3: Barter (`/barters`)

Response dilihat dari sisi pengguna yang login (mengikuti `BarterDeal.fromJson`): `id, status, status_label, is_sent_by_me, partner_user_id, partner_name, my_item, partner_item, cash_top_up, top_up_payer, top_up_paid_by_me, my_confirmed, partner_confirmed, last_offer_by_me, condition_proof_url, reason, can_confirm, can_negotiate, can_reject, can_delete, can_cancel, created_at, updated_at`.

- `status` memakai nilai PRD (`Pending, Negotiating, Locked, Rejected, Cancelled, Completed`); `status_label` berisi label aplikasi (`Menunggu, Negosiasi, Terkunci, Ditolak, Dibatalkan, Selesai`).
- `my_item`/`partner_item`: `{ id, name, price, category, condition, status, photo_url }`.
- Flag `can_*` adalah aksi yang diizinkan server; tombol di aplikasi cukup mengikuti flag ini.

| Method | Endpoint | Body | Keterangan |
|---|---|---|---|
| POST | `/barters` | `receiver_item_id, sender_item_id, cash_top_up?, top_up_payer?` (JSON, atau multipart + file `condition_proof`) | BR-14/15/16. `top_up_payer`: `Sender`/`Receiver`, wajib bila top-up > 0. Top-up Rp0–5.000.000, kelipatan Rp1.000. |
| GET | `/barters/me?box=incoming\|outgoing&status=` | — | |
| GET | `/barters/:id` | — | |
| PUT | `/barters/:id/negotiate` | `cash_top_up, top_up_payer?` | Tawaran balik → Negotiating, kedua konfirmasi direset. Pengaju yang merevisi sebelum ditanggapi tetap Pending. |
| POST | `/barters/:id/confirm` | — | Dual-confirmation. Konfirmasi kedua → Locked, kedua barang Reserved, tawaran lain atas barang itu Rejected. Bila barang sudah tidak tersedia → `409` dan tawaran Rejected (BR-19). |
| PUT | `/barters/:id/reject` | `reason?` | Penerima. |
| PUT | `/barters/:id/cancel` | `reason?` | Pengaju (sudah ditanggapi), atau salah satu pihak bila Locked (barang kembali Available, pertemuan terkait Dibatalkan). |
| DELETE | `/barters/:id` | — | Pengaju, Pending dan belum ditanggapi (BR-20). |

## Modul 4: Serah Terima QR & Ulasan

Token mengikuti `HandoverTokenModel.fromJson`: `token_id` dan `meetup_id` berupa string, `status` huruf kecil (`active, used, expired, cancelled`).

| Method | Endpoint utama | Alias | Body | Keterangan |
|---|---|---|---|---|
| POST | `/handover/session` | `/meetups/:meetupId/handover-token` | `meetup_id` (tidak perlu pada alias) | Pemilik, pertemuan Dikonfirmasi. Token acak berlaku 5 menit; token lama otomatis expired (BR-21). |
| DELETE | `/handover/session/:tokenId` | `/meetups/:meetupId/handover-token` | — | Batalkan sesi QR (token dihapus). Alias menghapus token aktif terbaru pada pertemuan itu. Token sudah dipakai → `409`. |
| GET | `/handover/status/:meetupId?token_id=` | `/meetups/:meetupId/handover-token` | — | Dipanggil layar QR tiap 3 detik. `data: { token_id, status, proof_number, used_at, expires_at, meetup_status, ... }`. Token terhapus → `status: "cancelled"`. |
| POST | `/handover/verify` | `/handover/scan` | `token` (isi QR), `meetup_id?` | Peminat. Berhasil → `data: { meetup_id, proof_number, used_at, status: "used" }`. Gagal (BR-22): token tidak dikenal `400 QR tidak valid`, bukan peminat pertemuan itu `403`, sudah dipakai `409`, kedaluwarsa `410`, pertemuan bukan Dikonfirmasi `409`. |
| GET | `/handover/history` | `/handover-receipts` | — | Bukti serah terima: `meetup_id, proof_number, validated_at, item_type, items[], item_price, cash_top_up, owner, requester, partner, safe_meet_point, my_review, partner_review`. |
| GET | `/handover/history/:meetupId` | `/handover-receipts/:meetupId` | — | Satu bukti. |

Verifikasi berhasil mencatat bukti di tabel `HANDOVER_RECEIPTS` (`receipt_number` = `proof_number`) dalam transaksi yang sama: pertemuan Selesai, barang Completed, barter/klaim Completed. Pemindaian bersamaan atas token yang sama dikunci di database, jadi hanya satu yang berhasil.

| Method | Endpoint | Body | Keterangan |
|---|---|---|---|
| GET | `/reviews?meetupId=` (atau `meetup_id`) | — | Ulasan untuk satu transaksi, hanya untuk kedua pihaknya. Tanpa `meetupId` → `400`. |
| POST | `/reviews` | `meetup_id, rating (1–5), comment?` (≤ 500) | Sekali per pihak per transaksi Selesai. |
| PUT | `/reviews/:id` | `rating?, comment?` | Sekali, maksimal 7 hari; `is_edited = true`. |
| DELETE | `/reviews/:id` | — | Selalu `405`: ulasan permanen (BR-26). |

## Modul 5: Klaim Hibah (`/claims`)

Barang hibah adalah Item dengan `tipe_listing = Hibah` (katalog: `GET /items?type=Hibah`). Field klaim: `id, item_id, item_title, item_photo_url, donor_user_id, donor_name, item_status, applicant_user_id, urgency_category, justification_text, status, reason, created_at, updated_at`. Antrean donatur menambahkan `applicant { id, name, nim, photo_url, reputation }`.

| Method | Endpoint | Body | Keterangan |
|---|---|---|---|
| POST | `/claims` | `item_id, urgency_category (Mendesak/Sedang/Rendah), justification_text (100–1.000)` | 1 klaim per barang, maksimal 3 klaim aktif (Pending/Approved). Klaim yang pernah **Cancelled** dapat diajukan lagi: data klaim lama dipakai ulang dan kembali Pending. |
| GET | `/claims/me?status=` (alias `/claims/mine`) | — | |
| GET | `/claims/:id` | — | Pemohon atau donatur. |
| PUT | `/claims/:id` | `urgency_category?, justification_text?` | Pemohon, selama Pending. |
| DELETE | `/claims/:id` | — | Pemohon, selama Pending. |
| PUT/PATCH | `/claims/:id/approve` | — | Donatur. Barang Reserved, klaim lain Rejected. |
| PUT/PATCH | `/claims/:id/reject` | `reason?` | Donatur. |
| PUT/PATCH | `/claims/:id/cancel` | `reason?` | Salah satu pihak, Approved → Cancelled; barang kembali Available dan pertemuan pengambilan Dibatalkan. |

## Sinkronisasi Notifikasi (`/sync`)

Notifikasi berbasis sinkronisasi (PRD 2.8, NFR-07: N-02 Meeting, N-03 Barter Alert, N-06 Claim Status Alert) cukup memakai satu endpoint, dipanggil saat aplikasi dibuka, kembali aktif, pull-to-refresh, dan tiap ±60 detik.

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/sync?since=<ISO 8601>` | Data yang berubah setelah `since`: `{ server_time, since, meetups[], barters[], claims[], incoming_claims[] }`. Bentuk tiap entri sama dengan endpoint modulnya; `incoming_claims` (klaim atas barang hibah milik sendiri) menambahkan `applicant { id, name }`. Tanpa `since` → seluruh data (baseline awal, jangan memicu notifikasi). `since` tidak valid → `400`. |

Simpan `server_time` dari response sebagai `since` untuk panggilan berikutnya, lalu bandingkan status tiap entri dengan data lokal untuk menentukan notifikasi. Data yang dihapus permanen (tawaran ditarik, ajakan/klaim dihapus) tidak muncul di response.

## Deploy & Perubahan Skema

Setiap kali `prisma/schema.prisma` berubah, database harus diperbarui setelah container di-build ulang. Kalau tidak, endpoint gagal `500` dengan log `The column ... does not exist in the current database`.

```bash
cd ~/be-campusshift && git pull
cd ~/infrastruktur/database && docker compose up -d --build --no-deps backend-campusshift
docker exec -it campusshift_api npx prisma db push
```

Perubahan skema terakhir (27 Okt 2026): kolom `last_listing_update_at` (USERS, ITEMS), `used_by_id` (HANDOVER_TOKENS), tabel `HANDOVER_RECEIPTS`, dan unique `(item_id, applicant_id)` di CLAIMS. Bila `db push` menolak karena unique CLAIMS, berarti ada data klaim ganda; bersihkan dulu sebelum memakai `--accept-data-loss`.

## Pengujian

- `npm test`: pemeriksaan cepat tanpa database (endpoint privat menolak request tanpa token).
- `npm run test:e2e`: alur lengkap semua modul terhadap server yang sedang berjalan. Pakai database khusus pengujian dan `AUTH_RATE_LIMIT_MAX=1000`. Detail di `docs/backend_update_logs.md`.

## Penyesuaian yang Diperlukan di Aplikasi Flutter

Backend mengikuti PRD v1.3. Bagian aplikasi berikut masih mengikuti rancangan lama atau data contoh:

1. **`ApiClient` (Modul 5)** membaca body langsung sebagai list/objek. Ambil `body['data']` di `_handle`.
2. **Modul 5** masih memakai entitas `SocialGrant` dan `/grant-claims`. Sesuai PRD v1.3, hibah memakai Item bertipe Hibah: `GET /grants` → `GET /items?type=Hibah`, `POST /grant-claims` → `POST /claims` (`grant_id` → `item_id`), `GET /grants/:id/claims` → `GET /items/:id/claims`, `PUT /grant-claims/:id/approve|reject` → `PUT /claims/:id/approve|reject`, `approval_status` → `status`. Voice note dan Digital Claim Pass Code tidak ada lagi (out of scope v1.3; bukti pengambilan memakai QR Modul 4).
3. **`HandoverService.checkTokenStatus`** membaca `status` dan `proof_number` dari root body; pindahkan ke `body['data']`.
4. **`BarterDeal.fromJson`** mewajibkan `date_label`. Bentuk label dari `created_at`, dan isi `status` dari `status_label` (atau ubah pembanding ke nilai PRD). `BarterService` masih data contoh.
5. **`Meetup.fromJson`** membaca `item_price` sebagai String, sedangkan backend mengirim angka. Format harga di aplikasi. `MeetupRepository` masih in-memory dan perlu diganti service ke `/meetups` dan `/safe-meet-points`.
6. **Validasi form registrasi** perlu disamakan: password ≥ 8 dengan huruf + angka, NIM 10 digit, email `@student.unand.ac.id`.
7. **Notifikasi sinkronisasi** (`grant_notification_service.dart`, `notification_service.dart`): ganti pemanggilan `/items/:id/claims` per barang dengan satu `GET /sync?since=`.
8. **Foto** hanya JPEG/PNG. Pastikan `image_picker` tidak menghasilkan HEIC/WebP; set `imageQuality` agar hasilnya JPEG.
9. **Detail barang** (`GET /items/:id`) milik orang lain yang sudah Reserved/Completed kini `404`. Layar barter/pertemuan/riwayat sebaiknya memakai data barang yang sudah ada di response modulnya.
