package ar.hackers.domain

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.commons.model.exceptions.UserException

@Accessors
class User {
    String username
    String password
    List<Role> roles = newArrayList
        
    def hasAdminRole() {
        roles.contains(Role.Admin)
    }
    
    def validate() {
        username.trim() => [
            if (length < 1 || length > 20) {
                throw new UserException("Username must be 1-20 characters long") 
            }
        ]  
        password.trim() => [
            if (length < 5 || length > 60) {
                throw new UserException("Password must be 5-60 characters long") 
            }
        ]  
    }
}