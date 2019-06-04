package cordova.plugin.bakaan.csdnmap.adapter;

import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;

import java.util.List;

import cordova.plugin.bakaan.csdnmap.model.SubwayStationModel;
import io.cordova.hellocordova.R;


public class CsdnmapSubwayStationAdapter extends BaseQuickAdapter<SubwayStationModel, BaseViewHolder> {

    public CsdnmapSubwayStationAdapter(@Nullable List<SubwayStationModel> data) {
        super(R.layout.layout_csdnmap_subway_line, data);
    }

    @Override
    protected void convert(BaseViewHolder helper, SubwayStationModel item) {

        if (item.getSelected()) {
            helper.setTextColor(R.id.tv_name, ContextCompat.getColor(mContext, R.color.blue));
        } else {
            helper.setTextColor(R.id.tv_name, ContextCompat.getColor(mContext, R.color.black));
        }

        helper.setText(R.id.tv_name, item.getSubname());

    }


}
