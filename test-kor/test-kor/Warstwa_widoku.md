# Warstwa widoku 

**F1 – Zarządzanie harmonogramami wywozu.** Wymaganie to jest realizowane przez trzy widoki. DashboardView wyświetla listę wszystkich adresów przy użyciu ForEach w komponencie List i umożliwia usuwanie harmonogramów poprzez przesunięcie palcem (onDelete). AddScheduleView udostępnia formularz dodawania nowego adresu z polami TextField dla adresu, DatePicker dla daty ostatniego wywozu, Stepper dla częstotliwości oraz przyciskiem Zapisz. DetailView pozwala na edycję istniejącego harmonogramu z tymi samymi kontrolkami.

**F2 – Automatyczne obliczanie dat następnego wywozu.** Wymaganie to jest widoczne w trzech miejscach. AddScheduleView w sekcji Następny termin wyświetla na żywo obliczoną datę kolejnego wywozu zaraz po zmianie pól formularza. DetailView w sekcji Nadchodzące terminy pokazuje pięć kolejnych terminów z uwzględnieniem dni roboczych i świąt, oznaczając najbliższy etykietą NAJBLIŻSZY. DashboardView dla każdego adresu wyświetla kolumnę Następny z najbliższą datą wywozu, kolorując ją pomarańczowo dla dat ręcznych i czerwono dla zaległych.

**F3 – Ręczne ustawienie daty wywozu.** DetailView zawiera sekcję Ręczne ustawienie najbliższego wywozu z toggle, który po włączeniu odsłania DatePicker umożliwiający wybór własnej daty. Wybrana data nadpisuje automatyczne obliczenia aż do momentu potwierdzenia wywozu.

**F4 – Potwierdzanie wywozu i historia.** DetailView wyświetla przycisk Potwierdź wykonanie wywozu, widoczny tylko gdy termin jest zaległy. Po kliknięciu zapisywany jest rekord w PickupHistory i aktualizowana data ostatniego wywozu. PickupHistoryView wyświetla listę wszystkich potwierdzonych wywozów z adresem, datą wykonania i datą potwierdzenia. DashboardView zapewnia dostęp do historii poprzez przycisk z ikoną zegara na pasku narzędzi, który otwiera PickupHistoryView w arkuszu.

Dodatkowe widoki wspierające to PinLockView, który stanowi pełnoekranową nakładkę blokady PIN zabezpieczającą dostęp do aplikacji, PinSettingsView umożliwiający tworzenie, zmianę i usuwanie PINu, oraz test_korApp będący punktem wejścia konfigurującym modelContainer, polski locale, zielony kolor akcentu i mechanizm blokady.

---
