(function() {
    var app = angular.module('myApp', ['onsen.directives', 'ngTouch']);

    document.addEventListener('deviceready', function() {
        angular.bootstrap(document, ['myApp']);
    }, false);

    app.factory('Data', function() {
        var Data = {};
        Data.items = ['aa', 'bb', 'cc'];
        return Data;
    });

    app.controller('Page1Ctrl', function($scope, Data) {
        $scope.items = Data.items;

        $scope.next = function(index) {
            Data.index = index;
            var item = Data.items[index];
            $scope.ons.navigator.pushPage('page2.html', {title: item});
        };
    });

    app.controller('Page2Ctrl', function($scope, Data) {
        $scope.item = Data.items[Data.index];

        $scope.save = function() {
            Data.items[Data.index] = $scope.item;
            $scope.ons.navigator.popPage();
        };
    });
})();
