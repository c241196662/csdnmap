package cordova.plugin.bakaan.csdnmap.adapter;

import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;

import java.util.List;

import cordova.plugin.bakaan.csdnmap.model.CsdnmapFilterModel;
import io.cordova.hellocordova.R;


public class CsdnmapFilterAdapter extends BaseQuickAdapter<CsdnmapFilterModel, BaseViewHolder> {


    public CsdnmapFilterAdapter(@Nullable List<CsdnmapFilterModel> data) {
        super(R.layout.layout_csdnmap_filter_item, data);
    }

    @Override
    protected void convert(BaseViewHolder helper, CsdnmapFilterModel item) {

        if (item.isSelected()) {
            helper.setBackgroundRes(R.id.tv_item, R.drawable.btn_blue);
            helper.setTextColor(R.id.tv_item, ContextCompat.getColor(mContext, R.color.white));
        } else {
            helper.setBackgroundRes(R.id.tv_item, R.drawable.btn_gray);
            helper.setTextColor(R.id.tv_item, ContextCompat.getColor(mContext, R.color.black));
        }

        helper.setText(R.id.tv_item, item.getValue());

    }


}
