package ar.hackers.server.dto

import ar.hackers.domain.User
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class LoginUser {
    String username
    String password

    new() {
    }
    
    new(User original) {
        this.username= original.username
        this.password = original.password
    }
    
}
