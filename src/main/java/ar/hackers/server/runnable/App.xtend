package ar.hackers.server.runnable

import ar.hackers.domain.Role
import ar.hackers.domain.User
import ar.hackers.server.AuthenticationController
import org.uqbar.xtrest.api.XTRest

class App {
    def static void main(String[] args) {
        val users = newArrayList

        users.add(new User => [
            username = "pepe"
            password = "123"
            roles = #[Role.Basic]
        ])

        users.add(new User => [
            username = "admin"
            password = "123"
            roles = #[Role.Admin]
        ])

        users.add(new User => [
            username = "juan"
            password = "123"
            roles = #[Role.Basic, Role.Admin]
        ])

        XTRest.startInstance(9000, new AuthenticationController(users))
    }
}