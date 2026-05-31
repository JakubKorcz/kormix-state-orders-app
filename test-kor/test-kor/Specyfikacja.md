# Specyfikacja projektu "KORMIX Planer"

## 1. Krótki opis projektu

KORMIX Planer to aplikacja mobilna na systemy iOS i iPadOS służąca do śledzenia i zarządzania harmonogramem wywozu odpadów komunalnych. Aplikacja umożliwia użytkownikom dodawanie adresów, konfigurację częstotliwości wywozu, automatyczne obliczanie kolejnych terminów z uwzględnieniem polskich świąt i dni roboczych, ręczne ustawianie dat, potwierdzanie wykonanych wywozów oraz przeglądanie historii. Dane przechowywane są lokalnie w bazie SwiftData, a dostęp do aplikacji może być zabezpieczony kodem PIN haszowanym algorytmem SHA256.

---

## 2. Wymagania funkcjonalne

**F1 – Zarządzanie harmonogramami wywozu.** Użytkownik może dodawać nowe adresy wraz z datą ostatniego wywozu i częstotliwością w dniach, edytować istniejące wpisy oraz usuwać je.

**F2 – Automatyczne obliczanie dat następnego wywozu.** System automatycznie oblicza kolejne terminy wywozu na podstawie daty ostatniego odbioru i częstotliwości, z uwzględnieniem wyłącznie dni roboczych oraz polskich świąt państwowych i ruchomych (Wielkanoc, Poniedziałek Wielkanocny, Boże Ciało).

**F3 – Ręczne ustawienie daty wywozu.** Użytkownik może ręcznie nadpisać datę następnego wywozu dla wybranego adresu, niezależnie od automatycznych obliczeń.

**F4 – Potwierdzanie wykonania wywozu i historia.** Użytkownik może potwierdzić wykonanie wywozu, co aktualizuje datę ostatniego odbioru na zaplanowaną oraz zapisuje zdarzenie w historii wraz z datą potwierdzenia. Historia wywozów jest dostępna do przeglądania.

---

## 3. Wymagania pozafunkcjonalne

**NF1 – Dostęp offline.** Aplikacja działa w pełni offline – wszystkie dane przechowywane są lokalnie w bazie SwiftData (SQLite). Brak konieczności połączenia z internetem.

**NF2 – Bezpieczeństwo danych dostępu.** Kod PIN przechowywany jest wyłącznie w postaci skrótu SHA256 (CryptoKit), nigdy w formie jawnego tekstu.

---

## 4. Potencjalni odbiorcy systemu

**Zarząd firmy Kormix.** 

---

## 5. Potencjalne korzyści biznesowe

**K1 – Eliminacja ryzyka przegapienia terminu wywozu.** Automatyczne obliczanie terminów z uwzględnieniem świąt i dni roboczych minimalizuje ryzyko pominięcia wywozu i związanego z tym gromadzenia odpadów.

**K2 – Oszczędność czasu i wygoda.** Użytkownik nie musi ręcznie śledzić kalendarza wywozów – aplikacja automatycznie wylicza kolejne daty i przypomina o zaległych terminach poprzez wizualne oznaczenia (kolor czerwony dla zaległych).

