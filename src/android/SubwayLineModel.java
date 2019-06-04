package cordova.plugin.bakaan.csdnmap.model;

import java.util.List;

/**
 * Created by cdkj on 2019/6/2.
 */

public class SubwayLineModel {


    private String name;

    private Boolean isSelected = false;

    private List<SubwayStationModel> list;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Boolean getSelected() {
        return isSelected;
    }

    public void setSelected(Boolean selected) {
        isSelected = selected;
    }

    public List<SubwayStationModel> getList() {
        return list;
    }

    public void setList(List<SubwayStationModel> list) {
        this.list = list;
    }
}
