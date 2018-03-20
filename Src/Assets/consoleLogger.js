(function() {
    var callbackCounter = 1,
        callbacks = {};        

    function sendData(data) {
        //NOTE: we cannot console.log in this function as it will cause a circular reference
        //as console.log will in turn calls this function sendData() - to handle the consoleLogger logic
        //which essentially results in an indefinite loop
        var jsonString = (JSON.stringify(data));
        if (webkit && webkit.messageHandlers && webkit.messageHandlers.nativeManager) {
            webkit.messageHandlers.nativeManager.postMessage(jsonString);
        } else {
        }        
    }

    window.WebBridge = window.WebBridge || {
        webToNative: function(event, payload, callback) {
            var context = callbackCounter.toString();
            callbacks[context] = callback;
            callbackCounter++;
            var data = {
                'event': event,
                'payload': payload,
                'context': context
            };
            sendData(data);
        },
        // Called from native side by executing JavaScript
        nativeToWeb: function (resp) {
            if (resp && resp.context) {
                var cb = callbacks[resp.context];
                //delete callbacks[resp.context];

                if (resp.data) {
                    cb(resp.data);
                } else {
                    cb();
                }
            } else {
                console.error('WebBridge: no resp in nativeToWeb or resp.context undefined');
            }
        }
    }
})();

//capture console.log and redirect to app log
window.console = (function() {
    function log(message) {
        window.WebBridge.webToNative('consoleLogger', {
            'payload': message
        });
    }
    return {
        log: log,
        debug: log,
        info: log,
        warn: log,
        error: log
    }
})();
