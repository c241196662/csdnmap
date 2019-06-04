package cordova.plugin.bakaan.csdnmap.adapter;

import android.support.annotation.Nullable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;

import java.util.List;

import cordova.plugin.bakaan.csdnmap.model.CsdnmapSearchModel;
import io.cordova.hellocordova.R;


public class CsdnmapSearchHistoryAdapter extends BaseQuickAdapter<CsdnmapSearchModel, BaseViewHolder> {


    public CsdnmapSearchHistoryAdapter(@Nullable List<CsdnmapSearchModel> data) {
        super(R.layout.layout_csdnmap_search_history, data);
    }

    @Override
    protected void convert(BaseViewHolder helper, CsdnmapSearchModel item) {

        helper.setText(R.id.tv_name, item.getName());
    }


}
