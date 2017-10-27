'use strict';

angular.module('casi-hackers')
.controller('AuthCtrl', function($rootScope, $state, Auth) {

    this.user = function() {
        return Auth.user;
    };

    this.isLoggedIn = function() {
        return Auth.isLoggedIn();
    };

    this.hasBasicRole = function() {
        return this.user().roles.includes("Basic");
    };

    this.hasAdminRole = function() {
        return this.user().roles.includes("Admin");
    };

    this.logout = function() {
        Auth.logout(function() {
            $state.go('public.login');
        }, function() {
            $rootScope.error = "Failed to logout";
        });
    };
});

angular.module('casi-hackers')
.controller('LoginCtrl', function($rootScope, $state, Auth) {

    this.login = function() {
        Auth.login({
            username: this.username,
            password: this.password
        },
        function() {
            $state.go('common.home');
        },
        function(response) {
            $rootScope.error = response.data;
        });
    };

});

angular.module('casi-hackers')
.controller('RegisterCtrl', function($rootScope, $state, Auth) {

    this.register = function() {
        Auth.register({
            username: this.username,
            password: this.password
        },
        function() {
            $state.go('common.home');
        },
        function(response) {
            $rootScope.error = response.data;
        });
    };
});

angular.module('casi-hackers')
.controller('AdminCtrl', function($rootScope, Users, Auth) {
    this.loading = true;

    var self = this;

    Users.getAll(function(users) {
        self.users = users;
        self.loading = false;
    }, function(err) {
        $rootScope.error = "Failed to fetch users.";
        self.loading = false;
    });

});
