# Projektowanie Obiektowe

## **ZADANIE 1** Paradygmaty

Proszę napisać program w Pascalu, który zawiera dwie procedury.
Jedna generuje listę 50 losowych liczb od 0 do 100.
Druga procedura sortuje liczbę za pomocą sortowania bąbelkowego.

:white_check_mark: 3.0 | Procedura do generowania 50 losowych liczb od 0 do 100 [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/4da4c676db4276607fec6acffbd101305b059fc7)

:white_check_mark: 3.5 | Procedura do sortowania liczb bąbelkowo [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/a4b9fe09878228d357b98e63303dfcac57ec9395)

:white_check_mark: 4.0 | Dodanie parametrów do procedury losującej określających zakres losowania: od, do, ile [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/1843ef1a767a7473c46cc9cb0918db9c93df9852)

:white_check_mark: 4.5 | 5 testów jednostkowych testujących procedury [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/3d1697382c46f2026c7cb36d5afab0f02865f4fa)

:x: 5.0 | Skrypt w bashu do uruchamiania aplikacji w Pascalu via docker

## **ZADANIE 2** Wzorce architektury
Symfony (PHP)

Należy stworzyć aplikację webową na bazie frameworka Symfony
na obrazie kprzystalski/projobj-php:latest.
Baza danych dowolna, sugeruję SQLite.

:white_check_mark: 3.0 | Należy stworzyć jeden model z kontrolerem z produktami, zgodnie z CRUD (JSON) [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/6c2064097350a8f86848ac8812cbc9aada448618)

:white_check_mark: 3.5 | Należy stworzyć skrypty do testów endpointów via curl (JSON) [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/2a5d320a37f6c7066cb0322761a519bf10e91ec4)

:white_check_mark: 4.0 | Należy stworzyć dwa dodatkowe kontrolery wraz z modelami (JSON) [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/7603e4865c380e28cf048c2a151c401746eda868)

:white_check_mark: 4.5 | Należy stworzyć widoki do wszystkich kontrolerów [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/41ca7ff4abe2f1c39db21b2fff650d9b2e92514a)

:x: 5.0 | Stworzenie panelu administracyjnego

## **ZADANIE 3** Wzorce kreacyjne
Sprint Boot (Kotlin)

Należy stworzyć prosty serwis do autoryzacji, który zasymuluje autoryzację
użytkownika za pomocą przesłanej nazwy użytkownika oraz hasła.
Serwis powinien zostać wstrzyknięty do kontrolera (4.5).
Aplikacja ma zawierać jeden kontroler i powinna zostać napisana
w języku Kotlin. Oparta powinna zostać na frameworku Spring Boot.
Serwis do autoryzacji powinien być singletonem.

:white_check_mark: 3.0 | Należy stworzyć jeden kontroler wraz z danymi wyświetlanymi z listy na endpoincie w formacie JSON - Kotlin + Spring Boot [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/fb6735430e262b83da54d90e08539061f4cb333f)

:white_check_mark: 3.5 | Należy stworzyć klasę do autoryzacji (mock) jako Singleton w formie eager [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/35fb9af8fc04782a2a91d1a3b2d999049b7f7968)

:white_check_mark: 4.0 | Należy obsłużyć dane autoryzacji przekazywane przez użytkownika [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/9f668f02cb9b8c6de4453885c17185c2a7934c10)

:white_check_mark: 4.5 | Należy wstrzyknąć singleton do głównej klasy via @Autowired lub kontruktor (constructor injection) [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/3352fbd8baceac4a3ef9b4f07e65d57f98c424fe)

:white_check_mark: 5.0 | Obok wersji Eager do wyboru powinna być wersja Singletona w wersji lazy [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/36b04356d7cdc9df5a800ee87afe820d9aa843c8)

## **ZADANIE 4** Wzorce strukturalne
Echo (Go)

Należy stworzyć aplikację w Go na frameworku echo.
Aplikacja ma mieć jeden endpoint, minimum jedną funkcję proxy,
która pobiera dane np. o pogodzie, giełdzie, etc. (do wyboru) z zewnętrznego API.
Zapytania do endpointu można wysyłać jako GET lub POST.

:x: 3.0 | Należy stworzyć aplikację we frameworki echo w j. Go, która będzie miała kontroler Pogody, która pozwala na pobieranie danych o pogodzie (lub akcjach giełdowych)

:x: 3.5 | Należy stworzyć model Pogoda (lub Giełda) wykorzystując gorm, a dane załadować z listy przy uruchomieniu

:x: 4.0 | Należy stworzyć klasę proxy, która pobierze dane z serwisu zewnętrznego podczas zapytania do naszego kontrolera

:x: 4.5 | Należy zapisać pobrane dane z zewnątrz do bazy danych

:x: 5.0 | Należy rozszerzyć endpoint na więcej niż jedną lokalizację (Pogoda), lub akcje (Giełda) zwracając JSONa
