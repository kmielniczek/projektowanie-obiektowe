package com.kmielniczek.zadanie_3.controller

import com.kmielniczek.zadanie_3.model.Note
import com.kmielniczek.zadanie_3.service.AuthService
import java.nio.charset.StandardCharsets
import java.util.Base64
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.server.ResponseStatusException

@RestController
@RequestMapping("/api/note")
class UserController(private val authService: AuthService) {
    private val products =
            listOf(
                    Note(1, "groceries", "milk, cheese, bread"),
                    Note(2, "todo", "prepare dinner; vacuum the house"),
                    Note(3, "barber appointment", "26th May 2026"),
                    Note(4, "plans", "find a trip offer to greece"),
            )

    @GetMapping("")
    fun getUsers(@RequestHeader(HttpHeaders.AUTHORIZATION) authorization: String): List<Note> {
        val credentials = extractCredentials(authorization)

        if (!authService.authorize(credentials.first, credentials.second)) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials")
        }

        return products
    }

    private fun extractCredentials(authorization: String): Pair<String, String> {
        if (!authorization.startsWith("Basic ")) {
            throw ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Authorization header must use Basic scheme"
            )
        }

        val encoded = authorization.removePrefix("Basic ").trim()

        val decoded =
                try {
                    String(Base64.getDecoder().decode(encoded), StandardCharsets.UTF_8)
                } catch (exception: IllegalArgumentException) {
                    throw ResponseStatusException(
                            HttpStatus.BAD_REQUEST,
                            "Invalid Basic credentials encoding"
                    )
                }

        val parts = decoded.split(":", limit = 3)
        if (parts.size != 2) {
            throw ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Basic credentials must use mail:password format"
            )
        }

        val mail = parts[0]
        val password = parts[1]

        return mail to password
    }
}
