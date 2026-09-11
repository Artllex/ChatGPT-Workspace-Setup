# Instalacja i zmiana folderów

Zalecana wersja: uruchom `dist\ChatGPT-Workspace-Setup-1.1.6.exe`.
Jest to standardowy instalator Windows po angielsku i polsku. Angielski jest
wybrany domyślnie. Instalator tworzy również wpis w
Zainstalowanych aplikacjach, skrótami menu Start i deinstalatorem.

Produkt nazywa się **ChatGPT Workspace Setup**. Domyślny katalog główny to `C:\CODE`.
Jego zmiana wylicza `temp` i `inbox`, po czym obie ścieżki możesz zmienić ręcznie.
Przy kolejnym uruchomieniu konfigurator wczyta zapisane wartości.

Przycisk **Zainstaluj / zapisz** tworzy foldery i instaluje narzędzie dla bieżącego
użytkownika w `%LOCALAPPDATA%\Programs\ChatGPTFolderLauncher` (ścieżka techniczna
zachowana dla zgodności aktualizacji).
Na pulpicie tworzy skróty **ChatGPT - foldery** i **ChatGPT - ustawienia folderów**.
Drugi skrót pozwala ponownie otworzyć konfigurator i zmienić foldery.
Instalator pokazuje osobny ekran z czytelnym wyborem utworzenia albo pominięcia
skrótu na pulpicie.
Program nie wymaga uruchomienia jako administrator. Wybieraj foldery, do których masz dostęp.

Zapis ustawień działa również podczas pracy ChatGPT. Nowy TEMP oraz inbox zostaną
zastosowane przy kolejnym uruchomieniu przez **ChatGPT - foldery**, po całkowitym
zamknięciu aplikacji. Nie przenosi to istniejących zadań ani plików.
TEMP/TMP innych aplikacji i ustawienia systemowe nie są zmieniane.

Konfiguracja jest zapisywana w `folders.xml`. Poprzedni zapis pozostaje w
`folders.xml.previous`. Launcher tworzy kopię konfiguracji ChatGPT przed zmianą inbox.
Nie uruchamiaj kilku konfiguratorów jednocześnie.

Wersję z `dist` usuwa się standardowo w Ustawienia > Aplikacje > Zainstalowane aplikacje.
Wybrane foldery TEMP/inbox i wszystkie dane pozostają. Inbox można zmienić w ustawieniach
ChatGPT; standardowy skrót aplikacji przywraca dziedziczenie zwykłego TEMP.

Plik EXE jest niepodpisany cyfrowo. Źródła: `FolderSetup.cs`, `Start-ChatGPT.ps1`
i `installer\setup.iss`. Ponowna kompilacja: `Build-Installer.ps1`.

Testy obejmują zapis i ponowne wczytanie folderów, zmianę inbox przy ponownej instalacji,
tworzenie skrótów w izolowanym katalogu testowym, edycję TOML i przekazywanie TEMP/TMP.
Rzeczywiste uruchomienie ChatGPT i podgląd pliku należy sprawdzić po instalacji i restarcie.
