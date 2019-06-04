package cordova.plugin.bakaan.csdnmap.adapter;

import android.support.annotation.Nullable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;

import java.util.List;
import java.util.Objects;

import cordova.plugin.bakaan.csdnmap.model.CsdnmapSearchModel;
import io.cordova.hellocordova.R;

import static cordova.plugin.bakaan.csdnmap.CsdnmapSearchActivity.TYPE_AREA;
import static cordova.plugin.bakaan.csdnmap.CsdnmapSearchActivity.TYPE_COMMUNITY;
import static cordova.plugin.bakaan.csdnmap.CsdnmapSearchActivity.TYPE_SUBWAY;


public class CsdnmapSearchAdapter extends BaseQuickAdapter<CsdnmapSearchModel, BaseViewHolder> {

    private List<CsdnmapSearchModel> subwayLineList;

    public CsdnmapSearchAdapter(@Nullable List<CsdnmapSearchModel> data, @Nullable List<CsdnmapSearchModel> subwayLine) {
        super(R.layout.layout_csdnmap_search, data);
        subwayLineList = subwayLine;
    }

    @Override
    protected void convert(BaseViewHolder helper, CsdnmapSearchModel item) {

        String name = "";
        String desc = "";

        if (Objects.equals(TYPE_AREA, item.getType())){

            if (item.getPareaid() == 33){
                name = item.getName()+"-城区";
            }else {
                name = item.getName()+"-商圈";
            }
            desc = "在租"+item.getCzcount()+"套";

        } else if(Objects.equals(TYPE_COMMUNITY, item.getType())){

            name = item.getName();
            desc = "在租"+item.getCzcount()+"套";

        }else if(Objects.equals(TYPE_SUBWAY, item.getType())){

            name = item.getName();

            if (item.getPsubid() != 0){
                for (CsdnmapSearchModel model : subwayLineList) {
                    if (Objects.equals(model.getSubid(), item.getPsubid())){
                        desc = model.getName();
                    }
                }
            }


        }

        helper.setText(R.id.tv_name, name);
        helper.setText(R.id.tv_desc, desc);
    }


}
