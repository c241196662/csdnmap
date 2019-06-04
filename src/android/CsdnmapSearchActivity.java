package cordova.plugin.bakaan.csdnmap;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.alibaba.fastjson.JSON;

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

import cordova.plugin.bakaan.csdnmap.adapter.CsdnmapSearchAdapter;
import cordova.plugin.bakaan.csdnmap.adapter.CsdnmapSearchHistoryAdapter;
import cordova.plugin.bakaan.csdnmap.model.CsdnmapSearchModel;
import io.cordova.hellocordova.R;

/**
 * Created by clkj on 2019/6/2.
 */

public class CsdnmapSearchActivity extends AppCompatActivity {

    public static final Integer TYPE_AREA = 0;
    public static final Integer TYPE_AREA_CQ = 1;
    public static final Integer TYPE_AREA_SQ = 2;
    public static final Integer TYPE_COMMUNITY = 3;
    public static final Integer TYPE_SUBWAY = 4;
    public static final Integer TYPE_SUBWAY_STATION = 5;

    private static final String SP_NAME = "csdn_search_history";
    private static final String HISTORY_KEY = "csdn_search_history_key";

    // 全量查询数据
    private List<CsdnmapSearchModel> dataList = new ArrayList<>();

    // 地铁线数据（用于搜索列表 地铁站描述转译）
    private List<CsdnmapSearchModel> subwayLineList = new ArrayList<>();

    private LinearLayout llHistory;

    private RecyclerView rvSearch;
    private CsdnmapSearchAdapter mCsdnmapSearchAdapter;
    private List<CsdnmapSearchModel> searchList = new ArrayList<>();

    private RecyclerView rvHistory;
    private CsdnmapSearchHistoryAdapter mCsdnmapSearchHistoryAdapter;
    private List<CsdnmapSearchModel> historyList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_csdnmap_search);

        initView();
        initAdapter();
        initHistory();
        getData();

    }

    private void initView() {
        rvSearch = findViewById(R.id.rv_search);
        rvHistory = findViewById(R.id.rv_history);

        llHistory = findViewById(R.id.ll_history);
        LinearLayout llSearch = findViewById(R.id.ll_search);

        EditText etKeyword = findViewById(R.id.et_keyword);

        ImageView ivDeleteKeyword = findViewById(R.id.iv_delete_keyword);
        ivDeleteKeyword.setOnClickListener(view -> {
            etKeyword.setText("");
        });

        etKeyword.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                if (TextUtils.isEmpty(editable.toString())) {
                    llSearch.setVisibility(View.GONE);
                    ivDeleteKeyword.setVisibility(View.GONE);
                } else {
                    llSearch.setVisibility(View.VISIBLE);
                    ivDeleteKeyword.setVisibility(View.VISIBLE);
                    search(editable.toString());
                }

            }

        });

        TextView tvCancel = findViewById(R.id.tv_cancel);
        tvCancel.setOnClickListener(view -> {
            finish();
        });


        ImageView ivDeleteHistory = findViewById(R.id.iv_delete_history);
        ivDeleteHistory.setOnClickListener(view -> {
            SharedPreferences sp = CsdnmapSearchActivity.this.getSharedPreferences(SP_NAME,
                    Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = sp.edit();
            editor.remove(HISTORY_KEY);
            editor.apply();

            historyList.clear();
            mCsdnmapSearchHistoryAdapter.notifyDataSetChanged();
            llHistory.setVisibility(View.GONE);
        });

    }

    private void initAdapter() {

        rvSearch.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        ((DefaultItemAnimator) rvSearch.getItemAnimator()).setSupportsChangeAnimations(false);

        mCsdnmapSearchAdapter = new CsdnmapSearchAdapter(searchList, subwayLineList);
        rvSearch.setAdapter(mCsdnmapSearchAdapter);
        mCsdnmapSearchAdapter.setOnItemClickListener((adapter, view, position) -> {

            CsdnmapSearchModel model = (CsdnmapSearchModel) adapter.getItem(position);

            showSearch(model);
            addHistory(model);

        });

        rvHistory.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        ((DefaultItemAnimator) rvHistory.getItemAnimator()).setSupportsChangeAnimations(false);

        mCsdnmapSearchHistoryAdapter = new CsdnmapSearchHistoryAdapter(historyList);
        rvHistory.setAdapter(mCsdnmapSearchHistoryAdapter);
        mCsdnmapSearchHistoryAdapter.setOnItemClickListener((adapter, view, position) -> {

            CsdnmapSearchModel model = (CsdnmapSearchModel) adapter.getItem(position);
            showSearch(model);
        });
    }

    private void initHistory() {

        SharedPreferences sp = this.getSharedPreferences(SP_NAME,
                Context.MODE_PRIVATE);

        if (sp.contains(HISTORY_KEY)) {

            String historyJson = sp.getString(HISTORY_KEY, "");
            historyList.addAll(com.alibaba.fastjson.JSONArray.parseArray(historyJson, CsdnmapSearchModel.class));

            if (historyList != null && historyList.size() > 0) {

                llHistory.setVisibility(View.VISIBLE);

                mCsdnmapSearchHistoryAdapter.notifyDataSetChanged();
            }

        }

    }

    private void showSearch(CsdnmapSearchModel model) {

        if (Objects.equals(TYPE_AREA, model.getType())) {
            if (model.getPareaid()== 33){
                setResult(TYPE_AREA_CQ, new Intent().putExtra("id", model.getAreaid()));
            }else {
                setResult(TYPE_AREA_SQ, new Intent().putExtra("id", model.getAreaid()));
            }

            finish();

        } else if (Objects.equals(TYPE_COMMUNITY, model.getType())) {

            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("communityid", model.getCommunityid());
            } catch (JSONException e) {
                e.printStackTrace();
            }

            setResult(TYPE_COMMUNITY, new Intent().putExtra("id", jsonObject.toString()));
            finish();

        } else if (Objects.equals(TYPE_SUBWAY, model.getType())) {

            if (model.getPsubid() == 0L){
                setResult(TYPE_SUBWAY, new Intent().putExtra("id", model.getSubid()));
            }else {
                setResult(TYPE_SUBWAY_STATION, new Intent().putExtra("id", model.getSubid()));
            }

            finish();

        }


    }

    private void addHistory(CsdnmapSearchModel model) {

        SharedPreferences sp = this.getSharedPreferences(SP_NAME,
                Context.MODE_PRIVATE);

        if (sp.contains(HISTORY_KEY)) {

            String historyJson = sp.getString(HISTORY_KEY, "");
            List<CsdnmapSearchModel> history = com.alibaba.fastjson.JSONArray.parseArray(historyJson, CsdnmapSearchModel.class);
            history.add(model);

            SharedPreferences.Editor editor = sp.edit();
            editor.remove(HISTORY_KEY);
            editor.putString(HISTORY_KEY, com.alibaba.fastjson.JSONArray.parseArray(JSON.toJSONString(history)).toJSONString());
            editor.apply();

        } else {

            List<CsdnmapSearchModel> history = new ArrayList<>();
            history.add(model);

            SharedPreferences.Editor editor = sp.edit();
            editor.putString(HISTORY_KEY, com.alibaba.fastjson.JSONArray.parseArray(JSON.toJSONString(history)).toJSONString());
            editor.apply();

        }

    }


    private void search(String keyword) {

        searchList.clear();
        for (CsdnmapSearchModel csdnmapSearchModel : dataList) {

            if (csdnmapSearchModel.getName().contains(keyword)
                    || csdnmapSearchModel.getPy().contains(keyword.toUpperCase())
                    || csdnmapSearchModel.getPy2().contains(keyword.toUpperCase())) {
                searchList.add(csdnmapSearchModel);
            }

        }

        mCsdnmapSearchAdapter.notifyDataSetChanged();

    }


    private void getData() {
        String url = "http://m.howzf.com/hzf/hzf_keywordlist.jspx";
        JSONObject params = new JSONObject();
        new CsdnmapSearchHttpgetTask(url).execute(params);
    }

    /**
     * 加载数据任务
     */
    class CsdnmapSearchHttpgetTask extends AsyncTask<JSONObject, Integer, String> {

        String url;

        CsdnmapSearchHttpgetTask(String url) {
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
            initData(result);
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

    private void initData(String result) {
        try {
            JSONObject json = new JSONObject(result);

            JSONArray areaArray = json.getJSONArray("arealist");
            List<CsdnmapSearchModel> areaList = com.alibaba.fastjson.JSONArray.parseArray(areaArray.toString(), CsdnmapSearchModel.class);
            for (CsdnmapSearchModel model : areaList) {
                model.setType(TYPE_AREA);
            }
            dataList.addAll(areaList);

            JSONArray communityArray = json.getJSONArray("communitylist");
            List<CsdnmapSearchModel> communityList = com.alibaba.fastjson.JSONArray.parseArray(communityArray.toString(), CsdnmapSearchModel.class);
            for (CsdnmapSearchModel model : communityList) {
                model.setType(TYPE_COMMUNITY);
            }
            dataList.addAll(communityList);

            JSONArray subwayArray = json.getJSONArray("subwaylist");
            List<CsdnmapSearchModel> subwayList = com.alibaba.fastjson.JSONArray.parseArray(subwayArray.toString(), CsdnmapSearchModel.class);
            for (CsdnmapSearchModel model : subwayList) {
                model.setType(TYPE_SUBWAY);

                if (model.getPsubid() == 0){
                    subwayLineList.add(model);
                }
            }
            dataList.addAll(subwayList);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

}
