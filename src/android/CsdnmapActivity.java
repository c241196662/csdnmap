package cordova.plugin.bakaan.csdnmap;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.widget.Toast;

import com.baidu.location.BDAbstractLocationListener;
import com.baidu.location.BDLocation;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;
import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BaiduMapOptions;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.MapStatus;
import com.baidu.mapapi.map.MapStatusUpdateFactory;
import com.baidu.mapapi.map.MapView;
import com.baidu.mapapi.map.Marker;
import com.baidu.mapapi.map.MarkerOptions;
import com.baidu.mapapi.map.MyLocationData;
import com.baidu.mapapi.map.Overlay;
import com.baidu.mapapi.map.OverlayOptions;
import com.baidu.mapapi.map.TextOptions;
import com.baidu.mapapi.model.LatLng;
import com.baidu.mapapi.model.LatLngBounds;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class CsdnmapActivity extends Activity {

    public static final float MAP_COMMUNITY_DISTRICT_BORDER = 16f;
    public static final String ACTION_LOADCOMMUNITY = "loadcommunity";

    private MapView mMapView; // 地图框框
    private BaiduMap mBaiduMap; // 地图
    private LocationClient mLocationClient; // 定位
    private OverlayOptions mPoint; // 标记点

    private List<Overlay> communitymarkers;
    private List<Overlay> areamarkers;
    private List<Overlay> districtmarkers;

    public CsdnmapActivity() {
        mMapView = null;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        BaiduMapOptions options = new BaiduMapOptions();
        // 设置地图模式为标准
        options.mapType(BaiduMap.MAP_TYPE_NORMAL);
        mMapView = new MapView(this, options);
        setContentView(mMapView);
        mBaiduMap = mMapView.getMap();

        // 初始化定位
        MapStatus.Builder builder = new MapStatus.Builder();
        LatLng center = new LatLng(30.2592444615, 120.219375416);
        float zoom = 16.5f; // 地图缩放级别
        builder.target(center).zoom(zoom);
        mBaiduMap.setMapStatus(MapStatusUpdateFactory.newMapStatus(builder.build()));
        // 加载图标
        Context appContext = this.getApplicationContext();
        String pkgName = appContext.getPackageName();
        Resources resource = appContext.getResources();
        int csdnmappoint = resource.getIdentifier("csdnmappoint", "drawable", pkgName);

        BitmapDescriptor icon = BitmapDescriptorFactory
                .fromResource(csdnmappoint);

        //构建MarkerOption，用于在地图上添加Marker
        mPoint = new MarkerOptions()
                .position(center)
                .icon(icon);
        //在地图上添加Marker，并显示
        mBaiduMap.addOverlay(mPoint);
        // 启动定位
        startlocation();
        // 添加监听器
        addlistener();
    }

    /**
     * 加载小区列表
     */
    private void loadcommunity() {
        String url = "http://m.howzf.com/hzf/esf_communitylist.jspx";
        LatLngBounds bounds = mBaiduMap.getMapStatus().bound;
        LatLng ne = bounds.northeast; // 东百角坐标
        LatLng sw = bounds.southwest; // 西南角坐标
        String[] key = {""};
        String[] values = {""};
        JSONObject params = new JSONObject();
        try {
            params.put("rp", 30);
            params.put("neLat", ne.latitude);
            params.put("neLng", ne.longitude);
            params.put("swLat", sw.latitude);
            params.put("swLng", sw.longitude);
        } catch (JSONException e) {
            e.printStackTrace();
        }
//        neLat: 30.291852148451074
//        neLng: 120.18529289260651
//        rp: 30
//        swLat: 30.281046313205913
//        swLng: 120.1778549229839
        AsyncTask loadcommunityTask = new CsdnmapHttpgetTask(ACTION_LOADCOMMUNITY, url);
        loadcommunityTask.execute(params);
    }

    /**
     * 批量添加小区标记
     * @param jsonstr
     */
    private void addCommunityMarkers(String jsonstr) {
        try {
            JSONObject json = new JSONObject(jsonstr);
            addCommunityMarkers(json);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 批量添加小区标记
     * @param json
     */
    private void addCommunityMarkers(JSONObject json) {
        JSONArray list = null;
        List<OverlayOptions> pointlist = new ArrayList<>();
        try {
            list = json.getJSONArray("list");
            for (int i = 0; i < list.length(); i++) {
                JSONObject community = list.getJSONObject(i);
                pointlist.add(buildCommunityMarker(community));
            }
            communitymarkers = mBaiduMap.addOverlays(pointlist);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 添加小区标记
     * @param community
     */
    private TextOptions buildCommunityMarker(JSONObject community) {
        try {
            String communityname = community.getString("communityname");
            float lat = (float) community.getDouble("prjx");
            float lng = (float) community.getDouble("prjy");
            int rentnum = community.getInt("czcount");

            LatLng latlng = new LatLng(lat, lng);
            //构建MarkerOption，用于在地图上添加Marker
            return new TextOptions()
                    .position(latlng)
                    .text(communityname + "(" +  rentnum + "套)")
                    .bgColor(0x80ffffff);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }
    /**
     * 删除所有的小区/商圈/板块标记物
     */
    private void clearMarkers() {
        clearMarkers(communitymarkers);
        clearMarkers(areamarkers);
        clearMarkers(districtmarkers);
    }

    /**
     * 指定删除某一类标记物
     * @param markerlist 标记物数组
     */
    private void clearMarkers(List<Overlay> markerlist) {
        if (markerlist != null) {
            for (Overlay marker : markerlist) {
                marker.remove();
            }
        }
    }
    /**
     * 启动定位
     */
    private void startlocation() {

        //定位初始化
        mLocationClient = new LocationClient(this);

        //通过LocationClientOption设置LocationClient相关参数
        LocationClientOption option = new LocationClientOption();
        option.setOpenGps(true); // 打开gps
        option.setCoorType("bd09ll"); // 设置坐标类型
        option.setScanSpan(1000);

        //设置locationClientOption
        mLocationClient.setLocOption(option);

        //注册LocationListener监听器
        mLocationClient.registerLocationListener(new BDAbstractLocationListener() {
            @Override
            public void onReceiveLocation(BDLocation location) {
                //mapView 销毁后不在处理新接收的位置
                if (location == null || mMapView == null) {
                    return;
                }
                MyLocationData locData = new MyLocationData.Builder()
                        .accuracy(location.getRadius())
                        // 此处设置开发者获取到的方向信息，顺时针0-360
                        .direction(location.getDirection()).latitude(location.getLatitude())
                        .longitude(location.getLongitude()).build();
                mBaiduMap.setMyLocationData(locData);
            }
        });
        //开启地图定位图层
        mLocationClient.start();
    }

    private void addlistener() {
        BaiduMap.OnMapStatusChangeListener listener = new BaiduMap.OnMapStatusChangeListener() {
            /**
             * 手势操作地图，设置地图状态等操作导致地图状态开始改变。
             *
             * @param status 地图状态改变开始时的地图状态
             */
            @Override
            public void onMapStatusChangeStart(MapStatus status) {

            }

            /**
             * 手势操作地图，设置地图状态等操作导致地图状态开始改变。
             *
             * @param status 地图状态改变开始时的地图状态
             *
             * @param reason 地图状态改变的原因
             */

            //用户手势触发导致的地图状态改变,比如双击、拖拽、滑动底图
            //int REASON_GESTURE = 1;
            //SDK导致的地图状态改变, 比如点击缩放控件、指南针图标
            //int REASON_API_ANIMATION = 2;
            //开发者调用,导致的地图状态改变
            //int REASON_DEVELOPER_ANIMATION = 3;
            @Override
            public void onMapStatusChangeStart(MapStatus status, int reason) {
                // 不是开发者修改的地图状态
                if (reason != REASON_DEVELOPER_ANIMATION) {
                    float zoom = mBaiduMap.getMapStatus().zoom;
                    if (zoom > MAP_COMMUNITY_DISTRICT_BORDER) {
                        Toast showToast = Toast.makeText(CsdnmapActivity.this, "缩放层级刚好(" + zoom + "), 小区加载四大托", Toast.LENGTH_LONG);
                        loadcommunity();
                    } else {
                        Toast showToast = Toast.makeText(CsdnmapActivity.this, "缩放层级太大啦(" + zoom + ")", Toast.LENGTH_LONG);
                        showToast.setGravity(Gravity.CENTER, 0, 0);
                        showToast.show();
                    }
                }
            }

            /**
             * 地图状态变化中
             *
             * @param status 当前地图状态
             */
            @Override
            public void onMapStatusChange(MapStatus status) {

            }

            /**
             * 地图状态改变结束
             *
             * @param status 地图状态改变结束后的地图状态
             */
            @Override
            public void onMapStatusChangeFinish(MapStatus status) {

            }
        };
        //设置地图状态监听
        mBaiduMap.setOnMapStatusChangeListener(listener);
    }

    @Override
    protected void onResume() {
        super.onResume();
        //在activity执行onResume时执行mMapView. onResume ()，实现地图生命周期管理
        mMapView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        //在activity执行onPause时执行mMapView. onPause ()，实现地图生命周期管理
        mMapView.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //在activity执行onDestroy时执行mMapView.onDestroy()，实现地图生命周期管理
        mMapView.onDestroy();
    }

    class CsdnmapHttpgetTask extends AsyncTask<JSONObject, Integer, String> {

        String action;
        String url;

        CsdnmapHttpgetTask(String action, String url) {
            this.action = action;
            this.url = url;
        }


        // 方法1：onPreExecute（）
        // 作用：执行 线程任务前的操作
        @Override
        protected void onPreExecute() {
        }


        // 方法2：doInBackground（）
        // 作用：接收输入参数、执行任务中的耗时操作、返回 线程任务执行的结果
        // 此处通过计算从而模拟“加载进度”的情况
        @Override
        protected String doInBackground(JSONObject... params) {
            try {
                //找水源，创建URL
                //开水闸-openConnection
                String u = url;
                if (params.length > 0) {
                    u = url + jsonobject2params(params[0]);
                }
                Log.e("MAIN", u);
                HttpURLConnection httpURLConnection = (HttpURLConnection) new URL(u).openConnection();
                // 设定请求的方法为"POST"，默认是GET
//                httpURLConnection.setRequestMethod("POST");
                //建水管-InputStream
                InputStream inputStream = httpURLConnection.getInputStream();
                //建蓄水池蓄水-InputStreamReader
                InputStreamReader reader = new InputStreamReader(inputStream, "UTF-8");
                //水桶盛水-BufferedReader
                BufferedReader bufferedReader = new BufferedReader(reader);

                StringBuffer stringBuffer = new StringBuffer();
                String temp = null;

                while ((temp = bufferedReader.readLine()) != null) {
                    stringBuffer.append(temp);
                }
                bufferedReader.close();
                reader.close();
                inputStream.close();

                Log.e("MAIN", stringBuffer.toString());
                return stringBuffer.toString();

            } catch (MalformedURLException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
            return null;
        }

        // 方法3：onProgressUpdate（）
        // 作用：在主线程 显示线程任务执行的进度
        @Override
        protected void onProgressUpdate(Integer... progresses) {
        }

        // 方法4：onPostExecute（）
        // 作用：接收线程任务执行结果、将执行结果显示到UI组件
        @Override
        protected void onPostExecute(String result) {
            clearMarkers();
            if (ACTION_LOADCOMMUNITY.equals(action)) {
                addCommunityMarkers(result);
            }
        }
        // 方法5：onCancelled()
        // 作用：将异步任务设置为：取消状态
        @Override
        protected void onCancelled() {

        }

        private String jsonobject2params(JSONObject json) {
            StringBuffer sb = new StringBuffer();
            Iterator<String> keys = json.keys();
            String key;
            while (keys.hasNext()) {
                key = keys.next();
                try {
                    if (!"".equals(sb.toString())) {
                        sb.append("&");
                    }
                    sb.append(key + "=" + json.getString(key));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
            return "?" + sb.toString();
        }
    }
}
