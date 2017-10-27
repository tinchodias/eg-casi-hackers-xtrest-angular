'use strict';

angular.module('casi-hackers')
.factory('Auth', function($http, $cookieStore){

    var currentUser = $cookieStore.get('user') || { username: '', roles: [] };

    $cookieStore.remove('user');

    function changeUser(user) {
        angular.extend(currentUser, user);
    }

    return {
        authorize: function(possibleRoles) {
            return possibleRoles.includes("Public") || _.intersection(possibleRoles, currentUser.roles).length > 0;
        },
        isLoggedIn: function() {
            return currentUser.roles.length > 0;
        },
        register: function(user, success, error) {
            $http.post('/register', user).then(function(response) {
                changeUser(response.data);
                success();
            }, error);
        },
        login: function(user, success, error) {
            $http.post('/login', user).then(function(response){
                changeUser(response.data);
                success();
            }, error);
        },
        logout: function(success, error) {
            $http.post('/logout').then(function(){
                changeUser({
                    username: '',
                    roles: []
                });
                success();
            }, error);
        },
        user: currentUser
    };
});

angular.module('casi-hackers')
.factory('Users', function($http) {
    return {
        getAll: function(success, error) {
            $http.get('/users')
            	.then(function(response) { return response.data })
            	.then(success, error);
        }
    };
});
