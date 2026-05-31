# Dokumentacja techniczna – KORMIX Planer

## 1. Stos technologiczny

Aplikacja została zbudowana w języku **Swift** z wykorzystaniem frameworka **SwiftUI** dostępnego od iOS 18.4 do budowy deklaratywnego interfejsu użytkownika. Do trwałego przechowywania danych wykorzystano **SwiftData** (również od iOS 18.4) będący osadzonym w języku ORM na bazie SQLite. Mechanizm haszowania kodu PIN zrealizowano przy użyciu **CryptoKit** (algorytm SHA256). Podstawowe operacje na datach i typach danych oparto na frameworku **Foundation**.

Brak zależności zewnętrznych – aplikacja korzysta wyłącznie z frameworków Apple.

---

## 2. Architektura aplikacji

Aplikacja zbudowana w oparciu o architekturę MV (Model-View) z SwiftData jako warstwą modelu. SwiftUI pełni rolę zarówno widoku, jak i kontrolera poprzez mechanizmy @Query, @Bindable.

Głównym punktem wejścia jest struktura test_korApp zgodna z protokołem App, która konfiguruje modelContainer dla modeli Schedule i PickupHistory, ustawia polski locale oraz zielony kolor akcentu. Nakłada ona również pełnoekranową blokadę PinLockView, gdy PIN jest ustawiony, a aplikacja przechodzi do stanu background lub inactive.

Z poziomu DashboardView, będącego głównym ekranem z listą harmonogramów, użytkownik może nawigować do DetailView celem edycji lub potwierdzenia wywozu. DashboardView otwiera również arkusze (sheets) dla AddScheduleView (dodawanie nowego adresu), PickupHistoryView (historia wywozów) oraz PinSettingsView (zarządzanie PIN-em). PinLockView wyświetlany jest jako pełnoekranowa nakładka nad całym interfejsem.

Warstwa modelu składa się z dwóch klas SwiftData: Schedule (harmonogram dla pojedynczego adresu) i PickupHistory (rekord potwierdzonego wywozu). Kontekst modelu (modelContext) zarządza cyklem życia obiektów i automatycznie zapisuje zmiany do bazy SQLite.

Warstwa pomocnicza zawiera rozszerzenie Calendar odpowiedzialne za logikę polskich dni roboczych i świąt oraz enum PinManager realizujący bezpieczne przechowywanie i weryfikację kodu PIN.

---

## 3. Opis klas modelu danych

### 3.1 Schedule (schedule.swift)

Klasa modelu SwiftData reprezentująca pojedynczy harmonogram wywozu dla jednego adresu. Zawiera cztery właściwości: address typu String przechowujący adres lokalizacji, frequencyDays typu Int określający częstotliwość wywozu w dniach od 1 do 60, lastPickupDate typu Date przechowujący datę ostatniego wywozu oraz choosenNextPickupDate typu Date? będący opcjonalną ręcznie ustawioną datą następnego wywozu.

Klasa udostępnia trzy właściwości obliczane: hasManualDate typu Bool zwracająca true jeśli choosenNextPickupDate nie jest nil, nextPickupDate typu Date zwracająca ręcznie ustawioną datę lub automatycznie wyliczoną najbliższą datę roboczą z wykorzystaniem rozszerzenia Calendar, oraz effectiveNextDate będąca aliasem dla nextPickupDate.

### 3.2 PickupHistory (PickupHistory.swift)

Klasa modelu SwiftData reprezentująca pojedynczy rekord potwierdzonego wywozu. Zawiera trzy właściwości: executionDate typu Date określająca datę wykonania usługi wywozu, address typu String przechowująca adres dla którego wykonano wywóz, oraz confirmedAt typu Date przechowująca datę i godzinę potwierdzenia przez użytkownika.

### 3.3 PinManager (PinManager.swift)

Enum bez przypadków pełniący rolę statycznego menedżera PIN. Wykorzystuje CryptoKit (SHA256) do przechowywania hasza PIN w UserDefaults.

Udostępnia pięć metod statycznych: isPinSet (Bool) sprawdza czy PIN został ustawiony, storePin przyjmuje string i zapisuje jego hasz, verifyPin przyjmuje string i weryfikuje go z zapisanym haszem zwracając Bool, removePin usuwa zapisany PIN, changePin przyjmuje stary i nowy PIN, weryfikuje stary i po pomyślnej weryfikacji zapisuje nowy zwracając Bool. Prywatna metoda hash przyjmuje string i zwraca jego skrót SHA256 jako szesnastkowy string.

### 3.4 Calendar extension (Calendar.swift)

Rozszerzenie klasy Foundation.Calendar o logikę polskich dni roboczych. Zawiera trzy metody: isWorkDay sprawdzająca czy data jest dniem roboczym (nie weekend i nie święto), findNearestWorkDay znajdująca najbliższy dzień roboczy względem podanej daty poprzez wyszukiwanie dwukierunkowe z maksymalnym zasięgiem 14 dni, oraz prywatną calculateEaster obliczającą datę Wielkanocy algorytmem Gaussa.

Obsługiwane święta stałe to: Nowy Rok (1 stycznia), Trzech Króli (6 stycznia), 1 Maja, 3 Maja, Wniebowzięcie Najświętszej Maryi Panny (15 sierpnia), Wszystkich Świętych (1 listopada), Narodowe Święto Niepodległości (11 listopada) oraz Boże Narodzenie (25 i 26 grudnia). Święta ruchome obejmują Wielkanoc, Poniedziałek Wielkanocny i Boże Ciało wyliczane algorytmem Gaussa.

---

## 4. Opis widoków SwiftUI

### 4.1 test_korApp (test_korApp.swift)

Punkt wejścia aplikacji. Konfiguruje modelContainer dla modeli Schedule i PickupHistory, ustawia polski locale (pl_PL) dla formatowania dat oraz zielony kolor akcentu o wartości #006600. Wyświetla nakładkę PinLockView jako fullScreenCover gdy PIN jest ustawiony, a aplikacja jest zablokowana. Nasłuchuje zmian scenePhase i automatycznie blokuje aplikację przy przejściu do stanu background lub inactive.

### 4.2 DashboardView (DashboardView.swift)

Główny ekran aplikacji wyświetlający listę adresów posortowanych według najbliższej daty wywozu (effectiveNextDate). Pasek narzędzi zawiera przyciski do otwierania historii wywozów, ustawień PIN oraz dodawania nowego adresu. Każdy wiersz listy pokazuje adres, częstotliwość w dniach, datę ostatniego i następnego wywozu. Daty są kolorowane: pomarańczowy gdy data została ustawiona ręcznie, czerwony gdy termin jest zaległy (przed dzisiejszą datą) oraz podstawowy (primary) gdy termin jest w przyszłości.

### 4.3 DetailView (DetailView.swift)

Ekran edycji istniejącego harmonogramu. Umożliwia edycję adresu poprzez TextField, daty ostatniego wywozu poprzez DatePicker oraz częstotliwości poprzez Stepper z zakresem od 1 do 60 dni. Zawiera sekcję ręcznego ustawienia najbliższego wywozu z togglem i DatePicker aktywowanym po włączeniu opcji. Wyświetla sekcję nadchodzących terminów z pięcioma kolejnymi datami obliczonymi z uwzględnieniem dni roboczych, gdzie najbliższy termin oznaczony jest etykietą NAJBLIŻSZY.

Gdy termin wywozu jest zaległy, widok pokazuje zielony przycisk do potwierdzenia wykonania wywozu. Po kliknięciu zapisywany jest rekord w PickupHistory (z zabezpieczeniem przed duplikatami), data ostatniego wywozu jest aktualizowana na zaplanowaną, a ewentualna ręcznie ustawiona data jest czyszczona.

### 4.4 AddScheduleView (AddScheduleView.swift)

Formularz dodawania nowego adresu zawierający pole tekstowe dla adresu, DatePicker dla daty ostatniego wywozu (z ograniczeniem do dat przeszłych) oraz Stepper dla częstotliwości (domyślnie 14 dni). Sekcja podglądu wyświetla na żywo obliczoną datę następnego wywozu. Przycisk Zapisz jest nieaktywny gdy pole adresu jest puste.

### 4.5 PickupHistoryView (PickupHistoryView.swift)

Lista potwierdzonych wywozów posortowana malejąco według daty wykonania, a następnie daty potwierdzenia. Każdy rekord wyświetla adres, datę wykonania wywozu oraz datę i godzinę potwierdzenia. W przypadku pustej historii wyświetlany jest komunikat z prośbą o pierwsze potwierdzenie wywozu.

### 4.6 PinLockView (PinLockView.swift)

Pełnoekranowa nakładka blokady z ikoną tarczy, tytułem aplikacji, polem SecureField do wprowadzenia PINu, przyciskiem odblokowania oraz komunikatem błędu przy nieprawidłowym PINie. Pole PIN automatycznie otrzymuje focus po pojawieniu się widoku.

### 4.7 PinSettingsView (PinSettingsView.swift)

Ekran zarządzania PIN-em. Gdy PIN nie jest ustawiony, wyświetla formularz tworzenia nowego PINu z polami dla nowego PINu i potwierdzenia. Gdy PIN jest już ustawiony, pokazuje formularz zmiany PINu (stary PIN, nowy PIN, potwierdzenie) oraz przycisk usunięcia PINu. Wszystkie pola ograniczone są do 4 cyfr, a walidacja sprawdza zgodność pól i poprawność starego PINu.

---
