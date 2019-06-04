package cordova.plugin.bakaan.csdnmap;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.databinding.DataBindingUtil;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.baidu.location.BDAbstractLocationListener;
import com.baidu.location.BDLocation;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;
import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BaiduMapOptions;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.CircleOptions;
import com.baidu.mapapi.map.MapPoi;
import com.baidu.mapapi.map.MapStatus;
import com.baidu.mapapi.map.MapStatusUpdate;
import com.baidu.mapapi.map.MapStatusUpdateFactory;
import com.baidu.mapapi.map.MapView;
import com.baidu.mapapi.map.MarkerOptions;
import com.baidu.mapapi.map.MyLocationConfiguration;
import com.baidu.mapapi.map.MyLocationData;
import com.baidu.mapapi.map.Overlay;
import com.baidu.mapapi.map.OverlayOptions;
import com.baidu.mapapi.map.Stroke;
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
import java.util.Objects;

import cordova.plugin.bakaan.csdnmap.adapter.CsdnmapFilterAdapter;
import cordova.plugin.bakaan.csdnmap.model.CsdnmapCQModel;
import cordova.plugin.bakaan.csdnmap.model.CsdnmapFilterModel;
import cordova.plugin.bakaan.csdnmap.model.CsdnmapSQModel;
import cordova.plugin.bakaan.csdnmap.model.SubwayStationCountModel;
import cordova.plugin.bakaan.csdnmap.model.SubwayStationModel;
import cordova.plugin.bakaan.csdnmap.popup.SubwayPop;
import io.cordova.hellocordova.R;
import io.cordova.hellocordova.databinding.ActivityCsdnmapBinding;

import static cordova.plugin.bakaan.csdnmap.Csdnmap.DATA_FLAG;
import static cordova.plugin.bakaan.csdnmap.Csdnmap.DATA_TYPE;
import static cordova.plugin.bakaan.csdnmap.Csdnmap.DATA_TYPE_LIST;
import static cordova.plugin.bakaan.csdnmap.Csdnmap.DATA_TYPE_MARKER;
import static cordova.plugin.bakaan.csdnmap.CsdnmapSearchActivity.TYPE_AREA_CQ;
import static cordova.plugin.bakaan.csdnmap.CsdnmapSearchActivity.TYPE_AREA_SQ;
import static cordova.plugin.bakaan.csdnmap.CsdnmapSearchActivity.TYPE_COMMUNITY;
import static cordova.plugin.bakaan.csdnmap.CsdnmapSearchActivity.TYPE_SUBWAY;
import static cordova.plugin.bakaan.csdnmap.CsdnmapSearchActivity.TYPE_SUBWAY_STATION;

public class CsdnmapActivity extends AppCompatActivity {

    public static final Integer RESULT_CODE = 10;
    private static Integer REQUEST_CODE = 2000;

    private static final String TYPE_COMUNITY = "type_community";
    private static final String TYPE_SQ = "type_sq";
    private static final String TYPE_CQ = "type_cq";

    public static final float MAP_AREA_COMMUNITY_BORDER = 17f;
    public static final float MAP_AREA_SQ_BORDER = 14f;
    public static final float MAP_AREA_CQ_BORDER = 13f;
    public static final float MAP_SUBWAY_BORDER = 18f;

    public static final String ACTION_LOADCOMMUNITY = "loadCommunity";
    public static final String ACTION_LOADSQ = "loadsq";
    public static final String ACTION_LOADCQ = "loadcq";


    public static final String ACTION_SEARCH_CQ = "get_cq";
    public static final String ACTION_SEARCH_SQ = "get_sq";
    public static final String ACTION_SEARCH_SUBWAY = "get_subway";
    public static final String ACTION_SEARCH_SUBWAY_STATION = "get_subway_station";
    public static final String ACTION_SEARCH_SUBWAY_STATION_COUNT = "get_subway_station_count";

    public static final String ACTION_SUBWAY_STATION_POP = "action_subway_station_pop";

    private MapView mMapView; // 地图框框
    private BaiduMap mBaiduMap; // 地图
    private LocationClient mLocationClient; // 定位
    private Overlay mAnchorMarker; // 标记点
    private BitmapDescriptor icon; // 图标

    private ActivityCsdnmapBinding mBinding;

    private List<Overlay> communitymarkers;
    private List<Overlay> cqmarkers;
    private List<Overlay> sqmarkers;

    private List<Overlay> subWayMarkers;
    private List<OverlayOptions> subWayMarkerList = new ArrayList<>();

    private BDLocation mCurrentLocation;

    //
    Overlay mCircle;

    // 范围
    private String distance = "0.5";
    private Double lat = 0d;
    private Double lng = 0d;

    // 区域编号
    private Long areaId;

    // 地铁线路编号
    private Long subId;
    private List<SubwayStationModel> subwayList = new ArrayList<>();

    // Drawer Recycler 数据源
    private List<CsdnmapFilterModel> priceList = new ArrayList<>();
    private List<CsdnmapFilterModel> typeList = new ArrayList<>();
    private List<CsdnmapFilterModel> areaList = new ArrayList<>();
    private List<CsdnmapFilterModel> brandList = new ArrayList<>();

    private SubwayPop mSubwayPop;

    // 是否是第一次进入地图
    private boolean isFirstIn = true;

    // 是否开启SeekBar滑动监听
    private boolean enableSeekBarListener = true;
    // 是否开启地图状态改变的监听
    private boolean enableMapStatusChangeListener = false;

    public CsdnmapActivity() {
        mMapView = null;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mBinding = DataBindingUtil.setContentView(this, R.layout.activity_csdnmap);

        initMap();
        initView();
        initDrawer();

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
        if (null != mLocationClient) {
            mLocationClient.stop();
        }

        if (null != mBaiduMap) {
            mBaiduMap.setMyLocationEnabled(false);
        }

        //在activity执行onDestroy时执行mMapView.onDestroy()，实现地图生命周期管理
        if (null != mMapView) {
            mMapView.onDestroy();
            mMapView = null;
        }

        super.onDestroy();
    }

    private void initView() {

        mBinding.flBack.setOnClickListener(view -> {
            finish();
        });

        mBinding.cvLocation.setOnClickListener(view -> {
            if (mCurrentLocation != null) {

                LatLng latLng = new LatLng(mCurrentLocation.getLatitude(), mCurrentLocation.getLongitude());
                MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newLatLng(latLng);
                mBaiduMap.animateMapStatus(mapStatusUpdate, 1000);

                // 清除已绘制的marker
                clearMarkers();

                drawCircle(mCurrentLocation.getLatitude(),  mCurrentLocation.getLongitude());

                loadCommunity();

            }

        });

        mBinding.flSearch.setOnClickListener(view -> {
            Intent intent = new Intent(CsdnmapActivity.this, CsdnmapSearchActivity.class);
            startActivityForResult(intent, REQUEST_CODE);
        });

        mBinding.cvList.setOnClickListener(view -> {
            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("key", "value");
            } catch (JSONException e) {
                e.printStackTrace();
            }

            setResult(Activity.RESULT_OK, new Intent().putExtra(DATA_FLAG, jsonObject.toString())
                    .putExtra(DATA_TYPE, DATA_TYPE_LIST));
            finish();
        });

        mBinding.cvSubway.setOnClickListener(view -> {
            getSubwayStationList(ACTION_SUBWAY_STATION_POP);
        });

        mBinding.sbDistance.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                int progress = seekBar.getProgress();

                if (enableSeekBarListener) {
                    enableSeekBarListener = false;
                    if (0 <= progress && progress < 13) {

                        seekBar.setProgress(0);
                        changeViewBySeekBar(0);

                    } else if (13 <= progress && progress < 38) {

                        seekBar.setProgress(25);
                        changeViewBySeekBar(25);

                    } else if (38 <= progress && progress < 63) {

                        seekBar.setProgress(50);
                        changeViewBySeekBar(50);

                    } else if (63 <= progress && progress < 88) {

                        seekBar.setProgress(75);
                        changeViewBySeekBar(75);

                    } else if (88 <= progress && progress <= 100) {

                        seekBar.setProgress(100);
                        changeViewBySeekBar(100);

                    }
                }

            }
        });

        addTabToTabLayout();

    }

    private void changeViewBySeekBar(int progress) {

        initDistanceView();
        if (progress == 0) {
            distance = "0.2";
            mBinding.tvDistance200.setTextColor(ContextCompat.getColor(this, R.color.blue));

        } else if (progress == 25) {
            distance = "0.5";
            mBinding.tvDistance200.setTextColor(ContextCompat.getColor(this, R.color.blue));
            mBinding.tvDistance500.setTextColor(ContextCompat.getColor(this, R.color.blue));

        } else if (progress == 50) {
            distance = "1";
            mBinding.tvDistance200.setTextColor(ContextCompat.getColor(this, R.color.blue));
            mBinding.tvDistance500.setTextColor(ContextCompat.getColor(this, R.color.blue));
            mBinding.tvDistance1000.setTextColor(ContextCompat.getColor(this, R.color.blue));

        } else if (progress == 75) {
            distance = "1.5";
            mBinding.tvDistance200.setTextColor(ContextCompat.getColor(this, R.color.blue));
            mBinding.tvDistance500.setTextColor(ContextCompat.getColor(this, R.color.blue));
            mBinding.tvDistance1000.setTextColor(ContextCompat.getColor(this, R.color.blue));
            mBinding.tvDistance1500.setTextColor(ContextCompat.getColor(this, R.color.blue));

        } else if (progress == 100) {
            distance = "";
            mBinding.tvDistance200.setTextColor(ContextCompat.getColor(this, R.color.blue));
            mBinding.tvDistance500.setTextColor(ContextCompat.getColor(this, R.color.blue));
            mBinding.tvDistance1000.setTextColor(ContextCompat.getColor(this, R.color.blue));
            mBinding.tvDistance1500.setTextColor(ContextCompat.getColor(this, R.color.blue));
            mBinding.tvDistanceCity.setTextColor(ContextCompat.getColor(this, R.color.blue));

        }

        // 清除原有的 小区气泡 重新加载，注意要先清除，不然marker添加顺序上会有显示问题
        clearMarkers(communitymarkers);

        drawClickEvent();

        loadCommunity();

        enableSeekBarListener = true;
    }

    private void initDistanceView() {
        mBinding.tvDistance200.setTextColor(ContextCompat.getColor(this, R.color.distance_gray));
        mBinding.tvDistance500.setTextColor(ContextCompat.getColor(this, R.color.distance_gray));
        mBinding.tvDistance1000.setTextColor(ContextCompat.getColor(this, R.color.distance_gray));
        mBinding.tvDistance1500.setTextColor(ContextCompat.getColor(this, R.color.distance_gray));
        mBinding.tvDistanceCity.setTextColor(ContextCompat.getColor(this, R.color.distance_gray));
    }

    private void initDrawer() {

        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(CsdnmapActivity.this, mBinding.dlLayout,
                R.string.activity_name, R.string.activity_name) {
            //菜单打开
            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
            }

            // 菜单关闭
            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
            }
        };
        mBinding.dlLayout.addDrawerListener(toggle);


        mBinding.flFilter.setOnClickListener(view -> {
            if (mBinding.dlLayout.isDrawerOpen(mBinding.llRightDrawerLayout)) {
                mBinding.dlLayout.closeDrawer(mBinding.llRightDrawerLayout);
            } else {
                mBinding.dlLayout.openDrawer(mBinding.llRightDrawerLayout);
            }
        });

        mBinding.edtPriceMin.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                clearFilter(priceList);
                mBinding.rvPrice.getAdapter().notifyDataSetChanged();
            }
        });

        mBinding.edtPriceMax.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                clearFilter(priceList);
                mBinding.rvPrice.getAdapter().notifyDataSetChanged();
            }
        });

        mBinding.btnClear.setOnClickListener(view -> {

            mBinding.edtPriceMin.setText("");
            mBinding.edtPriceMax.setText("");

            clearFilter(typeList);
            mBinding.rvType.getAdapter().notifyDataSetChanged();

            clearFilter(areaList);
            mBinding.rvArea.getAdapter().notifyDataSetChanged();

            clearFilter(brandList);
            mBinding.rvBrand.getAdapter().notifyDataSetChanged();

        });

        mBinding.btnConfirm.setOnClickListener(view -> {
            filter();
            mBinding.dlLayout.closeDrawer(mBinding.llRightDrawerLayout);
        });

        initDrawerRecycler();

    }

    private void clearFilter(List<CsdnmapFilterModel> list) {
        for (CsdnmapFilterModel model : list) {
            model.setSelected(false);
        }
    }

    private void initDrawerRecycler() {
        setLayoutManager(mBinding.rvPrice);
        setLayoutManager(mBinding.rvType);
        setLayoutManager(mBinding.rvArea);
        setLayoutManager(mBinding.rvBrand);

        priceList = getDrawerRecyclerData("price");
        typeList = getDrawerRecyclerData("type");
        areaList = getDrawerRecyclerData("area");
        brandList = getDrawerRecyclerData("brand");

        setRecyclerAdapter(mBinding.rvPrice, priceList);
        setRecyclerAdapter(mBinding.rvType, typeList);
        setRecyclerAdapter(mBinding.rvArea, areaList);
        setRecyclerAdapter(mBinding.rvBrand, brandList);
    }

    private void setLayoutManager(RecyclerView rv) {
        rv.setLayoutManager(new GridLayoutManager(this, 3) {
            @Override
            public boolean canScrollVertically() {
                return false;
            }
        });
        ((DefaultItemAnimator) rv.getItemAnimator()).setSupportsChangeAnimations(false);
    }

    private void setRecyclerAdapter(RecyclerView rv, List<CsdnmapFilterModel> list) {

        CsdnmapFilterAdapter csdnmapFilterAdapter = new CsdnmapFilterAdapter(list);
        rv.setAdapter(csdnmapFilterAdapter);

        csdnmapFilterAdapter.setOnItemClickListener((adapter, view, position) -> {

            CsdnmapFilterModel model = csdnmapFilterAdapter.getItem(position);

            model.setSelected(!model.isSelected());
            csdnmapFilterAdapter.notifyItemChanged(position);
        });
    }

    private List<CsdnmapFilterModel> getDrawerRecyclerData(String type) {
        List<CsdnmapFilterModel> list = new ArrayList<>();

        if (type.equals("price")) {

            CsdnmapFilterModel model = new CsdnmapFilterModel();
            model.setKey("0_1200");
            model.setValue("1200以内");
            list.add(model);

            CsdnmapFilterModel model1 = new CsdnmapFilterModel();
            model1.setKey("1200_1500");
            model1.setValue("1200-1500");
            list.add(model1);

            CsdnmapFilterModel model2 = new CsdnmapFilterModel();
            model2.setKey("1500_2000");
            model2.setValue("1500-2000");
            list.add(model2);

            CsdnmapFilterModel model3 = new CsdnmapFilterModel();
            model3.setKey("2000_3000");
            model3.setValue("2000-3000");
            list.add(model3);

            CsdnmapFilterModel model4 = new CsdnmapFilterModel();
            model4.setKey("3000_999999");
            model4.setValue("3000以上");
            list.add(model4);

        }

        if (type.equals("type")) {

            CsdnmapFilterModel model = new CsdnmapFilterModel();
            model.setKey("0");
            model.setValue("整租");
            list.add(model);

            CsdnmapFilterModel model1 = new CsdnmapFilterModel();
            model1.setKey("1");
            model1.setValue("合租");
            list.add(model1);

            CsdnmapFilterModel model2 = new CsdnmapFilterModel();
            model2.setKey("2");
            model2.setValue("品牌公寓");
            list.add(model2);

        }

        if (type.equals("area")) {

            CsdnmapFilterModel model = new CsdnmapFilterModel();
            model.setKey("0_50");
            model.setValue("50以下");
            list.add(model);

            CsdnmapFilterModel model1 = new CsdnmapFilterModel();
            model1.setKey("50_70");
            model1.setValue("50-70");
            list.add(model1);

            CsdnmapFilterModel model2 = new CsdnmapFilterModel();
            model2.setKey("70_90");
            model2.setValue("70-90");
            list.add(model2);

            CsdnmapFilterModel model3 = new CsdnmapFilterModel();
            model3.setKey("90_110");
            model3.setValue("90-110");
            list.add(model3);

            CsdnmapFilterModel model4 = new CsdnmapFilterModel();
            model4.setKey("110_130");
            model4.setValue("110-130");
            list.add(model4);

            CsdnmapFilterModel model5 = new CsdnmapFilterModel();
            model5.setKey("130_150");
            model5.setValue("130-150");
            list.add(model5);

            CsdnmapFilterModel model6 = new CsdnmapFilterModel();
            model6.setKey("150_200");
            model6.setValue("150-200");
            list.add(model6);

            CsdnmapFilterModel model7 = new CsdnmapFilterModel();
            model7.setKey("200_99999");
            model7.setValue("200以上");
            list.add(model7);

        }

        if (type.equals("brand")) {

            CsdnmapFilterModel model = new CsdnmapFilterModel();
            model.setKey("泊寓");
            model.setValue("泊寓");
            list.add(model);

            CsdnmapFilterModel model1 = new CsdnmapFilterModel();
            model1.setKey("魔方");
            model1.setValue("魔方");
            list.add(model1);

            CsdnmapFilterModel model2 = new CsdnmapFilterModel();
            model2.setKey("爱上租");
            model2.setValue("爱上租");
            list.add(model2);

            CsdnmapFilterModel model3 = new CsdnmapFilterModel();
            model3.setKey("红璞");
            model3.setValue("红璞");
            list.add(model3);

            CsdnmapFilterModel model4 = new CsdnmapFilterModel();
            model4.setKey("群岛");
            model4.setValue("群岛");
            list.add(model4);

            CsdnmapFilterModel model5 = new CsdnmapFilterModel();
            model5.setKey("冠寓");
            model5.setValue("冠寓");
            list.add(model5);

            CsdnmapFilterModel model6 = new CsdnmapFilterModel();
            model6.setKey("麦家");
            model6.setValue("麦家");
            list.add(model6);

            CsdnmapFilterModel model7 = new CsdnmapFilterModel();
            model7.setKey("自如");
            model7.setValue("自如");
            list.add(model7);

        }

        return list;
    }

    /**
     * 给TabLayout添加tab
     */
    private void addTabToTabLayout() {
        mBinding.tlTitle.addTab(mBinding.tlTitle.newTab().setText("租房"));

    }

    /**
     * 初始化地图
     */
    private void initMap() {
        BaiduMapOptions options = new BaiduMapOptions();
        // 设置地图模式为标准
        options.mapType(BaiduMap.MAP_TYPE_NORMAL);
        // 是否显示缩放按钮控件
        options.zoomControlsEnabled(false);
        // 是否显示比例尺控件
        options.scaleControlEnabled(false);
        mMapView = new MapView(this, options);

        mBinding.flMap.addView(mMapView);
        mBaiduMap = mMapView.getMap();

        mBaiduMap.setMyLocationEnabled(true);

        // 启动定位
        startLocation();

        // 添加监听器
        addMapListener();

    }

    /**
     * 加载小区列表
     */
    private void loadCommunity() {
        String url = "http://m.howzf.com/hzf/esf_communitylist.jspx";
        LatLngBounds bounds = mBaiduMap.getMapStatus().bound;
        LatLng ne = bounds.northeast; // 东百角坐标
        LatLng sw = bounds.southwest; // 西南角坐标

        JSONObject params = new JSONObject();
        try {
            if (!distance.equals("")) {
                params.put("lat", lat);
                params.put("lng", lng);
                params.put("distance", distance);
            }
            params.put("rp", 30);
            params.put("neLat", ne.latitude);
            params.put("neLng", ne.longitude);
            params.put("swLat", sw.latitude);
            params.put("swLng", sw.longitude);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        new CsdnmapHttpgetTask(ACTION_LOADCOMMUNITY, url, null).execute(params);
    }

    /**
     * 批量添加小区标记
     *
     * @param jsonstr
     */
    private void addCommunityMarkers(String jsonstr) {

        if (TextUtils.isEmpty(jsonstr)) {
            return;
        }

        try {
            JSONObject json = new JSONObject(jsonstr);
            addCommunityMarkers(json);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 批量添加小区标记
     *
     * @param json
     */
    private void addCommunityMarkers(JSONObject json) {
        Long totalCommunityCount = 0L;

        JSONArray list = null;
        List<OverlayOptions> pointlist = new ArrayList<>();
        try {
            list = json.getJSONArray("list");
            for (int i = 0; i < list.length(); i++) {
                JSONObject community = list.getJSONObject(i);

                // 计算共找到多少套房源
                int czCount = community.getInt("czcount");
                totalCommunityCount = totalCommunityCount + czCount;

                pointlist.add(buildCommunityMarker(community));
            }
            communitymarkers = mBaiduMap.addOverlays(pointlist);

            showTotalCommunityCount(totalCommunityCount);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 显示找到的 房源数量
     *
     * @param totalCommunityCount
     */
    private void showTotalCommunityCount(Long totalCommunityCount) {
        if (totalCommunityCount == 0L) {
            return;
        }

        mBinding.tvCount.setText(totalCommunityCount + "");
        mBinding.llCount.setVisibility(View.VISIBLE);

        new CountDownTimer(3000, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {

            }

            @Override
            public void onFinish() {
                // 倒计时3秒隐藏房源数量
                mBinding.llCount.setVisibility(View.GONE);
            }
        }.start();
    }

    /**
     * 添加小区标记
     *
     * @param community
     */
    private MarkerOptions buildCommunityMarker(JSONObject community) {
        try {
            String communityname = community.getString("communityname");
            float lat = (float) community.getDouble("prjy");
            float lng = (float) community.getDouble("prjx");
            int rentnum = community.getInt("czcount");
            Long communityId = community.getLong("communityid");

            LatLng latlng = new LatLng(lat, lng);
            //构建MarkerOption，用于在地图上添加Marker

            TextView textView = new TextView(getApplicationContext());
            textView.setText(communityname + "(" + rentnum + "套)");
            textView.setTextSize(16);
            textView.setGravity(Gravity.CENTER);

            Context appContext = this.getApplicationContext();
            String pkgName = appContext.getPackageName();
            Resources resource = appContext.getResources();
            int bgr = resource.getIdentifier("csdnmap_marker1", "drawable", pkgName);

            textView.setBackgroundResource(bgr);
//            textView.setBackgroundColor(0xccffffff);
            //将View转换为BitmapDescriptor
            BitmapDescriptor descriptor = BitmapDescriptorFactory.fromView(textView);

            Bundle extra = new Bundle();
            extra.putString("type", TYPE_COMUNITY);
            extra.putLong("communityId", communityId);

            return new MarkerOptions()
                    .position(latlng)
                    .extraInfo(extra)
                    .icon(descriptor);

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 加载商圈(sq)
     */
    private void loadsq() {
        loadArea(ACTION_LOADSQ);
    }

    /**
     * 加载城区(cq)
     */
    private void loadcq() {
        loadArea(ACTION_LOADCQ);
    }

    /**
     * 加载城区/商圈列表
     */
    private void loadArea(String action) {
        String url = "http://m.howzf.com/hzf/esf_arealist.jspx";
        LatLngBounds bounds = mBaiduMap.getMapStatus().bound;
        LatLng ne = bounds.northeast; // 东百角坐标
        LatLng sw = bounds.southwest; // 西南角坐标
        String[] key = {""};
        String[] values = {""};
        JSONObject params = new JSONObject();
        new CsdnmapHttpgetTask(action, url, null).execute(params);
    }

    /**
     * 批量添加商圈(sq)标记
     *
     * @param jsonstr
     */
    private void addSqMarkers(String jsonstr) {
        try {
            JSONObject json = new JSONObject(jsonstr);
            addSqMarkers(json);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 批量添加城区(cq)标记
     *
     * @param jsonstr
     */
    private void addCqMarkers(String jsonstr) {
        try {
            JSONObject json = new JSONObject(jsonstr);
            addCqMarkers(json);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 批量添加商圈(sq)标记
     *
     * @param json
     */
    private void addSqMarkers(JSONObject json) {
        JSONArray list = null;
        List<OverlayOptions> pointlist = new ArrayList<>();
        try {
            list = json.getJSONArray("sqlist");
            for (int i = 0; i < list.length(); i++) {
                JSONObject area = list.getJSONObject(i);
                pointlist.add(buildSqMarker(area));
            }
            sqmarkers = mBaiduMap.addOverlays(pointlist);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 批量添加城区(cq)标记
     *
     * @param json
     */
    private void addCqMarkers(JSONObject json) {
        JSONArray list = null;
        List<OverlayOptions> pointlist = new ArrayList<>();
        try {
            list = json.getJSONArray("cqlist");
            for (int i = 0; i < list.length(); i++) {
                JSONObject area = list.getJSONObject(i);
                pointlist.add(buildCqMarker(area));
            }
            cqmarkers = mBaiduMap.addOverlays(pointlist);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 添加城区/商圈标记
     *
     * @param area
     */
    private MarkerOptions buildCqMarker(JSONObject area) {
        try {
            String cqmc = area.getString("cqmc");
            float lat = (float) area.getDouble("gisy");
            float lng = (float) area.getDouble("gisx");
            int rentnum = area.getInt("rentnum");

            LatLng latlng = new LatLng(lat, lng);
            //构建MarkerOption，用于在地图上添加Marker

            TextView textView = new TextView(getApplicationContext());
            textView.setText(cqmc + "\n" + rentnum + "套");
            textView.setTextSize(14);
            textView.setGravity(Gravity.CENTER);

            Context appContext = this.getApplicationContext();
            String pkgName = appContext.getPackageName();
            Resources resource = appContext.getResources();
            int bgr = resource.getIdentifier("csdnmap_marker2", "drawable", pkgName);

            textView.setBackgroundResource(bgr);
//            textView.setBackgroundColor(0xccffffff);
            //将View转换为BitmapDescriptor
            BitmapDescriptor descriptor = BitmapDescriptorFactory.fromView(textView);

            Bundle extra = new Bundle();
            extra.putString("type", TYPE_CQ);
            extra.putFloat("lat", lat);
            extra.putFloat("lng", lng);

            return new MarkerOptions()
                    .position(latlng)
                    .extraInfo(extra)
                    .icon(descriptor);

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 添加城区/商圈标记
     *
     * @param area
     */
    private MarkerOptions buildSqMarker(JSONObject area) {
        try {
            String sqmc = area.getString("sqmc");
            float lat = (float) area.getDouble("gisy");
            float lng = (float) area.getDouble("gisx");
            int rentnum = area.getInt("rentnum");

            LatLng latlng = new LatLng(lat, lng);
            //构建MarkerOption，用于在地图上添加Marker

            TextView textView = new TextView(getApplicationContext());
            textView.setText(sqmc + "\n" + rentnum + "套");
            textView.setTextSize(14);
            textView.setGravity(Gravity.CENTER);

            Context appContext = this.getApplicationContext();
            String pkgName = appContext.getPackageName();
            Resources resource = appContext.getResources();
            int bgr = resource.getIdentifier("csdnmap_marker2", "drawable", pkgName);

            textView.setBackgroundResource(bgr);
//            textView.setBackgroundColor(0xccffffff);
            //将View转换为BitmapDescriptor
            BitmapDescriptor descriptor = BitmapDescriptorFactory.fromView(textView);

            Bundle extra = new Bundle();
            extra.putString("type", TYPE_SQ);
            extra.putFloat("lat", lat);
            extra.putFloat("lng", lng);

            return new MarkerOptions()
                    .position(latlng)
                    .extraInfo(extra)
                    .icon(descriptor);

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
        clearMarkers(cqmarkers);
        clearMarkers(sqmarkers);

        clearMarkers(subWayMarkers);
    }

    /**
     * 指定删除某一类标记物
     *
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
    private void startLocation() {

        mBaiduMap.setMyLocationConfiguration(new MyLocationConfiguration(MyLocationConfiguration.LocationMode.FOLLOWING,
                true,
                null, 0x00000000, 0x00000000));

        //定位初始化
        mLocationClient = new LocationClient(this);

        //通过LocationClientOption设置LocationClient相关参数
        LocationClientOption option = new LocationClientOption();
        option.setOpenGps(true); // 打开gps
        option.setCoorType("bd09ll"); // 设置坐标类型
//        option.setScanSpan(1000);
//        option.setLocationNotify(false);


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

                mCurrentLocation = location;

                lat = location.getLatitude();
                lng = location.getLongitude();

                MyLocationData locData = new MyLocationData.Builder()
                        .accuracy(location.getRadius())
                        // 此处设置开发者获取到的方向信息，顺时针0-360
                        .direction(location.getDirection())
                        .latitude(location.getLatitude())
                        .longitude(location.getLongitude()).build();
                mBaiduMap.setMyLocationData(locData);

                if (isFirstIn) {
                    // 画蓝色圆框框
                    drawCircle(location.getLatitude(), location.getLongitude());

                    // 默认加载一遍小区
                    loadCommunity();

                    isFirstIn = false;
                }

            }
        });
        //开启地图定位图层
        mLocationClient.start();
        Log.i("location", "location start");
    }

    /**
     * 加载地图监听器
     */
    private void addMapListener() {
        BaiduMap.OnMapStatusChangeListener statuschangelistener = new BaiduMap.OnMapStatusChangeListener() {
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

            }

            /**
             * 地图状态变化中
             *
             * @param status 当前地图状态
             */
            @Override
            public void onMapStatusChange(MapStatus status) {
                Log.e("onMapStatusChange", "(MapStatus status)");

                // 请注意，此监听会在 地图状态变化 时被重复调用，之所以使用此监听，是因为只有此监听可以 监听到 marker点击后的地图层级缩放 的事件
                // 所以此监听只在 marker点击事件中开发，其余情况不开放
                if (!enableMapStatusChangeListener) {
                    return;
                }

                lat = status.target.latitude;
                lng = status.target.longitude;

                float zoom = mBaiduMap.getMapStatus().zoom;

                Log.e("zoom", zoom + "");

                if (zoom >= MAP_AREA_COMMUNITY_BORDER) {
                    loadCommunity();
                } else if (zoom >= MAP_AREA_SQ_BORDER) {
                    loadsq();
                } else if (zoom >= MAP_AREA_CQ_BORDER) {
                    loadcq();
                } else {
                    Toast showToast = Toast.makeText(CsdnmapActivity.this, "缩放层级太大啦(" + zoom + ")", Toast.LENGTH_LONG);
                    showToast.setGravity(Gravity.CENTER, 0, 0);
                    showToast.show();
                }

                enableMapStatusChangeListener = false;
            }

            /**
             * 地图状态改变结束
             *
             * @param status 地图状态改变结束后的地图状态
             */
            @Override
            public void onMapStatusChangeFinish(MapStatus status) {
                Log.e("onMapStatusChangeFinish", "(MapStatus status)");

                lat = status.target.latitude;
                lng = status.target.longitude;

                float zoom = mBaiduMap.getMapStatus().zoom;

                Log.e("zoom", zoom + "");

                if (zoom >= MAP_AREA_COMMUNITY_BORDER) {
                    loadCommunity();
                } else if (zoom >= MAP_AREA_SQ_BORDER) {
                    loadsq();
                } else if (zoom >= MAP_AREA_CQ_BORDER) {
                    loadcq();
                } else {
                    Toast showToast = Toast.makeText(CsdnmapActivity.this, "缩放层级太大啦(" + zoom + ")", Toast.LENGTH_LONG);
                    showToast.setGravity(Gravity.CENTER, 0, 0);
                    showToast.show();
                }
            }
        };
        // 点击监听
        BaiduMap.OnMapClickListener clickListener = new BaiduMap.OnMapClickListener() {
            @Override
            public void onMapClick(LatLng latLng) {

                lat = latLng.latitude;
                lng = latLng.longitude;

                drawClickEvent();

                MapStatus mMapStatus = new MapStatus.Builder()
                        .target(latLng)
                        .zoom(MAP_AREA_COMMUNITY_BORDER)
                        .build();
                //定义MapStatusUpdate对象，以便描述地图状态将要发生的变化
                MapStatusUpdate mMapStatusUpdate = MapStatusUpdateFactory.newMapStatus(mMapStatus);
                //改变地图状态
                mBaiduMap.animateMapStatus(mMapStatusUpdate);
            }

            @Override
            public boolean onMapPoiClick(MapPoi mapPoi) {
                return false;
            }
        };
        // 设置地图状态监听
        mBaiduMap.setOnMapStatusChangeListener(statuschangelistener);
        // 设置地图点击监听
        mBaiduMap.setOnMapClickListener(clickListener);
        //marker被点击时回调的方法
        mBaiduMap.setOnMarkerClickListener(marker -> {
            //若响应点击事件，返回true，否则返回false

            Bundle bundle = marker.getExtraInfo();
            if (null == bundle) {
                return false;
            }

            String markerType = bundle.getString("type");
            if (TYPE_CQ.equals(markerType)) {

                // 开启地图状态改变监听
                enableMapStatusChangeListener = true;

                float latitude = bundle.getFloat("lat");
                float longitude = bundle.getFloat("lng");
                changeMapZoom(latitude, longitude, MAP_AREA_SQ_BORDER);


            } else if (TYPE_SQ.equals(markerType)) {

                // 开启地图状态改变监听
                enableMapStatusChangeListener = true;

                float latitude = bundle.getFloat("lat");
                float longitude = bundle.getFloat("lng");
                changeMapZoom(latitude, longitude, MAP_AREA_COMMUNITY_BORDER);

                // 重新绘制蓝色圈圈
                drawCircle(lat, lng);

            } else if (TYPE_COMUNITY.equals(markerType)) {

                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("communityid", bundle.getLong("communityId"));
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                setResult(Activity.RESULT_OK, new Intent().putExtra(DATA_FLAG, jsonObject.toString())
                        .putExtra(DATA_TYPE, DATA_TYPE_MARKER));
                finish();

            }


            return true;
        });
    }


    /**
     * 加载数据任务
     */
    class CsdnmapHttpgetTask extends AsyncTask<JSONObject, Integer, String> {

        String action;
        String url;
        Long flagId;

        CsdnmapHttpgetTask(String action, String url, Long flagId) {
            this.action = action;
            this.url = url;
            this.flagId = flagId;
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
                Log.e("HTTP URL", u);
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

                Log.e("HTTP RESPONSE", stringBuffer.toString());
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
            } else if (ACTION_LOADCQ.equals(action)) {
                addCqMarkers(result);
            } else if (ACTION_LOADSQ.equals(action)) {
                addSqMarkers(result);
            } else if (ACTION_SEARCH_SUBWAY.equals(action)) {
                moveToSubwayLine(result);
            } else if (ACTION_SEARCH_SUBWAY_STATION.equals(action)) {
                moveToSubwayStation(result);
            } else if (ACTION_SEARCH_SUBWAY_STATION_COUNT.equals(action)) {
                countSubwayStation(result, flagId);
            } else if (ACTION_SEARCH_SQ.equals(action)) {
                moveToSQ(result);
            } else if (ACTION_SEARCH_CQ.equals(action)) {
                moveToCQ(result);
            } else if (ACTION_SUBWAY_STATION_POP.equals(action)) {
                showSubwayPop(result);
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

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (REQUEST_CODE == requestCode) {

            if (null == data) {
                return;
            }

            if (null == data.getExtras()) {
                return;
            }

            if (resultCode == TYPE_AREA_CQ) {

                areaId = (Long) data.getExtras().get("id");
                loadArea(ACTION_SEARCH_CQ);

            } else if (resultCode == TYPE_AREA_SQ) {

                areaId = (Long) data.getExtras().get("id");
                loadArea(ACTION_SEARCH_SQ);

            } else if (resultCode == TYPE_COMMUNITY) {

                setResult(Activity.RESULT_OK, new Intent().putExtra(DATA_FLAG, data.getExtras().get("id") + "")
                        .putExtra(DATA_TYPE, DATA_TYPE_MARKER));
                finish();

            } else if (resultCode == TYPE_SUBWAY) {

                subId = (Long) data.getExtras().get("id");
                if (subId != null) {
                    getSubwayStation(ACTION_SEARCH_SUBWAY);
                }

            } else if (resultCode == TYPE_SUBWAY_STATION) {

                subId = (Long) data.getExtras().get("id");
                if (subId != null) {
                    getSubwayStation(ACTION_SEARCH_SUBWAY_STATION);
                }

            }


        }
    }

    /**
     * 加载地铁站
     */
    private void getSubwayStation(String action) {
        String url = "http://jia3.tmsf.com/hzf/hzf_subway.jspx?openid=90886E8949BF9D70247B33D4D1D02488B3256D09&uuid=";
        JSONObject params = new JSONObject();
        new CsdnmapHttpgetTask(action, url, null).execute(params);
    }

    /**
     * 添加地铁站气泡
     *
     * @param result
     */
    private void moveToSubwayLine(String result) {

        double lineCenterStationLat = 0;
        double lineCenterStationLng = 0;

        subwayList.clear();
        try {
            JSONObject json = new JSONObject(result);
            JSONArray subwayArray = json.getJSONArray("list");
            List<SubwayStationModel> allSubwayList = com.alibaba.fastjson.JSONArray.parseArray(subwayArray.toString(), SubwayStationModel.class);
            for (SubwayStationModel subwayStationModel : allSubwayList) {

                if (Objects.equals(subwayStationModel.getPsubid(), subId)) {
                    subwayList.add(subwayStationModel);
                }

                // 根据线路判断要展示的中心站点
                if (subId == 1L) {

                    if (subwayStationModel.getSubname().equals("打铁关")) {
                        lineCenterStationLat = Double.parseDouble(subwayStationModel.getPrjy());
                        lineCenterStationLng = Double.parseDouble(subwayStationModel.getPrjx());
                    }

                } else if (subId == 2L) {

                    if (subwayStationModel.getSubname().equals("建国北路")) {
                        lineCenterStationLat = Double.parseDouble(subwayStationModel.getPrjy());
                        lineCenterStationLng = Double.parseDouble(subwayStationModel.getPrjx());
                    }

                } else if (subId == 4L) {

                    if (subwayStationModel.getSubname().equals("近江")) {
                        lineCenterStationLat = Double.parseDouble(subwayStationModel.getPrjy());
                        lineCenterStationLng = Double.parseDouble(subwayStationModel.getPrjx());
                    }

                }

            }

            // 搜索地铁线路时，计算该地铁站所有站点1公里范围内的小区房源总数
            distance = "1";
            changeMapZoom(lineCenterStationLat, lineCenterStationLng, 14f);

            subWayMarkerList.clear();
            for (SubwayStationModel stationModel : subwayList) {
                getSubwayStationCount(stationModel);
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void moveToCQ(String result) {

        try {
            JSONObject json = new JSONObject(result);
            JSONArray subwayArray = json.getJSONArray("cqlist");
            List<CsdnmapCQModel> cqModelList = com.alibaba.fastjson.JSONArray.parseArray(subwayArray.toString(), CsdnmapCQModel.class);
            for (CsdnmapCQModel cqModel : cqModelList) {
                if (Objects.equals(cqModel.getCqid(), areaId)) {

                    changeMapZoom(Double.parseDouble(cqModel.getGisy()), Double.parseDouble(cqModel.getGisx()), MAP_AREA_CQ_BORDER);

                    loadcq();
                }

            }


        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void moveToSQ(String result) {

        try {
            JSONObject json = new JSONObject(result);
            JSONArray subwayArray = json.getJSONArray("sqid");
            List<CsdnmapSQModel> sqModelList = com.alibaba.fastjson.JSONArray.parseArray(subwayArray.toString(), CsdnmapSQModel.class);
            for (CsdnmapSQModel sqModel : sqModelList) {
                if (Objects.equals(sqModel.getSqid(), areaId)) {

                    changeMapZoom(Double.parseDouble(sqModel.getGisy()), Double.parseDouble(sqModel.getGisx()), MAP_AREA_SQ_BORDER);

                    loadsq();
                }

            }


        } catch (JSONException e) {
            e.printStackTrace();
        }
    }


    private void moveToSubwayStation(String result) {

        try {
            JSONObject json = new JSONObject(result);
            JSONArray subwayArray = json.getJSONArray("list");
            List<SubwayStationModel> allSubwayList = com.alibaba.fastjson.JSONArray.parseArray(subwayArray.toString(), SubwayStationModel.class);
            for (SubwayStationModel stationModel : allSubwayList) {
                if (Objects.equals(stationModel.getSubid(), subId)) {

                    distance = "0.5";
                    changeMapZoom(Double.parseDouble(stationModel.getPrjy()), Double.parseDouble(stationModel.getPrjx()), MAP_SUBWAY_BORDER);
                }

            }


        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 根据地铁站经纬度、范围查询 站点房源数量
     */
    private void getSubwayStationCount(SubwayStationModel stationModel) {
        String url = "http://jia3.tmsf.com/hzf/esf_communitylist.jspx?distance=" + distance + "&fanglingzoom=&lat="
                + stationModel.getPrjy() + "&lng=" + stationModel.getPrjx()
                + "&mapfwcxzoom=&maphousetypezoom=&mapjzmjzoom=&mappricezoom=&mapratezoom=&mapszlczoom=&mapzxbzzoom="
                + "&openid=90886E8949BF9D70247B33D4D1D02488B3256D09&rp=30&uuid=";
        JSONObject params = new JSONObject();
        new CsdnmapHttpgetTask(ACTION_SEARCH_SUBWAY_STATION_COUNT, url, stationModel.getSubid()).execute(params);
    }

    /**
     * 遍历地铁站周围房源 计算总房源数量，并添加气泡
     *
     * @param result
     * @param subId
     */
    private void countSubwayStation(String result, Long subId) {

        try {
            JSONObject json = new JSONObject(result);
            JSONArray subwayCountArray = json.getJSONArray("list");
            List<SubwayStationCountModel> subwayStationCountList = com.alibaba.fastjson.JSONArray.parseArray(subwayCountArray.toString(), SubwayStationCountModel.class);

            Long czCount = 0L;
            for (SubwayStationCountModel countModel : subwayStationCountList) {

                czCount = czCount + countModel.getCzcount();
            }


            for (SubwayStationModel stationModel : subwayList) {

                if (Objects.equals(stationModel.getSubid(), subId)) {
                    stationModel.setCzcount(czCount);

                    subWayMarkerList.add(buildSubWayMarker(stationModel));
                }

            }
            subWayMarkers = mBaiduMap.addOverlays(subWayMarkerList);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 添加地铁站气泡
     *
     * @param stationModel
     */
    private MarkerOptions buildSubWayMarker(SubwayStationModel stationModel) {
        String name = stationModel.getSubname();
        Double lat = Double.parseDouble(stationModel.getPrjy());
        Double lng = Double.parseDouble(stationModel.getPrjx());
        Long czCount = stationModel.getCzcount();

        LatLng latlng = new LatLng(lat, lng);
        //构建MarkerOption，用于在地图上添加Marker

        TextView textView = new TextView(getApplicationContext());
        textView.setText(name + "\n" + czCount + "套");
        textView.setTextSize(14);
        textView.setGravity(Gravity.CENTER);

        Context appContext = this.getApplicationContext();
        String pkgName = appContext.getPackageName();
        Resources resource = appContext.getResources();
        int bgr = resource.getIdentifier("csdnmap_marker2", "drawable", pkgName);

        textView.setBackgroundResource(bgr);
//            textView.setBackgroundColor(0xccffffff);
        //将View转换为BitmapDescriptor
        BitmapDescriptor descriptor = BitmapDescriptorFactory.fromView(textView);
        return new MarkerOptions()
                .position(latlng)
                .icon(descriptor);
    }

    /**
     * 筛选小区列表
     */
    private void filter() {
        String url = "http://m.howzf.com/hzf/esf_communitylist.jspx";
        LatLngBounds bounds = mBaiduMap.getMapStatus().bound;

        LatLng ne = bounds.northeast; // 东百角坐标
        LatLng sw = bounds.southwest; // 西南角坐标
        JSONObject params = new JSONObject();
        try {
            params.put("rp", 30);
            params.put("neLat", ne.latitude);
            params.put("neLng", ne.longitude);
            params.put("swLat", sw.latitude);
            params.put("swLng", sw.longitude);

            if (!distance.equals("")) {
                params.put("lat", lat);
                params.put("lng", lng);
                params.put("distance", distance);
            }
            params.put("maprentzjjezoom", getFilterData(priceList) + getCustomPrice());
            params.put("maprenttypezoom", getFilterData(typeList));
            params.put("maprentjzmjzoom", getFilterData(areaList));
            params.put("maprentppmczoom", getFilterData(brandList));
        } catch (JSONException e) {
            e.printStackTrace();
        }

        new CsdnmapHttpgetTask(ACTION_LOADCOMMUNITY, url, null).execute(params);
    }

    /**
     * 组装本地筛选数据
     *
     * @param list
     * @return
     */
    private String getFilterData(List<CsdnmapFilterModel> list) {
        String data = "";
        for (CsdnmapFilterModel model : list) {

            if (model.isSelected()) {
                data = data + model.getKey() + ",";
            }

        }

        return data.length() > 0 ? data.substring(0, data.length() - 1) : data;

    }

    /**
     * 获取自定义填写的筛选价格
     *
     * @return
     */
    private String getCustomPrice() {
        String data = "";

        String min;
        String max;
        if (!TextUtils.isEmpty(mBinding.edtPriceMin.getText().toString())
                && !TextUtils.isEmpty(mBinding.edtPriceMax.getText().toString())) {

            if (TextUtils.isEmpty(mBinding.edtPriceMin.getText().toString())) {
                min = "0";
            } else {
                min = mBinding.edtPriceMin.getText().toString().trim();
            }

            if (TextUtils.isEmpty(mBinding.edtPriceMin.getText().toString())) {
                max = "99999";
            } else {
                max = mBinding.edtPriceMin.getText().toString().trim();
            }

            data = min + "_" + max;
        }

        return data;
    }

    /**
     * 点击事件绘图
     */
    private void drawClickEvent() {

        drawCircle(lat, lng);

        drawPoint(lat, lng);
    }

    /**
     * 绘制蓝色圆形框框
     *
     * @param latitude
     * @param longitude
     */
    private void drawCircle(double latitude, double longitude) {
        if (mCircle != null) {
            mCircle.remove();
        }

        if (distance.equals("")) {
            return;
        }

        //圆心位置
        LatLng center = new LatLng(latitude, longitude);

        double radius = Double.parseDouble(distance) * 1000;

        //构造CircleOptions对象
        CircleOptions mCircleOptions = new CircleOptions().center(center)
                .radius((int) radius)
                .fillColor(0xBFCEE3FF) //填充颜色
                .stroke(new Stroke(1, 0xBFCEE300)); //边框宽和边框颜色

        //在地图上显示圆
        mCircle = mBaiduMap.addOverlay(mCircleOptions);

        float level = 0f;
        if (distance.equals("0.2")) {
            level = 18f;
        } else if (distance.equals("0.5")) {
            level = 17f;
        } else if (distance.equals("1")) {
            level = 16f;
        } else if (distance.equals("1.5")) {
            level = 15f;
        } else if (distance.equals("")) {
            level = 12f;
        }

        changeMapZoom(latitude, longitude, level);
    }

    /**
     * 绘制图钉
     *
     * @param latitude
     * @param longitude
     */
    private void drawPoint(double latitude, double longitude) {
        if (mAnchorMarker != null) {
            mAnchorMarker.remove();
        }

        //圆心位置
        LatLng point = new LatLng(latitude, longitude);

        Context appContext = CsdnmapActivity.this.getApplicationContext();
        String pkgName = appContext.getPackageName();
        Resources resource = appContext.getResources();
        int marker = resource.getIdentifier("csdnmapanchormarker", "drawable", pkgName);
        MarkerOptions options = new MarkerOptions();
        options.position(point)
                .icon(BitmapDescriptorFactory
                        .fromResource(marker))
                .animateType(MarkerOptions.MarkerAnimateType.jump)
                .period(1);
        mAnchorMarker = mBaiduMap.addOverlay(options);
    }

    /**
     * 加载地铁站列表构建Pop
     */
    private void getSubwayStationList(String action) {
        String url = "http://m.howzf.com/hzf/hzf_subway.jspx";
        JSONObject params = new JSONObject();
        new CsdnmapHttpgetTask(action, url, null).execute(params);
    }

    /**
     * 根据获取的数据加载 显示PopupWindow
     *
     * @param result
     */
    private void showSubwayPop(String result) {

        try {
            JSONObject json = new JSONObject(result);
            JSONArray subwayCountArray = json.getJSONArray("list");
            List<SubwayStationModel> subwayStationList = com.alibaba.fastjson.JSONArray.parseArray(subwayCountArray.toString(), SubwayStationModel.class);

            if (subwayStationList == null || subwayStationList.size() == 0) {
                return;
            }

            mSubwayPop = new SubwayPop(this, subwayStationList);
            mSubwayPop.setItemClickListener(new SubwayPop.onItemClickListener() {
                @Override
                public void onCancelClick() {
                    mSubwayPop.dismiss();
                }

                @Override
                public void onConfirmClick(SubwayStationModel station) {
                    if (null == station) {
                        Toast.makeText(CsdnmapActivity.this, "请选择站点", Toast.LENGTH_SHORT);
                        return;
                    }

                    subway(station);
                    mSubwayPop.dismiss();
                }
            });

            mSubwayPop.showPopupWindow();

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 地铁找房点击事件
     *
     * @param station
     */
    private void subway(SubwayStationModel station) {

        if (station.getSubname().equals("全部")) {

            subId = station.getSubid();
            if (subId != null) {
                getSubwayStation(ACTION_SEARCH_SUBWAY);
            }

        } else {

            subId = station.getSubid();
            if (subId != null) {
                getSubwayStation(ACTION_SEARCH_SUBWAY_STATION);
            }

        }
    }

    /**
     * 修改坐标和缩放级别
     *
     * @param latitude
     * @param longitude
     * @param level
     */
    private void changeMapZoom(double latitude, double longitude, float level) {
        Log.e("changeMapZoom()", "level=" + level);

        //圆心位置
        LatLng center = new LatLng(latitude, longitude);

        // 初始化定位
        MapStatus.Builder builder = new MapStatus.Builder();
        builder.target(center).zoom(level); // 地图缩放级别
        mBaiduMap.setMapStatus(MapStatusUpdateFactory.newMapStatus(builder.build()));
    }
}
