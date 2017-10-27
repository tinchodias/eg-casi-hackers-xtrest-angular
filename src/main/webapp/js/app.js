'use strict';

angular.module('casi-hackers', ['ngCookies', 'ui.router'])

.config(function ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) {

    // Public routes
    $stateProvider
        .state('public', {
            abstract: true,
            template: "<ui-view/>",
            data: {
                possibleRoles: ["Public"]
            }
        })
        .state('public.welcome', {
            url: '/',
            templateUrl: 'partials/welcome.html'
        })
        .state('public.404', {
            url: '/404',
            templateUrl: 'partials/404.html'
        })
        .state('public.login', {
            url: '/login',
            templateUrl: 'partials/login.html',
            controller: 'LoginCtrl as loginCtrl'
        })
        .state('public.register', {
            url: '/register',
            templateUrl: 'partials/register.html',
            controller: 'RegisterCtrl as registerCtrl'
        });

    // Basic and Admin user routes
    $stateProvider
        .state('common', {
            abstract: true,
            template: "<ui-view/>",
            data: {
                possibleRoles: ["Basic", "Admin"]
            }
        })
        .state('common.home', {
            url: '/home',
            templateUrl: 'partials/home.html'
        });

    // Admin user routes
    $stateProvider
        .state('admin', {
            abstract: true,
            template: "<ui-view/>",
            data: {
                possibleRoles: ["Admin"]
            }
        })
        .state('admin.users', {
            url: '/admin/users',
            templateUrl: 'partials/admin.html',
            controller: 'AdminCtrl as adminCtrl'
        });

    // the known route, with missing '/' - let's create alias
    $urlRouterProvider.when('', '/');

    // the unknown
    $urlRouterProvider.otherwise('/404');

    $httpProvider.interceptors.push(function($q, $location) {
        return {
            'responseError': function(response) {
                if(response.status === 401 || response.status === 403) {
                    $location.path('/login');
                }
                return $q.reject(response);
            }
        };
    });

})

.run(function ($rootScope, $state, Auth) {

    $rootScope.$on("$stateChangeStart", function (event, toState, toParams, fromState, fromParams) {

        if (!Auth.authorize(toState.data.possibleRoles)) {
            $rootScope.error = "You must have " + toState.data.possibleRoles + " role to access " + toState.url;
            event.preventDefault();

            if(fromState.url === '^') {
                if(Auth.isLoggedIn()) {
                    $state.go('common.home');
                } else {
                    $rootScope.error = null;
                    $state.go('public.login');
                }
            }
        }
    });

});
