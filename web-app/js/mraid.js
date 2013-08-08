function mraidJsId() {
    if (typeof (mraid) === 'undefined') {
        console.log('mraid not found yet');
    } else {
        clearInterval(idInterval);
        mraid.info('mraid.js identification script included');
        mraidview.scriptFound = true;
    }
}

var idInterval = setInterval(mraidJsId, 500);
