package ar.hackers.server

import ar.hackers.domain.User
import ar.hackers.server.dto.LoginUser
import com.fasterxml.jackson.databind.exc.UnrecognizedPropertyException
import java.net.URLDecoder
import java.net.URLEncoder
import java.util.List
import javax.servlet.http.Cookie
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.uqbar.commons.model.exceptions.UserException
import org.uqbar.xtrest.api.annotation.Body
import org.uqbar.xtrest.api.annotation.Controller
import org.uqbar.xtrest.api.annotation.Get
import org.uqbar.xtrest.api.annotation.Post
import org.uqbar.xtrest.http.ContentType
import org.uqbar.xtrest.json.JSONUtils
import ar.hackers.domain.Role

@Controller
class AuthenticationController {
    extension JSONUtils = new JSONUtils
    
    List<User> users
    
    new(List<User> users) {
        this.users = users
    }
    
    
    /** API */
    
    @Post("/login")
    def login(@Body String body) {
        response.contentType = ContentType.APPLICATION_JSON
        var User user;
        try {
            user = this.getAuthenticatedUserFromJson(body)
        } catch (UserException exception) {
            return forbidden(exception.message.toJson)            
        } 
        this.setUserCookie(response, user)
        return ok(user.toJson)
    }
    
    @Post("/logout")
    def logout() {
        response.contentType = ContentType.APPLICATION_JSON
        this.removeUserCookie(response)
        return ok()
    }
    
    @Post("/register")
    def register(@Body String json) {
        response.contentType = ContentType.APPLICATION_JSON
        var User user 
        try {
            val loginUser = json.fromJson(LoginUser)
            user = new User() => [
                username = loginUser.username
                password = loginUser.password
                roles = #[ Role.Basic ]
            ]
        }
        catch (UnrecognizedPropertyException exception) {
            return badRequest("Bad user format".toJson)
        }
        
        try {
            user.validate()
        } catch (UserException exception) {
            return badRequest(exception.message.toJson)            
        } 
        this.setUserCookie(response, user)
        return ok(user.toJson)
    }

    @Get("/users")
    def getUsers() {
        response.contentType = ContentType.APPLICATION_JSON
        try {
            this.assertAutorizadoComoAdministrador(request)    
        } catch(UserException exception) {
            return forbidden(exception.message.toJson)
        }
        return ok(users.toJson)
    }


    /** Private - Helpers */
    
    def getUserByUsername(String string) {
        users.findFirst[ it.username == string ]    
    }

    def getAuthenticatedUserFromJson(String json) {
        var LoginUser loginUser
        try {
            loginUser = json.fromJson(LoginUser)
        }
        catch (UnrecognizedPropertyException exception) {
            throw new UserException("Invalid format")
        }

        val user = this.getUserByUsername(loginUser.username)
        if (user == null || user.password != loginUser.password) {
            throw new UserException("Invalid username or pass")
        }
        return user
    }

    
    /** Private - Cookies */

    def assertAutorizadoComoAdministrador(HttpServletRequest request) {
        if (request.cookies == null) {
            throw new UserException("Must be logged in")
        }
        val cookie = request.cookies.findFirst[ it.name == "user" ]
        if (cookie == null) {
            throw new UserException("Must be logged in")
        }
        val json = URLDecoder.decode(cookie.value, 'utf-8')
        val usuario = this.getAuthenticatedUserFromJson(json)
        if (!usuario.hasAdminRole) {
            throw new UserException("Must have Admin role")
        }
        return usuario
    }

    def setUserCookie(HttpServletResponse response, User user) {
        val cookieValue = URLEncoder.encode(new LoginUser(user).toJson, "utf-8")        
        response.addCookie(new Cookie("user", cookieValue) => [
            maxAge = 30
        ])
    }

    def removeUserCookie(HttpServletResponse response) {
        response.addCookie(new Cookie("user", null) => [
            maxAge = 0    
        ])
    }


    /** OLD */

//    def assertAutorizadoComoAdministrador(HttpServletRequest request) {
//        val usuario = this.getUsuarioBasicAuthorization(request)
//        if (!usuario.esAdministrador) {
//            throw new UserException("No está autorizado para esta acción")
//        }
//        return usuario
//    }

//    def getUsuarioBasicAuthorization(HttpServletRequest request) {
//        val auth = request.getHeader("Authorization")
//        if (auth == null) {
//            throw new UserException("No hay header Authorization")
//        }
//
//        val String[] authparts = auth.split(" ")
//        if (authparts.length != 2) {
//            throw new UserException("Formato inválido en header Authorization")
//        }
//        if (!authparts.get(0).equals("Basic")) {
//            throw new UserException("Solamente aceptamos Basic Authorization")
//        }
//
//        val userpass = new String(Base64.mimeDecoder.decode(authparts.get(1)));
//        val parts = userpass.split(":")
//        if (parts.length != 2) {
//            throw new UserException("Formato inválido de usuario:contraseña codificado con base64")
//        }
//        val name = parts.get(0)
//        val pass = parts.get(1)
//
//        var user = this.buscarUsuario(name)
//        if (user == null || user.contrasenia != pass) {
//            throw new UserException("Usuario o contraseña inválidos")
//        }
//        return user
//    }


}