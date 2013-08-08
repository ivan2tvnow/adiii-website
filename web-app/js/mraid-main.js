(function() {
    var mraid = window.mraid = {};

    // CONSTANTS ///////////////////////////////////////////////////////////////

    var VERSIONS = mraid.VERSIONS = {
        V1  : '1.0',
        V2  : '2.0'
    };

    var STATES = mraid.STATES = {
        LOADING     :'loading',
        DEFAULT     :'default',
        EXPANDED    :'expanded',
        RESIZED     :'resized',
        HIDDEN      :'hidden'
    };

    var EVENTS = mraid.EVENTS = {
        READY               :'ready',
        ERROR               :'error',
        STATECHANGE         :'stateChange',
        VIEWABLECHANGE      :'viewableChange',
        SIZECHANGE          :'sizeChange'
    };

    var PLACEMENTS = mraid.PLACEMENTS = {
        UNKNOWN      : 'unknown',

        INLINE       : 'inline',
        INTERSTITIAL : 'interstitial'
    }

    var FEATURES = mraid.FEATURES = {
        SMS         :'sms',
        TEL         :'tel',
        CALENDAR    :'calendar',
        STOREPICTURE:'storePicture',
        INLINEVIDEO	:'inlineVideo'
    };

    // PRIVATE PROPERTIES (sdk controlled) //////////////////////////////////////////////////////

    var state = STATES.UNKNOWN;

    var placementType = PLACEMENTS.UNKNOWN;

    var screenSize = {
        width: 320,
        height: 480
    };

    var defaultPosition = {
        x: 0,
        y: 0,
        width: 320,
        height: 50
    };

    var currentPosition = {
        x: 0,
        y: 0,
        width: 320,
        height: 480
    };

    var maxSize = {
        x: 0,
        y: 0,
        width: 320,
        height: 480
    };

    var expandProperties = {
        width: 320,
        height: 480,
        useCustomClose: false,
        isModal: false
    };

    var orientationProperties = {
        allowOrientationChange: true,
        forceOrientation: 'portrait'
    };

    var resizeProperties = {
        width: 0,
        height: 0,
        offsetX: 0,
        offsetY: 0,
        customClosePosition: 'top-right',
        allowOffscreen: true
    };

    var supports = {
        sms: true,
        tel: true,
        calendar: true,
        storePicture: true,
        inlineVideo: true
    };

    var orientation = -1;
    var mraidVersion = VERSIONS.UNKNOWN;
    var screenSize = null;
    var isViewable = false;

    // PRIVATE PROPERTIES (internal) //////////////////////////////////////////////////////

    var intervalID = null;

    var changeHandlers = {
        version:function(val) {
            mraidVersion = val;
        },
        placement:function(val){
            placementType = val;
        },
        state:function(val) {
            console.log('state listener. state='+state+':new='+val);
            if (state == STATES.UNKNOWN && val != STATES.UNKNOWN) {
                broadcastEvent(EVENTS.INFO, 'controller initialized');
            }
            if (state == STATES.LOADING && val != STATES.LOADING) {
                mraid.signalReady();
            } else {
                broadcastEvent(EVENTS.INFO, 'setting state to ' + stringify(val));
                state = val;
                broadcastEvent(EVENTS.STATECHANGE, state);
            }
        },
        size:function(val) {
            broadcastEvent(EVENTS.INFO, 'setting size to ' + stringify(val));
            size = val;
            broadcastEvent(EVENTS.SIZECHANGE, size.width, size.height);
        },
        defaultPosition:function(val) {
            broadcastEvent(EVENTS.INFO, 'setting default position to ' + stringify(val));
            defaultPosition = val;
        },
        currentPosition:function(val) {
            broadcastEvent(EVENTS.INFO, 'setting current position to ' + stringify(val));
            currentPosition = val;
        },
        maxSize:function(val) {
            broadcastEvent(EVENTS.INFO, 'setting maxSize to ' + stringify(val));
            maxSize = val;
        },
        expandProperties:function(val) {
            broadcastEvent(EVENTS.INFO, 'merging expandProperties with ' + stringify(val));
            for (var i in val) {
                expandProperties[i] = val[i];
            }
        },
        resizeProperties:function(val) {
            broadcastEvent(EVENTS.INFO, 'merging resizeProperties with ' + stringify(val));
            for (var i in val) {
                resizeProperties[i] = val[i];
            }
        },
        supports:function(val) {
            broadcastEvent(EVENTS.INFO, 'setting supports to ' + stringify(val));
            supports = {};
            for (var key in FEATURES) {
                supports[FEATURES[key]] = contains(FEATURES[key], val);
            }
        },
        orientation:function(val) {
            broadcastEvent(EVENTS.INFO, 'setting orientation to ' + stringify(val));
            orientation = val;
            broadcastEvent(EVENTS.ORIENTATIONCHANGE, orientation);
        },
        screenSize:function(val) {
            broadcastEvent(EVENTS.INFO, 'setting screenSize to ' + stringify(val));
            screenSize = val;
            broadcastEvent(EVENTS.SCREENCHANGE, screenSize.width, screenSize.height);
        },
        isViewable:function(val) {
            broadcastEvent(EVENTS.INFO, 'setting isViewable to ' + stringify(val));
            isViewable = val;
            broadcastEvent(EVENTS.VIEWABLECHANGE, isViewable);
        },
        orientationProperties:function(val) {
            broadcastEvent(EVENTS.INFO, 'setting orientationProperties to ' + stringify(val));
            for (var i in val) {
                orientationProperties[i] = val[i];
            }
        }
    };

    var listeners = {};

    var EventListeners = function(event) {
        this.event = event;
        this.count = 0;
        var listeners = {};

        this.add = function(func) {
            var id = String(func);
            if (!listeners[id]) {
                listeners[id] = func;
                this.count++;
                if (this.count == 1) {
                    broadcastEvent(EVENTS.INFO, 'activating ' + event);
                    mraidview.activate(event);
                }
            }
        };
        this.remove = function(func) {
            var id = String(func);
            if (listeners[id]) {
                listeners[id] = null;
                delete listeners[id];
                this.count--;
                if (this.count == 0) {
                    broadcastEvent(EVENTS.INFO, 'deactivating ' + event);
                    mraidview.deactivate(event);
                }
                return true;
            } else {
                return false;
            }
        };
        this.removeAll = function() { for (var id in listeners) this.remove(listeners[id]); };
        this.broadcast = function(args) { for (var id in listeners) listeners[id].apply({}, args); };
        this.toString = function() {
            var out = [event,':'];
            for (var id in listeners) out.push('|',id,'|');
            return out.join('');
        };
    };

    // PRIVATE METHODS ////////////////////////////////////////////////////////////

    mraidview.addEventListener('change', function(properties) {
        for (var property in properties) {
            var handler = changeHandlers[property];
            console.log('for property "' + property + '" typeof handler is: ' + typeof(handler));
            handler(properties[property]);
        }
    });

    mraidview.addEventListener('error', function(message, action) {
        broadcastEvent(EVENTS.ERROR, message, action);
    });

    var clone = function(obj) {
        var f = function() {};
        f.prototype = obj;
        return new f();
    };

    var contains = function(value, array) {
        for (var i in array) if (array[i] == value) return true;
        return false;
    };

    var broadcastEvent = function() {
        var args = new Array(arguments.length);
        for (var i = 0; i < arguments.length; i++) args[i] = arguments[i];
        var event = args.shift();
        if (listeners[event]) listeners[event].broadcast(args);
    }

    // VERSION 1 ////////////////////////////////////////////////////////////////////

    mraid.signalReady = function() {
        broadcastEvent(EVENTS.INFO, 'START READY SIGNAL, setting state to ' + stringify(STATES.DEFAULT));
        state = STATES.DEFAULT;
        broadcastEvent(EVENTS.STATECHANGE, state);
        broadcastEvent(EVENTS.INFO, 'ready event fired');
        broadcastEvent(EVENTS.READY, 'ready event fired');
        window.clearInterval(intervalID);
    };

    mraid.info = function(message) {
        /* not in MRAID - unique to mraid-web-tester */
        broadcastEvent(EVENTS.INFO, message);
    };

    mraid.addEventListener = function(event, listener) {
        if (!event || !listener) {
            broadcastEvent(EVENTS.ERROR, 'Both event and listener are required.', 'addEventListener');
        } else if (!contains(event, EVENTS)) {
            broadcastEvent(EVENTS.ERROR, 'Unknown event: ' + event, 'addEventListener');
        } else {
            if (!listeners[event]) listeners[event] = new EventListeners(event);
            listeners[event].add(listener);
        }
    };

    mraid.removeEventListener = function(event, listener) {
        if (!event) {
            broadcastEvent(EVENTS.ERROR, 'Must specify an event.', 'removeEventListener');
        } else {
            if (!listener || (typeof(listeners[event]) === 'undefined' || !listeners[event].remove(listener))) {
                broadcastEvent(EVENTS.ERROR, 'Listener not currently registered for event: ' + event, 'removeEventListener');
                return;
            } else {
                listeners[event].removeAll();
            }
            if (listeners[event].count == 0) {
                listeners[event] = null;
                delete listeners[event];
            }
        }
    };

    mraid.getSize = function() {
        var pos = clone(currentPosition);
        return ({width:pos.width, height:pos.height});
    };

    mraid.getCurrentPosition = function() {
        if (parseFloat(mraidVersion, 10) < 2) {
            broadcastEvent(EVENTS.ERROR, 'Method not supported by this version. (getCurrentPosition)', 'getCurrentPosition');
        } else {
            return clone(currentPosition);
        }
        return (null);
    };

    mraid.getDefaultPosition = function() {
        if (parseFloat(mraidVersion, 10) < 2) {
            broadcastEvent(EVENTS.ERROR, 'Method not supported by this version. (getDefaultPosition)', 'getDefaultPosition');
        } else {
            return clone(defaultPosition);
        }
        return (null);
    };

    mraid.getExpandProperties = function() {
        var props = clone(expandProperties);
        return props;
    };

    mraid.getMaxSize = function(bOverride) {
        if (!bOverride && parseFloat(mraidVersion, 10) < 2) {
            broadcastEvent(EVENTS.ERROR, 'Method not supported by this version. (getMaxSize)', 'getMaxSize');
        } else {
            return clone(maxSize);
        }
        return (null);
    };

    mraid.getPlacementType = function() {
        return placementType;
    };

    mraid.getResizeProperties = function() {
        if (parseFloat(mraidVersion, 10) < 2) {
            broadcastEvent(EVENTS.ERROR, 'Method not supported by this version. (getResizeProperties)', 'getResizeProperties');
        } else {
            return clone(resizeProperties);
        }
        return (null);
    };

    mraid.getScreenSize = function() {
        if (parseFloat(mraidVersion, 10) < 2) {
            broadcastEvent(EVENTS.ERROR, 'Method not supported by this version. (getScreenSize)', 'getScreenSize');
        } else {
            return clone(screenSize);
        }
        return (null);
    };

    mraid.getState = function() {
        return state;
    };

    mraid.getVersion = function() {
        return (mraidVersion);
    };

    mraid.isViewable = function() {
        return isViewable;
    };

    mraid.setExpandProperties = function(properties) {
        broadcastEvent('setExpandProperties', properties);
    };

    mraid.setResizeProperties = function (properties) {
        mraidview.setResizeProperties(properties);
    };

    mraid.useCustomClose = function(useCustomCloseIndicator) {
        expandProperties['useCustomClose'] = useCustomCloseIndicator;
    };

    mraid.open = function(url) {
        if (!url) {
            broadcastEvent(EVENTS.ERROR, 'URL is required.', 'open');
        } else {
            broadcastEvent('open', url);
        }
    };

    mraid.expand = function(url) {
        if (placementType === PLACEMENTS.INLINE) {
            broadcastEvent('expand', url);
        }
    };

    mraid.resize = function() {
        if (parseFloat(mraidVersion, 10) < 2) {
            broadcastEvent(EVENTS.ERROR, 'Method not supported by this version. (resize)', 'resize');
        } else {
            if (placementType === PLACEMENTS.INLINE) {
                broadcastEvent('resize');
            }
        }
    };

    mraid.close = function() {
        broadcastEvent('close');
    };

    mraid.playVideo = function(url) {
        if (parseFloat(mraidVersion, 10) < 2) {
            broadcastEvent(EVENTS.ERROR, 'Method not supported by this version. (playVideo)', 'playVideo');
        } else {
            if (supports[FEATURES.INLINEVIDEO]) {
                broadcastEvent(EVENTS.INFO, 'Inline video is available but playVideo uses native player.');
            }
            if (!url || typeof url != 'string') {
                broadcastEvent(EVENTS.ERROR, 'Valid url required.', 'playVideo');
            } else {
                broadcastEvent('playVideo', url);
            }
        }
    };

    mraid.storePicture = function(url) {
        if (parseFloat(mraidVersion, 10) < 2) {
            broadcastEvent(EVENTS.ERROR, 'Method not supported by this version. (storePicture)', 'storePicture');
        } else {
            if (!supports[FEATURES.STOREPICTURE]) {
                broadcastEvent(EVENTS.ERROR, 'Method not supported by this client. (storePicture)', 'storePicture');
            } else if (!url || typeof url !== 'string') {
                broadcastEvent(EVENTS.ERROR, 'Valid url required. (storePicture)', 'storePicture');
            } else {
                broadcastEvent('storePicture', url);
            }
        }
    };

    mraid.supports = function(feature) {
        var bSupports = false;
        if (parseFloat(mraidVersion, 10) < 2) {
            broadcastEvent(EVENTS.ERROR, 'Method not supported by this version. (supports)', 'supports');
        } else {
            bSupports = supports[feature];
        }
        return (bSupports);
    };

    mraid.createCalendarEvent = function(params) {
        if (parseFloat(mraidVersion, 10) < 2) {
            broadcastEvent(EVENTS.ERROR, 'Method not supported by this version. (createCalendarEvent)', 'createCalendarEvent');
        } else {
            if (!supports[FEATURES.CALENDAR]) {
                broadcastEvent(EVENTS.ERROR, 'Method not supported by this client. (createCalendarEvent)', 'createCalendarEvent');
            } else if (!params || typeof params != 'object') {
                broadcastEvent(EVENTS.ERROR, 'Valid params required.', 'createCalendarEvent');
            } else {
                broadcastEvent('createCalendarEvent', params);
            }
        }
    };

})();