package cordova.plugin.bakaan.csdnmap.model;

/**
 * Created by cdkj on 2019/6/2.
 */

public class CsdnmapFilterModel {

    private String key;
    private String value;
    private boolean isSelected = false;

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
    }
}
