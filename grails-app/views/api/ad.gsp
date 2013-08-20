<script type="text/javascript" src="${resource(dir: "js", file: "mraidview-bridge.js")}"></script>
<script type="text/javascript" src="${resource(dir: "js", file: "mraid-main.js")}"></script>

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

    function mraidReady(){
        window.demo.onReply();
        mraid.useCustomClose(false);
        mraid.addEventListener( 'error', handleErrorEvent );
        mraid.addEventListener( 'stateChange', handleStateChangeEvent );
        showDefault();
    }

    function expandAd() {
        console.log('expand Ad');
        mraid.useCustomClose(false);
        mraid.setExpandProperties({useCustomClose:false});
        mraid.expand('./mraid-test-ad-expanded.html');
    }

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

    function handleOrientationEvent( angle ) {
        console.log('handleOrientationEvent');
        var btn = document.controller.orientationButton;
        btn.value = "Orientation: " + angle;
    }

    function handleStateChangeEvent( state ) {
        console.log('handleStateChangeEvent');
        if ( state === 'default' ) {
            showDefault();
        }
        else if ( state === 'expanded' ) {
            showExpanded();
        }
    }

    function sendEvent() {
        console.log('sendEvent');
        mraid.createCalendarEvent( new Date(), "title", "body" );
    }

    function showDefault() {
        console.log('showDefault');
        var banner = document.getElementById( 'banner' );
        banner.style.display = 'block';
    }

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
        mraid.open('${clickTrough}');
    }

    function playVideo() {
        console.log('playVideo');
        mraid.playVideo('${videoUrl}');
    }

    function storePicture() {
        console.log('storePicture');
        mraid.storePicture('${imgUrl}');
    }
    function createCalendarEvent() {
        console.log('createCalendarEvent');
        mraid.createCalendarEvent({description:'event description',location:'event location',summary:'event summary',start:'2011-03-24T09:00-08:00',end:'2011-03-24T10:00:00-08:00',reminder: '-3600000'});
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

    function adOnView() {
        console.log('adOnView');
        tracking('${viewUlr}');
    }

    function adImpression() {
        console.log('adImpression');
        tracking('${impressionUrl}');
    }

    function adClick() {
        console.log('adClick');
        tracking('${clickUrl}');
    }

</script>

<!-- The actual creative -->

<div id='ad'>
    <div id='banner'>
        <img id="ad_content" src="${imgUrl}" alt="banner advertisement" onerror="this.src='../img/300x50-solid.png'"/>
    </div>


    <!-- The expanded ad (expanded state) -->
</div>
<script src="http://code.jquery.com/jquery.js"></script>
<script language="javascript">
    $(function() {
        adImpression();

        $('#ad_content').load(adOnView());

        $('#ad_content').click(function(){
            adClick();
            openInMraid();
        });
    });

    function tracking(url) {
        $.ajax({
            url: url,
            type: "GET",
            dataType: "text",
            error: function() {
                console.log('traking error');
            },
            success: function () {
                console.log('traking success');
            }
        });
    }

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