package com.kmielniczek.zadanie_3.controller

import com.kmielniczek.zadanie_3.model.Note
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/note")
class UserController {
    private val products =
            listOf(
                    Note(1, "groceries", "milk, cheese, bread"),
                    Note(2, "todo", "prepare dinner; vacuum the house"),
                    Note(3, "barber appointment", "26th May 2026"),
                    Note(4, "plans", "find a trip offer to greece"),
            )

    @GetMapping("")
    fun getUsers(): List<Note> {
        return products
    }
}
