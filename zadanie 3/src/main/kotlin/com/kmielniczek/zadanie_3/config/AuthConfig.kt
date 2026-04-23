package com.kmielniczek.zadanie_3.config

import com.kmielniczek.zadanie_3.service.AuthService
import com.kmielniczek.zadanie_3.service.MockAuthService
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class AuthConfig {
    @Bean
    fun mockAuthService(): AuthService {
        return MockAuthService()
    }
}
