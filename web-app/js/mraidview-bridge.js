(function () {
    var mraidview = window.mraidview = {},
        listeners = {};
    broadcastEvent = function() {
        var i,
            key,
            event,
            handler,
            args = new Array(arguments.length);

        for (i = 0; i < arguments.length; i++) {
            args[i] = arguments[i];
        }

        event = args.shift();
        for (key in listeners[event]) {
            handler = listeners[event][key];
            handler.func.apply(handler.func.scope, args);
        }
    };

    mraidview.broadcastEvent = broadcastEvent;
    mraidview.scriptFound = false;

    mraidview.addEventListener = function(event, listener, scope) {
        var key = String(listener) + String(scope),
            map = listeners[event];

        if (!map) {
            map = {};
            listeners[event] = map;
        }
        map[key] = {scope : (scope ? scope : {}), func : listener};
    };

    mraidview.removeEventListener = function(event, listener, scope) {
        var key = String(listener) + String(scope),
            map = listeners[event];

        if (map) {
            map[key] = null;
            delete map[key];
        }
    };

    mraidview.pushChange = function(obj) {
        console.warn(obj);
        Object
        broadcastEvent('change', obj);
    };

    mraidview.pushError = function(message, action) {
        broadcastEvent('error', message, action);
    };

    mraidview.pushInfo = function(message) {
        broadcastEvent('info', message);
    };

    mraidview.activate = function(service) {
        broadcastEvent('activate', service);
    };

    mraidview.deactivate = function(service) {
        broadcastEvent('deactivate', service);
    };

    mraidview.expand = function(URL) {
        broadcastEvent('expand', URL);
    };

    mraidview.close = function() {
        broadcastEvent('close');
    };

    mraidview.open = function(URL) {
        broadcastEvent('open', URL);
        window.bridge.open(URL);
    };

    mraidview.resize = function() {
        broadcastEvent('resize');
    };

    mraidview.setExpandProperties = function(properties) {
        broadcastEvent('setExpandProperties', properties);
    };

    mraidview.setResizeProperties = function(properties) {
        broadcastEvent('setResizeProperties', properties);
    };

    mraidview.storePicture = function(url) {
        broadcastEvent('storePicture', url);
    };

    mraidview.playVideo = function(url) {
        broadcastEvent('playVideo', url);
    };

    mraidview.createCalendarEvent = function(params) {
        broadcastEvent('createCalendarEvent', params);
    };

    mraidview.useCustomClose = function(useCustomCloseIndicator) {
        broadcastEvent('useCustomClose', useCustomCloseIndicator);
    }

})();
