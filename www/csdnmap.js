var exec = require('cordova/exec');


module.exports = {
    launch: function (message, onSuccess, onError) {
        exec(onSuccess, onError, "Csdnmap", "launch", [message]);
    }
};
