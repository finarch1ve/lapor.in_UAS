# Setup Guide Supabase untuk E-Ticketing Helpdesk

Guide ini membantu setup Supabase project untuk aplikasi E-Ticketing Helpdesk.

---

## 1. Buat Supabase Project

1. Buka [https://supabase.com](https://supabase.com)
2. Sign up atau login
3. Klik **"New Project"**
4. Isi project details:
   - **Organization**: Pilih atau buat organization baru
   - **Name**: `ticketing-uts` (atau nama lain)
   - **Database Password**: Buat password yang kuat dan **simpan**!
   - **Region**: Pilih region terdekat (Singapore/Jakarta)
5. Tunggu database provisioning (± 2-3 menit)

---

## 2. Jalankan Database Schema

1. Di Supabase dashboard, buka menu **SQL Editor** di sidebar kiri
2. Klik **"New Query"**
3. Copy isi file `supabase_schema.sql` dari project root
4. Paste ke SQL Editor
5. Klik **"Run"** atau tekan `Ctrl + Enter`

Schema yang dibuat:
- ✅ `users` - User profiles dengan role (user/helpdesk/admin)
- ✅ `tickets` - Tickets dengan status & category
- ✅ `comments` - Comments per ticket
- ✅ `ticket_history` - Activity history
- ✅ `notifications` - User notifications
- ✅ Storage buckets untuk images
- ✅ RLS policies untuk security
- ✅ Triggers & functions

---

## 3. Dapatkan Supabase Credentials

1. Di Supabase dashboard, buka **Settings** → **API**
2. Copy values berikut:

| Field | Contoh Value |
|-------|-------------|
| **Project URL** | `https://xxxxx.supabase.co` |
| **anon/public key** | `eyJhbGci...` (panjang) |

---

## 4. Update Flutter Project

1. Buka file `lib/config/supabase_config.dart`
2. Replace dengan credentials dari step 3:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xxxxx.supabase.co';
  static const String supabaseKey = 'eyJhbGci...';
  
  // ... rest of code
}
```

3. Jalanakan `flutter pub get` jika belum

---

## 5. Buat Admin User Pertama

### Option A: Via SQL (Recommended)

1. Di Supabase SQL Editor, jalankan:

```sql
-- 1. Sign up dulu via app atau auth API
-- Setelah punya user ID, jalankan:

UPDATE public.users
SET role = 'admin'
WHERE email = 'admin@example.com';
```

### Option B: Via Flutter App

1. Run app: `flutter run`
2. Register new user
3. Di Supabase SQL Editor, update role:

```sql
UPDATE public.users
SET role = 'admin'
WHERE email = 'your_email@example.com';
```

### Option C: Via Supabase Dashboard

1. Di Supabase, buka **Authentication** → **Users**
2. Klik user yang ingin jadi admin
3. Di **Raw User Metadata**, add: `{"role": "admin"}`
4. Lalu di SQL Editor:

```sql
UPDATE public.users
SET role = 'admin'
WHERE email = 'email_yang_dipilih@example.com';
```

---

## 6. Setup Storage untuk Images

Storage buckets sudah otomatis dibuat via schema. Verifikasi:

1. Buka **Storage** di sidebar
2. Pastikan ada bucket:
   - `ticket_images` (public)
   - `user_avatars` (public)

---

## 7. Test Connection

Run aplikasi dan test:

```bash
flutter run
```

Cek:
- ✅ Register new user → berhasil
- ✅ Login dengan user tersebut → berhasil
- ✅ Dashboard menampilkan data → berhasil

---

## 8. Buat Helpdesk User (Optional)

Untuk testing helpdesk features:

```sql
-- Register dulu via app, lalu update role
UPDATE public.users
SET role = 'helpdesk'
WHERE email = 'helpdesk@example.com';
```

---

## Troubleshooting

### Error: "Invalid API Key"
- Pastikan `supabaseKey` menggunakan `anon/public key`, BUKAN `service_role key`

### Error: "Table not found"
- Pastikan schema SQL sudah di-run
- Cek di Table Editor di Supabase dashboard

### Error: "Permission denied"
- Pastikan RLS policies sudah dibuat
- Cek di Authentication → User punya role yang benar

### Error: "Storage policy violation"
- Pastikan storage bucket ada dan public
- Cek policies di Storage → bucket name → Policies

---

## Environment Variables (Optional)

Untuk production, gunakan environment variables:

1. Install `flutter_dotenv`
2. Buat `.env` file (add to .gitignore!)
3. Load di `main.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load(fileName: ".env");
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_KEY']!,
);
```

---

## Next Steps

Setelah setup selesai:
1. Test semua user flows (register, login, create ticket)
2. Test admin features (user management, ticket assignment)
3. Test helpdesk features (assigned tickets, update status)
4. Test notifications

---

## Dashboard Supabase

URL dashboard kamu:
```
https://supabase.com/dashboard/project/YOUR_PROJECT_REF
```

Simpan URL ini untuk akses cepat ke:
- Table Editor
- SQL Editor
- Authentication → Users
- Storage
- API Settings
