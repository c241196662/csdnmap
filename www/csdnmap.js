cordova.define("cordova-plugin-bakaan-csdnmap.csdnmap", function(require, exports, module) {
var exec = require('cordova/exec');


module.exports = {
    launch: function (message, onSuccess, onError) {
        exec(onSuccess, onError, "Csdnmap", "launch", [message]);
    },

    //  地图marker点击事件
    markerClickCallBack: function (data) {
     	data = JSON.stringify(data);
     	var event = JSON.parse(data);
     	cordova.fireDocumentEvent("csdnmap.markerClickCallBack", event);
    },

    // 地图房源列表点击事件
    listClickCallBack: function (data) {
         data = JSON.stringify(data);
         var event = JSON.parse(data);
         cordova.fireDocumentEvent("csdnmap.listClickCallBack", event);
    }

};

});
