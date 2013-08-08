(function () {
    var mraidview = window.mraidview = {};

    // CONSTANTS ///////////////////////////////////////////////////////////////

    var VERSIONS = mraidview.VERSIONS = {
        V1: '1.0',
        V2: '2.0'
    };

    var PLACEMENTS = mraidview.PLACEMENTS = {
        UNKNOWN: 'unknown',

        INLINE: 'inline',
        INTERSTITIAL: 'interstitial'
    }

    var STATES = mraidview.STATES = {
        UNKNOWN: 'unknown',

        LOADING: 'loading',
        DEFAULT: 'default',
        RESIZED: 'resized',
        EXPANDED: 'expanded',
        HIDDEN: 'hidden'
    };

    var EVENTS = mraidview.EVENTS = {
        INFO: 'info',
        ORIENTATIONCHANGE: 'orientationChange',

        READY: 'ready',
        ERROR: 'error',
        STATECHANGE: 'stateChange',
        VIEWABLECHANGE: 'viewableChange',
        SIZECHANGE: 'sizeChange',
    };

    var FEATURES = mraidview.FEATURES = {
        SMS: 'sms',
        TEL: 'tel',
        CALENDAR: 'calendar',
        STOREPICTURE: 'storePicture',
        INLINEVIDEO: 'inlineVideo'
    };

    // EVENT HANDLING ///////////////////////////////////////////////////////////////

    var listeners = {};

    var broadcastEvent = function () {
        var args = new Array(arguments.length);
        for (var i = 0; i < arguments.length; i++) args[i] = arguments[i];

        var event = args.shift();

        for (var key in listeners[event]) {
            var handler = listeners[event][key];
            handler.func.apply(handler.func.scope, args);
        }
    }

    mraidview.broadcastEvent = broadcastEvent;

    mraidview.addEventListener = function (event, listener, scope) {
        var key = String(listener) + String(scope);
        var map = listeners[event]
        if (!map) {
            map = {};
            listeners[event] = map;
        }
        map[key] = {scope: (scope ? scope : {}), func: listener};
    };

    mraidview.removeEventListener = function (event, listener, scope) {
        var key = String(listener) + String(scope);
        var map = listeners[event];
        if (map) {
            map[key] = null;
            delete map[key];
        }
    };

    // PRIVATE VARIABLES ///////////////////////////////////////////////////////////////

    var
        adURI = "",
        adURIFragment = true,
        adHtml = '',
        useHtml = false,
        adContent = '',
        adWindow = null,
        adWindowAdj = {x: 0, y: 0},
        adFrame = null,
        adFrameExpanded = null,
        adContainer = null,
        adResizeContainer = null,
        adExpandedContainer = null,
        closeEventRegion = null,
        adBridge = null,
        adController = null,
        inactiveAdBridge = null,
        inactiveAdController = null,
        intervalID = null,
        timeoutID = null,
        active = {},
        previousPosition = { x: 0, y: 0, width: 0, height: 0 },
        previousState = null,
        defaultWindowSize = null,
        adContainerOrientation = -1;

    // MRAID state variables - shared with frame
    var
        state = STATES.LOADING,
        screenSize = { width: 320, height: 480 },
        size = { width: 0, height: 0 },
        defaultPosition = { width: 320, height: 50, y: 0, x: 0 },
        c = { width: 0, height: 0, y: 0, x: 0 },
        maxSize = { width: 320, height: 480, x: 0, y: 0 },
        expandProperties = { width: 0, height: 0, useCustomClose: false, isModal: false},
        orienationProperties = { allowOrientationChange: true, forceOrientation: 'none' },
        resizeProperties = { width: 0, height: 0, customClosePosition: 'top-right', offsetX: 0, offsetY: 0, allowOffscreen: true},
        supports = ["sms", "tel", "calendar", "storePicture", "inlineVideo"],
        version = VERSIONS.V2,
        placement = PLACEMENTS.UNKNOWN,
        isViewable = false;
        orientation = -1;


    // PUBLIC ACCESSOR METHODS ///////////////////////////////////////////////////////////////

    mraidview.setAdURI = function(uri, fragment) {
        adURI = uri;
        adURIFragment = (fragment)?true:false;
    };

    mraidview.setDefaultWindowSize = function () {
        defaultWindowSize = {};
        if (orientation % 180 === 0) {
            defaultWindowSize.outerWidth = adWindow.outerWidth;
            defaultWindowSize.innerWidth = adWindow.innerWidth;
            defaultWindowSize.outerHeight = adWindow.outerHeight;
            defaultWindowSize.innerHeight = adWindow.innerHeight;
        } else {
            defaultWindowSize.innerWidth = adWindow.innerHeight;
            defaultWindowSize.innerHeight = adWindow.innerWidth;
            defaultWindowSize.outerWidth = defaultWindowSize.innerWidth + (adWindow.outerWidth - adWindow.innerWidth); // + (adWindow.outerHeight - adWindow.innerHeight);
            defaultWindowSize.outerHeight = defaultWindowSize.innerHeight + (adWindow.outerHeight - adWindow.innerHeight);
        }
    };

    // PUBLIC ACTION METHODS ///////////////////////////////////////////////////////////////

    mraidview.render = function () {
        broadcastEvent(EVENTS.INFO, 'rendering');

        if (!adFrame || !adWindow || !adWindow.document || !adFrame.contentWindow) {
            broadcastEvent(EVENTS.INFO, 'creating adWindow');
            adWindow = window.open('device', 'adWindow', 'left=1000,width=' + screenSize.width + ',height=' + screenSize.height + ',menubar=no,location=no,toolbar=no,status=no,personalbar=no,resizable=no,scrollbars=no,chrome=no,all=no');

            adWindow.onload = function () {
                broadcastEvent(EVENTS.INFO, 'adWindow loaded');

                adWindowAdj.x = window.outerWidth - screenSize.width;
                adWindowAdj.y = window.outerHeight - screenSize.height;
                adWindow.document.getElementsByTagName('body')[0].style.width = screenSize.width + 'px';
                adWindow.document.getElementsByTagName('body')[0].style.height = screenSize.height + 'px';
                adContainer = adWindow.document.getElementById('adContainer');
                adContainer.addEventListener('ViewableChange', function (e) {
                    changeViewable();
                });
                adResizeContainer = adWindow.document.getElementById('adResizeContainer');
                adFrame = adWindow.document.getElementById('adFrame');
                closeEventRegion = adWindow.document.getElementById('closeEventRegion');
                //closeEventRegion.addEventListener('click', closeAd);

                window.setTimeout(function () {
                    mraidview.setDefaultWindowSize();
                }, 250);
                loadAd();
            };
        } else {
            adWindow.close();
            adWindow = null;
            mraidview.render();
        }
    };

    // PRIVATE METHODS ///////////////////////////////////////////////////////////////

    var reset = function () {
        adContent = '';
        adBridge = null;
        adController = null;
        adFrame.style.display = 'block';
        adContainer.style.display = 'block';
        adResizeContainer.style.display = 'block';
        intervalID = null;
        timeoutID = null;
        active = {};
        size.width = defaultPosition.width;
        size.height = defaultPosition.height;
        previousPosition = { x: 0, y: 0, width: 0, height: 0 };
        previousState = null;
        state = STATES.DEFAULT;
        expandProperties = { width: maxSize.width, height: maxSize.height, useCustomClose: false, isModal: false};
        resizeProperties = { width: 0, height: 0, customClosePosition: 'top-right', offsetX: 0, offsetY: 0, allowOffscreen: true};
        orientationProperties = {allowOrientationChange: true, forceOrientation: 'none'};
        orientation = (screenSize.width >= screenSize.height) ? 90 : 0;
        version = VERSIONS.UNKNOWN;
        currentPosition = { 'x': 0, 'y': 0, 'width': defaultPosition.width, 'height': defaultPosition.height };
        isViewable = false;
    };

    var loadAd = function () {
        reset();

        if (adFrame.attachEvent) {
            adFrame.attachEvent("onload", initAdFrame);
        } else {
            adFrame.onload = initAdFrame;
        }

        setContainerDefaultPosition(defaultPosition);

        adFrame.contentWindow.location.replace(adURI);

        if (orientation % 180 === 0) {
            setMaxAdArea(maxSize);
        } else {
            setMaxAdArea({'width': maxSize.height, 'height': maxSize.width, 'x': maxSize.x, 'y': maxSize.y});
        }
    };

    var showMraidCloseButton = function(toggle) {
        var closeDiv = closeEventRegion;
        closeDiv.style.position = 'absolute';

        if (toggle) {
            closeDiv.style.top = '';
            closeDiv.style.left = '';
            closeDiv.style.bottom = '';
            closeDiv.style.right = '';
            closeDiv.style.width = '50px';
            closeDiv.style.height = '50px';
            closeDiv.style.display = 'none';
            closeDiv.style.zIndex = getHighestZindex()+2;
            closeDiv.style.cursor = 'pointer';
            closeDiv.style.background = (expandProperties.useCustomClose) ? '': 'url("close.png") no-repeat 8px 8px';

            if (state === STATES.RESIZED) {
                closeDiv.style.background = '';

                var pos = resizeProperties.customClosePosition;
                if (/top/i.test(pos)) {
                    closeDiv.style.top = '0px';
                } else if (/bottom/i.test(pos)) {
                    closeDiv.style.bottom = '0px';
                } else {
                    closeDiv.style.top = [(resizeProperties.height - 50 ) / 2, 'px'].join('');
                }

                if (/left/i.test(pos)) {
                    closeDiv.style.left = '0px';
                } else if (/right/i.test(pos)) {
                    closeDiv.style.right = '0px';
                } else {
                    closeDiv.style.left = [(resizeProperties.width - 50 ) / 2, 'px'].join('');
                }
            } else {
                closeDiv.style.top = '0';
                closeDiv.style.right = '0';
            }

            closeDiv.style.display = 'block';
            broadcastEvent (EVENTS.INFO, 'adding MRAID close button');
        } else {
            closeDiv.style.display = 'none';
            broadcastEvent (EVENTS.INFO, 'removing MRAID close button');
        }
    };

    var setContainerDefaultPosition = function () {
        adContainer.style.left = defaultPosition.x + 'px';
        adContainer.style.top = defaultPosition.y + 'px';
        adContainer.style.width = defaultPosition.width + 'px';
        adContainer.style.height = defaultPosition.height + 'px';
    };

    var setMaxAdArea = function (size) {
        var maxDiv = adWindow.document.getElementById('maxArea');
        maxDiv.style.width = [size.width, 'px'].join('');
        maxDiv.style.height = [size.height, 'px'].join('');
        maxDiv.style.position = 'absolute';
        maxDiv.style.left = [size.x, 'px'].join('');
        maxDiv.style.top = [size.y, 'px'].join('');
        !adBridge || adBridge.pushChange({'maxSize': size});
    };

    var initAdFrame = function () {
        if (this.detachEvent) {
            this.detachEvent("onload", initAdFrame);
        } else {
            this.onload = '';
        }
        broadcastEvent(EVENTS.INFO, 'initializing ad frame');

        var win = this.contentWindow,
            doc = win.document,
            adScreen = {};

        for (var prop in win.screen) {
            if (prop !== 'width' && prop !== 'height') {
                adScreen[prop] = win.screen[prop];
            }
        }

        adScreen.width = screenSize.width;
        adScreen.height = screenSize.height;

        win.screen = adScreen;

        var bridgeJS = doc.createElement('script');
        bridgeJS.setAttribute('type', 'text/javascript');
        bridgeJS.setAttribute('src', '/adiii/js/mraidview-bridge.js');
        doc.getElementsByTagName('head')[0].appendChild(bridgeJS);

        intervalID = win.setInterval(function () {
            if (win.mraidview) {
                win.clearInterval(intervalID);

                var mraidJS = doc.createElement('script');
                mraidJS.setAttribute('type', 'text/javascript');
                mraidJS.setAttribute('src', '/adiii/js/mraid-main.js');
                doc.getElementsByTagName('head')[0].appendChild(mraidJS);

                intervalID = win.setInterval(function () {
                    if (win.mraid) {
                        win.clearInterval(intervalID);
                        window.clearTimeout(timeoutID);
                        initAdBridge(win.mraidview, win.mraid);
                    }
                }, 30);
            }
        }, 30);
    };

    var initAdBridge = function(bridge, controller) {
        broadcastEvent(EVENTS.INFO, 'initializing bridge object ' + bridge + controller);

        inactiveAdBridge = adBridge;
        inactiveAdController = adController;

        adBridge = bridge;
        adController = controller;

        if (placement === PLACEMENTS.INTERSTITIAL) {
            showMraidCloseButton(true);
        }

        bridge.addEventListener('activate', function(service) {
            active[service] = true;
        }, this);

        bridge.addEventListener('deactivate', function(service) {
            if (active[service]) {
                active[service] = false;
            }
        }, this);

        //bridge.addEventListener('close', closeAd , this);

        bridge.addEventListener('hide', function() {
            adFrame.style.display = 'none';
            adResizeContainer.disabled = 'none';
            adContainer.style.display = 'none';
            previousState = state;
            state = STATES.HIDDEN;
            adBridge.pushChange({ state:state, isViewable:false });
        }, this);

        bridge.addEventListener('show', function() {
            adFrame.style.display = 'block';
            adResizeContainer.style.display = 'block';
            adContainer.style.display = 'block';
            state = previousState;
            adBridge.pushChange({ state:state });
        }, this);

        bridge.addEventListener('open', function(URL) {
            broadcastEvent(EVENTS.INFO, 'opening ' + URL);
            window.open(URL, '_blank', 'left=1000,width='+screenSize.width+',height='+screenSize.height+',menubar=no,location=no,toolbar=no,status=no,personalbar=no,resizable=no,scrollbars=no,chrome=no,all=no');
        }, this);

        bridge.addEventListener('playVideo', function(URL) {
            broadcastEvent(EVENTS.INFO, 'playing ' + URL);
            window.open(URL, '_blank');
        }, this);

        bridge.addEventListener('storePicture', function(URL) {
            var allow = confirm('CONFIRM: Store this image to gallery?\nURL:' + URL);
            if (allow) {
                window.open('../imageDownload.php?imageUrl=' + URL);
                broadcastEvent(EVENTS.INFO, 'storing the image ' + URL);
            } else {
                broadcastEvent(EVENTS.ERROR, 'Permission denied by user', 'storePicture');
            }
        }, this);

        bridge.addEventListener('resize', function(uri) {

            if (state === STATES.EXPANDED) {
                broadcastEvent(EVENTS.ERROR, 'Can not expand a resized ad', 'resize');
                return;
            } else if (state === STATES.HIDDEN || state === STATES.UNKNOWN || state === STATES.LOADING) {
                return;
            }
            state = STATES.RESIZED;
            showMraidCloseButton(true);
            resizeAd();

            adBridge.pushChange({ 'state':state, 'currentPosition':currentPosition, 'size':size });
        }, this);

        bridge.addEventListener('setExpandProperties', function(properties) {
            broadcastEvent(EVENTS.INFO, 'setting expand properties to ' + stringify(properties));
            !properties.width || (expandProperties.width = properties.width);
            !properties.height || (expandProperties.height = properties.height);
            !properties.useCustomClose || (expandProperties.useCustomClose = properties.useCustomClose);

            adBridge.pushChange({'expandProperties':expandProperties});
        }, this);

        bridge.addEventListener('setResizeProperties', function(properties) {
            broadcastEvent(EVENTS.INFO, 'setting resize properties to ' + stringify(properties));
            setResizeProperties(properties);
            adBridge.pushChange({'resizeProperties':resizeProperties});
        }, this);

        bridge.addEventListener('createCalendarEvent', function(params) {
            var allow = confirm('CONFIRM: Create this calendar event?\n' + stringify(params));
            if (allow) {
                broadcastEvent(EVENTS.INFO, 'creating event ' + stringify(params));
            } else {
                broadcastEvent(EVENTS.ERROR, 'Permission denied by user', 'createCalendarEvent');
            }
        }, this);

        bridge.addEventListener('useCustomClose', function(useCustomCloseIndicator) {
            broadcastEvent(EVENTS.INFO, 'setting useCustomClose properties to ' + stringify(useCustomCloseIndicator));
            expandProperties.useCustomClose = !!useCustomCloseIndicator;
        }, this);

        controller.addEventListener('info', function(message) {
            broadcastEvent(EVENTS.INFO, message);
        }, this);

        controller.addEventListener('error', function(message) {
            broadcastEvent(EVENTS.ERROR, message);
        }, this);

        var initProps = {
            state:STATES.LOADING,
            screenSize:screenSize,
            orientation:orientation,
            size:size,
            defaultPosition:defaultPosition,
            maxSize:maxSize,
            expandProperties:expandProperties,
            resizeProperties:resizeProperties,
            orientationProperties:orientationProperties,
            supports:supports,
            version:mraidview.version,
            placement:mraidview.placement,
            currentPosition:defaultPosition,
            isViewable:isAdViewAble()
        };

        bridge.pushChange({version:mraidview.version});
        bridge.pushChange(initProps);

        if (!!inactiveAdBridge) {
            state =  STATES.EXPANDED;
            mraidview.setOrientation(orientation, true);
            bridge.pushChange({'state':state, 'currentPosition': currentPosition });
            repaintAdWindow();
        }

        bridge.pushChange({ state:state });
    };

    var changeViewable = function (toggle) {
        if (!isViewable && isAdViewAble()) {
            isViewable = true;
            adBridge.pushChange({ 'isViewable': isViewable});
            if (inactiveAdBridge) inactiveAdBridge.pushChange({'isViewable': isViewable});
        } else if (isViewable && !isAdViewAble()) {
            isViewable = false;
            adBridge.pushChange({ 'isViewable': isViewable});
            if (inactiveAdBridge) inactiveAdBridge.pushChange({'isViewable': isViewable});
        }
    };

    var isAdViewAble = function () {
        var viewableAttr = adContainer.getAttribute('data-isViewable');
        return ((typeof(viewableAttr) === 'string' && viewableAttr === 'true') || (typeof(viewableAttr) === 'boolean' && viewableAttr));
    };
})();