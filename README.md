# eBiblioteka

Seminarski rad iz predmeta **Razvoj softvera 2** na Fakultetu informacijskih tehnologija u Mostaru

---

## Upute za pokretanje aplikacije

### Korak 1: Priprema backend i mobile okruženja
1. Raspakirajte arhive `fit-build-2025-06-14-env-backend.zip` i `fit-build-2025-06-14-env-mobile.zip` u istim direktorijima gdje se nalaze njihovi ZIP fajlovi
2. Otvorite terminal u `\eBiblioteka` direktoriju
3. Pokrenite Docker komandu:
   ```bash
   docker-compose up --build
   ```
4. Sačekajte da se aplikacija u potpunosti izgradi

### Korak 2: Desktop aplikacija (Administratorska)
1. Raspakirajte arhivu `fit-build-2025-06-14-desktop.zip`
2. Otvorite `ebiblioteka_admin.exe` iz direktorija `\build\windows\x64\runner\Release`

### Korak 3: Mobile aplikacija
1. Raspakirajte arhive `fit-build-2025-06-14-mobile.z01` i `fit-build-2025-06-14-mobile.zip`
2. Prenesite `app-release.apk` iz direktorija `\build\app\outputs\flutter-apk` u Android emulator
3. Instalirajte aplikaciju

---

## Podaci za prijavu

### Desktop aplikacija (Administrator)
- **Korisničko ime:** `admin`
- **Šifra:** `admin`

### Mobile aplikacija (Korisnik)
- **Korisničko ime:** `korisnik`
- **Šifra:** `korisnik`

---

## PayPal login podaci

Za testiranje PayPal funkcionalnosti koristite sledeće podatke:

- **Email:** `sb-dn94s43638564@business.example.com`
- **Password:** `buh(!S<4`

> **Napomena:** PayPal plaćanje je omogućeno na ekranu za članarinu u mobilnoj aplikaciji nakon što korisnik izabere odgovarajući tip članarine.

---

##  Funkcionalnosti

- **Desktop aplikacija** - Administratorski panel za upravljanje bibliotekom
- **Mobile aplikacija** - Korisnička aplikacija za pretragu i rezervaciju knjiga
- **PayPal integracija** - Sigurno plaćanje članarine
- **Docker podrška** - Jednostavno pokretanje backend servisa

---

##  Tehnologije

- **Backend:** Docker, REST API, .NET
- **Baza podataka:** Microsoft SQL Server (MSSQL)
- **Desktop:** Flutter (Windows)
- **Mobile:** Flutter (Android)
- **Payment:** PayPal SDK
