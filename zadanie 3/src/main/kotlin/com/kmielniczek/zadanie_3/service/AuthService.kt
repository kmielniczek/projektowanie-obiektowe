package com.kmielniczek.zadanie_3.service

interface AuthService {
    fun authorize(mail: String, password: String): Boolean
}

class MockAuthService : AuthService {
    private val credentials =
            mapOf(
                    "nick@mail.com" to "theSecretPass",
                    "beth@eruna.se" to "u2n5h9s*2m",
                    "ryszard@wolna.pl" to "1234",
            )

    override fun authorize(mail: String, password: String): Boolean {
        return credentials[mail] == password
    }
}
