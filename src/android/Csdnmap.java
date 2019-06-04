package cordova.plugin.bakaan.csdnmap;

import android.content.Context;
import android.content.Intent;

import com.baidu.mapapi.CoordType;
import com.baidu.mapapi.SDKInitializer;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * This class echoes a string called from JavaScript.
 */
public class Csdnmap extends CordovaPlugin {

    private static Context mContext;

    private static Integer REQUEST_CODE = 1000;

    static final String DATA_FLAG = "data_flag";
    static final String DATA_TYPE = "data_type";
    static final String DATA_TYPE_MARKER = "data_type_marker";
    static final String DATA_TYPE_LIST = "data_type_list";

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        mContext = cordova.getActivity().getApplicationContext();
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("launch")) {
            String message = args.getString(0);
            this.launch(message, callbackContext);
            return true;
        }
        return false;
    }

    private void launch(String message, CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            callbackContext.success(message);
            //在使用SDK各组件之前初始化context信息，传入ApplicationContext
            SDKInitializer.initialize(mContext);
            //自4.3.0起，百度地图SDK所有接口均支持百度坐标和国测局坐标，用此方法设置您使用的坐标类型.
            //包括BD09LL和GCJ02两种坐标，默认是BD09LL坐标。
            SDKInitializer.setCoordType(CoordType.BD09LL);
            // 启动地图activity
            Intent intent = new Intent();
            intent.setClass(mContext, CsdnmapActivity.class);
            cordova.startActivityForResult(this, intent, REQUEST_CODE);
        } else {
            callbackContext.error("nmsl!");
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        if (REQUEST_CODE == requestCode) {

            if (null == intent) {
                return;
            }

            if (null == intent.getExtras()) {
                return;
            }

            if (DATA_TYPE_MARKER.equals(intent.getExtras().get(DATA_TYPE))) {

                // 地图marker点击事件
                String format = "csdnmap.markerClickCallBack(%s);";
                String js = String.format(format, intent.getExtras().get(DATA_FLAG));
                webView.loadUrl("javascript:" + js);

            } else if (DATA_TYPE_LIST.equals(intent.getExtras().get(DATA_TYPE))) {

                // 地图房源列表点击事件
                String format = "csdnmap.listClickCallBack(%s);";
                String js = String.format(format, intent.getExtras().get(DATA_FLAG));
                webView.loadUrl("javascript:" + js);

            }


        }


    }
}
