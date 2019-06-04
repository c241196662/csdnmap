package cordova.plugin.bakaan.csdnmap.popup;

import android.app.Activity;
import android.content.Context;
import android.databinding.DataBindingUtil;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.LinearLayoutManager;
import android.view.View;
import android.view.ViewGroup;

import java.util.ArrayList;
import java.util.List;

import cordova.plugin.bakaan.csdnmap.adapter.CsdnmapSubwayLineAdapter;
import cordova.plugin.bakaan.csdnmap.adapter.CsdnmapSubwayStationAdapter;
import cordova.plugin.bakaan.csdnmap.model.SubwayLineModel;
import cordova.plugin.bakaan.csdnmap.model.SubwayStationModel;
import io.cordova.hellocordova.R;
import io.cordova.hellocordova.databinding.PopSubwayBinding;
import razerdp.basepopup.BasePopupWindow;


public class SubwayPop extends BasePopupWindow implements View.OnClickListener {

    private Context mContext;
    private PopSubwayBinding mBinding;

    private List<SubwayLineModel> list = new ArrayList<>();
    private List<SubwayStationModel> stationList = new ArrayList<>();

    private CsdnmapSubwayStationAdapter subwayStationAdapter;

    private onItemClickListener itemClickListener;

    private SubwayStationModel model;

    @Override
    public View onCreateContentView() {
        mBinding = DataBindingUtil.inflate(((Activity) getContext()).getLayoutInflater(), R.layout.pop_subway, null, false);
        initClickListener();
        return mBinding.getRoot();
    }

    /**
     * @param context
     */
    public SubwayPop(Context context, List<SubwayStationModel> list) {
        super(context, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        mContext = context;

        setData(list);
    }

    /**
     * 自行组装数据
     *
     * @param stationList
     */
    private void setData(List<SubwayStationModel> stationList) {

        SubwayLineModel line1_1 = new SubwayLineModel();
        line1_1.setName("1号线(下沙江滨)");
        List<SubwayStationModel> line1_1_station = new ArrayList<>();

        // 自行 添加一个全部的选项
        SubwayStationModel line1_1_all = new SubwayStationModel();
        line1_1_all.setSubid(1L);
        line1_1_all.setSubname("全部");
        line1_1_station.add(line1_1_all);

        for (SubwayStationModel station : stationList) {
            if (station.getPsubid() == 1L) {
                if (!station.getSubname().equals("乔司南") && !station.getSubname().equals("乔司")
                        && !station.getSubname().equals("翁梅")
                        && !station.getSubname().equals("余杭高铁站")
                        && !station.getSubname().equals("南苑")
                        && !station.getSubname().equals("临平")) {
                    line1_1_station.add(station);
                }
            }
        }
        line1_1.setList(line1_1_station);
        line1_1.setSelected(true);


        SubwayLineModel line1_2 = new SubwayLineModel();
        line1_2.setName("1号线(临平)");
        List<SubwayStationModel> line1_2_station = new ArrayList<>();

        // 自行 添加一个全部的选项
        SubwayStationModel line1_2_all = new SubwayStationModel();
        line1_2_all.setSubid(1L);
        line1_2_all.setSubname("全部");
        line1_2_station.add(line1_2_all);

        for (SubwayStationModel station : stationList) {
            if (station.getPsubid() == 1L) {
                if (!station.getSubname().equals("下沙西") && !station.getSubname().equals("金沙湖")
                        && !station.getSubname().equals("高沙路")
                        && !station.getSubname().equals("文泽路")
                        && !station.getSubname().equals("文海南路")
                        && !station.getSubname().equals("云水")
                        && !station.getSubname().equals("下沙江滨")) {
                    line1_2_station.add(station);
                }
            }
        }
        line1_2.setList(line1_2_station);


        SubwayLineModel line2 = new SubwayLineModel();
        line2.setName("2号线");
        List<SubwayStationModel> line2_station = new ArrayList<>();

        // 自行 添加一个全部的选项
        SubwayStationModel line2_all = new SubwayStationModel();
        line2_all.setSubid(1L);
        line2_all.setSubname("全部");
        line2_station.add(line2_all);

        for (SubwayStationModel station : stationList) {
            if (station.getPsubid() == 2L) {
                line2_station.add(station);
            }
        }
        line2.setList(line2_station);


        SubwayLineModel line4 = new SubwayLineModel();
        line4.setName("4号线");
        List<SubwayStationModel> line4_station = new ArrayList<>();

        // 自行 添加一个全部的选项
        SubwayStationModel line4_all = new SubwayStationModel();
        line4_all.setSubid(1L);
        line4_all.setSubname("全部");
        line4_station.add(line4_all);

        for (SubwayStationModel station : stationList) {
            if (station.getPsubid() == 4L) {
                line4_station.add(station);
            }
        }
        line4.setList(line4_station);

        list.add(line1_1);
        list.add(line1_2);
        list.add(line2);
        list.add(line4);

        initLineRecycle();
    }

    private void initLineRecycle() {
        mBinding.rvLine.setLayoutManager(new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false));
        ((DefaultItemAnimator) mBinding.rvLine.getItemAnimator()).setSupportsChangeAnimations(false);

        CsdnmapSubwayLineAdapter subwayLineAdapter = new CsdnmapSubwayLineAdapter(list);
        mBinding.rvLine.setAdapter(subwayLineAdapter);
        subwayLineAdapter.setOnItemClickListener((adapter, view, position) -> {

            SubwayLineModel model = (SubwayLineModel) adapter.getItem(position);

            for (SubwayLineModel lineModel : list) {
                lineModel.setSelected(false);
            }
            list.get(position).setSelected(true);
            subwayLineAdapter.notifyDataSetChanged();

            stationList.clear();
            stationList.addAll(model.getList());
            subwayStationAdapter.notifyDataSetChanged();
        });

        stationList.clear();
        stationList.addAll(list.get(0).getList());
        initStationRecycle();
    }

    private void initStationRecycle() {
        mBinding.rvStation.setLayoutManager(new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false));
        ((DefaultItemAnimator) mBinding.rvStation.getItemAnimator()).setSupportsChangeAnimations(false);

        subwayStationAdapter = new CsdnmapSubwayStationAdapter(stationList);
        mBinding.rvStation.setAdapter(subwayStationAdapter);
        subwayStationAdapter.setOnItemClickListener((adapter, view, position) -> {

            model = (SubwayStationModel) adapter.getItem(position);

            for (SubwayStationModel stationModel : stationList) {
                stationModel.setSelected(false);
            }
            stationList.get(position).setSelected(true);
            subwayStationAdapter.notifyDataSetChanged();

        });
    }

    /**
     * 初始化点击事件
     */
    private void initClickListener() {
        mBinding.tvCancel.setOnClickListener(this);
        mBinding.tvConfirm.setOnClickListener(this);
    }


    @Override
    public void onClick(View view) {

        if (itemClickListener != null) {

            switch (view.getId()) {
                case R.id.tv_cancel:
                    itemClickListener.onCancelClick();
                    break;

                case R.id.tv_confirm:
                    itemClickListener.onConfirmClick(model);
                    break;
            }
        }

        dismiss();
    }


    public interface onItemClickListener {
        void onCancelClick();

        void onConfirmClick(SubwayStationModel station);
    }

    public SubwayPop setItemClickListener(onItemClickListener itemClickListener) {
        this.itemClickListener = itemClickListener;
        return this;
    }
}
