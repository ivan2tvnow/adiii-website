<script type="text/javascript" src="${resource(dir: "js", file: "mraid.js")}"></script>

<style>

#expand {
    position:absolute;
    left:260px;
    top:11px;
}


#expandedad {
    position:absolute;
    left:0px;
    top:0px;
    clip:rect( 0, 300, 250, 0 );
    display:none;
}

#expanddata {
    position:absolute;
    left:15px;
    top:15px;
    color:green;
}

#data {
    position:absolute;
    left:20px;
    top:60px;
    color:green;
}

img {
    border:none
}

#shrink {
    position:absolute;
    left:0px;
    top:0px;
}

#close {
    position:absolute;
    left:10px;
    top:11px;
}

#ad {
    margin:0px;
    position:absolute;
    left:0px;
    top:0px;
}

#buttonTable {
    position:absolute;
    top: 4px;
}
</style>


<!-- Setup our Javascript -->
<script language="javascript">
    var stringify = function(obj) {
        if (typeof obj == 'object') {
            if (obj.push) {
                var out = [];
                for (var p = 0; p < obj.length; p++) {
                    out.push(obj[p]);
                }
                return '[' + out.join(',') + ']';
            } else {
                var out = [];
                for (var p in obj) {
                    out.push('\''+p+'\':'+obj[p]);
                }
                return '{' + out.join(',') + '}';
            }
        } else {
            return String(obj);
        }
    };

    /**
     * Primary entry point, listens for when MRAID is ready.
     *
     * Sets up an error event handler and populates initial screen data
     *
     * @requires mraid
     */
    function mraidReady(){
        mraid.useCustomClose(false);
        mraid.addEventListener( 'error', handleErrorEvent );
        mraid.addEventListener( 'stateChange', handleStateChangeEvent );
        showDefault();
    }

    /**
     * Notifies the SDK that the default ad wishes to move to the expanded state.
     *
     * @requires mraid
     */
    function expandAd() {
        console.log('expand Ad');
        mraid.useCustomClose(false);
        mraid.setExpandProperties({useCustomClose:false});
        mraid.expand('./mraid-test-ad-expanded.html');
    }


    /**
     * Handles MRAID errors.
     */
    function handleErrorEvent( message, action ) {
        console.log('handleErrorEvent');
        var msg = "MRAID ERROR ";
        if ( action != null ) {
            // error caused by an action
            msg += "caused by action '" + action + "', ";
        }
        msg += "Message: " + message;
        alert(msg);
    }

    /**
     * Handles orientaion changes.
     *
     * @param {evt} Event, the error event
     *
     * @requires mraid
     */
    function handleOrientationEvent( angle ) {
        console.log('handleOrientationEvent');
        var btn = document.controller.orientationButton;
        btn.value = "Orientation: " + angle;
    }

    /**
     * Handles state change events.
     */
    function handleStateChangeEvent( state ) {
        console.log('handleStateChangeEvent');
        if ( state === 'default' ) {
            showDefault();
        }
        else if ( state === 'expanded' ) {
            showExpanded();
        }
    }


    /**
     * creates a calendar event
     *
     * @requires mraid
     */
    function sendEvent() {
        console.log('sendEvent');
        mraid.createCalendarEvent( new Date(), "title", "body" );
    }

    /**
     * Causes the appropriate elements for the "default" state to be displayed.
     *
     * @requires: mraid
     */
    function showDefault() {
        console.log('showDefault');
        var banner = document.getElementById( 'banner' );
        banner.style.display = 'block';
    }


    /**
     * Causes the appropriate elements for the "expanded" state to be displayed.
     *
     * @requires: mraid
     */
    function showExpanded() {
        console.log('showExpanded');
    }

    function getPlacementType() {
        alert('PlacementType: ' + mraid.getPlacementType());
    }

    function isViewable() {
        alert('Viewable: ' + mraid.isViewable());
    }

    function getVersion() {
        alert('Version: ' + mraid.getVersion());
    }

    function getState() {
        alert('State: ' + mraid.getState());
    }

    function getResizeProperties() {
        alert('ResizeProperties: ' + stringify(mraid.getResizeProperties()));
    }

    function getExpandProperties() {
        alert('ExpandProperties: ' + stringify(mraid.getExpandProperties()));
    }

    function getSize() {
        alert('Size: ' + stringify(mraid.getSize()));
    }

    function getScreenSize() {
        alert('ScreenSize: ' + stringify(mraid.getScreenSize()));
    }

    function getMaxSize() {
        alert('MaxSize: ' + stringify(mraid.getMaxSize()));
    }

    function getDefaultPosition() {
        alert('DefaultPosition: ' + stringify(mraid.getDefaultPosition()));
    }

    function getCurrentPosition() {
        alert('CurrentPosition: ' + stringify(mraid.getCurrentPosition()));
    }

    function openInMraid() {
        console.log('openInMraid');
        mraid.open ('http://www.iab.net/mraid/');
    }

    function playVideo() {
        console.log('playVideo');
        mraid.playVideo ('http://youtu.be/FB5KeKdVCVo');
    }

    function storePicture() {
        console.log('storePicture');
        mraid.storePicture ('http://www.iab.net/media/image/new-iab-logo.gif');
    }
    function createCalendarEvent() {
        console.log('createCalendarEvent');
        mraid.createCalendarEvent ({description:'event description',location:'event location',summary:'event summary',start:'2011-03-24T09:00-08:00',end:'2011-03-24T10:00:00-08:00',reminder: '-3600000'});
    }

    function supports() {
        console.log('supports');

        var vSupported = {
            'sms' : false,
            'tel' : false,
            'calendar' : false,
            'storePicture' : false,
            'inlineVideo' : false
        };

        for (var feature in vSupported) {
            vSupported[feature] = mraid.supports(feature);
        }
        alert(stringify(vSupported));
    }

    function closeBanner() {
        console.log('closeBanner');
        mraid.close();
    }

</script>

<!-- The actual creative -->

<div id='ad'>
    <div id='banner'>
        <img src="../img/300x50-solid.png"
             alt="banner advertisement" />
        <div id='expand'>
            <img src="../img/expand.png"
                 alt="expand"
                 onclick="expandAd();" />
        </div>
        <div id='close'>
            <img src="../img/shrink.png"
                 alt="close"
                 onclick="closeBanner();" />
        </div>
    </div>


    <!-- The expanded ad (expanded state) -->
</div>
<script language="javascript">
    //listen for mraid ready

    var readyTimeout;
    function readyListener() {
        if (typeof (mraid) === 'undefined') {
            console.log('mraid not found yet');
            readyTimeout = setTimeout(readyListener, 10);
        } else {
            var state = mraid.getState();
            if (state === 'default') {
                console.log ('mraid state is already default before could register listener for ready')
                mraidReady();
            } else {
                console.log ('state is ' + state + '; register ready listener');
                clearTimeout(readyTimeout);
                mraid.addEventListener('ready', mraidReady);
            }
        }
    }
    readyListener();
</script>