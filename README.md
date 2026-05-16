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

:white_check_mark: 3.0 | Należy stworzyć aplikację we frameworki echo w j. Go, która będzie miała kontroler Pogody, która pozwala na pobieranie danych o pogodzie (lub akcjach giełdowych) [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/c52324bc401820b91fbac09b84f78dcc6f054b20)

:white_check_mark: 3.5 | Należy stworzyć model Pogoda (lub Giełda) wykorzystując gorm, a dane załadować z listy przy uruchomieniu [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/cf5d3a5a0d22c5fce7c08f22265f0f0b4483e7b1)

:white_check_mark: 4.0 | Należy stworzyć klasę proxy, która pobierze dane z serwisu zewnętrznego podczas zapytania do naszego kontrolera [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/7847a20e09888fb480fb475c4392843e328a9fe2)

:white_check_mark: 4.5 | Należy zapisać pobrane dane z zewnątrz do bazy danych [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/1ad6486d98d3f88d2c635e9193c1d9a82eaec80d)

:white_check_mark: 5.0 | Należy rozszerzyć endpoint na więcej niż jedną lokalizację (Pogoda), lub akcje (Giełda) zwracając JSONa [commit](https://github.com/kmielniczek/projektowanie-obiektowe/commit/1ad6486d98d3f88d2c635e9193c1d9a82eaec80d)


## **ZADANIE 5** Wzorce behawioralne
React (JavaScript/TypeScript)

:x: 3.0 | W ramach projektu należy stworzyć komponenty Produkty oraz Płatności; komponent Produkty powinien pobierać listę produktów z aplikacji serwerowej, natomiast komponent Płatności powinien wysyłać dane płatności do aplikacji serwerowej.

:x: 3.5 | Należy dodać komponent Koszyk wraz z osobnym widokiem; aplikacja powinna umożliwiać przechodzenie pomiędzy widokami przy użyciu routingu.

:x: 4.0 | Dane pomiędzy komponentami, takimi jak Produkty, Koszyk i Płatności, powinny być przekazywane z wykorzystaniem React hooks, np. useState, useEffect lub useContext.

:x: 4.5 | Należy przygotować konfigurację umożliwiającą uruchomienie aplikacji klienckiej oraz serwerowej w kontenerach Docker za pomocą docker-compose.

:x: 5.0 | Należy wykorzystać bibliotekę axios do komunikacji z serwerem oraz skonfigurować obsługę CORS, aby frontend mógł poprawnie komunikować się z backendem.


## **ZADANIE 6** Zapaszki
Należy sprawdzić kod projektów JS 3.0, 3.5, 4.0,  kotlin, go, js - 4.5, 5.0.

:x: 3.0 | Należy skonfigurować husky + lint-staged uruchamianie lintowania przed commitem

:x: 3.5 | Należy wyeliminować wszystkie bugi w kodzie w Sonarze (kod aplikacji klienckiej)

:x: 4.0 | Przeskanować oraz naprawić dowolny projekt open source narzędziem CodeQL https://codeql.github.com/

:x: 4.5 | Należy usunąć problemy typu Code Smell w kodzie w Sonarze (kotlin, go, js). Należy dodać badge z Sonara

:x: 5.0 | Skonfigurować Github Actions z linterem oraz CodeQL


## **ZADANIE 7**
Proszę napisać prostą aplikację w Vaporze,
wykorzystując Leaf jako silnik szablonów or Fluent jako ORM.
Proszę stworzyć trzy modele oraz CRUD dla każdego z nich.
Należy stworzyć model z minimum jedną relacją.
CRUD powinien mieć odzwierciedlenie w szablonach.

:x: 3.0 | Należy stworzyć kontroler wraz z modele Produktów zgodny z CRUD w ORM Fluent

:x: 3.5 | Należy stworzyć szablony w Leaf

:x: 4.0 | Należy stworzyć drugi model oraz kontroler Kategorii wraz z relacją

:x: 4.5 | Należy wykorzystać Redis do przechowywania danych

:x: 5.0 | Wrzucić aplikację na heroku
