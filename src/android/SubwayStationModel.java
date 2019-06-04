package cordova.plugin.bakaan.csdnmap.model;

/**
 * Created by cdkj on 2019/6/2.
 */

public class SubwayStationModel {


    /**
     * communityid : 0
     * isdisplay : 1
     * levelid : 0
     * linkid : 0
     * modtime :
     * orderid : 1
     * prjx : 120.187604
     * prjy : 30.250151
     * psubid : 1
     * schoolrmk :
     * subid : 107
     * subname : 城站
     * subwayname : 1号线
     */

    private Long communityid;
    private Long isdisplay;
    private Long levelid;
    private Long linkid;
    private String modtime;
    private Long orderid;
    private String prjx;
    private String prjy;
    private Long psubid;
    private String schoolrmk;
    private Long subid;
    private String subname;
    private String subwayname;

    private Long czcount;

    private Boolean isSelected  = false;

    public Long getCommunityid() {
        return communityid;
    }

    public void setCommunityid(Long communityid) {
        this.communityid = communityid;
    }

    public Long getIsdisplay() {
        return isdisplay;
    }

    public void setIsdisplay(Long isdisplay) {
        this.isdisplay = isdisplay;
    }

    public Long getLevelid() {
        return levelid;
    }

    public void setLevelid(Long levelid) {
        this.levelid = levelid;
    }

    public Long getLinkid() {
        return linkid;
    }

    public void setLinkid(Long linkid) {
        this.linkid = linkid;
    }

    public String getModtime() {
        return modtime;
    }

    public void setModtime(String modtime) {
        this.modtime = modtime;
    }

    public Long getOrderid() {
        return orderid;
    }

    public void setOrderid(Long orderid) {
        this.orderid = orderid;
    }

    public String getPrjx() {
        return prjx;
    }

    public void setPrjx(String prjx) {
        this.prjx = prjx;
    }

    public String getPrjy() {
        return prjy;
    }

    public void setPrjy(String prjy) {
        this.prjy = prjy;
    }

    public Long getPsubid() {
        return psubid;
    }

    public void setPsubid(Long psubid) {
        this.psubid = psubid;
    }

    public String getSchoolrmk() {
        return schoolrmk;
    }

    public void setSchoolrmk(String schoolrmk) {
        this.schoolrmk = schoolrmk;
    }

    public Long getSubid() {
        return subid;
    }

    public void setSubid(Long subid) {
        this.subid = subid;
    }

    public String getSubname() {
        return subname;
    }

    public void setSubname(String subname) {
        this.subname = subname;
    }

    public String getSubwayname() {
        return subwayname;
    }

    public void setSubwayname(String subwayname) {
        this.subwayname = subwayname;
    }

    public Long getCzcount() {
        return czcount;
    }

    public void setCzcount(Long czcount) {
        this.czcount = czcount;
    }

    public Boolean getSelected() {
        return isSelected;
    }

    public void setSelected(Boolean selected) {
        isSelected = selected;
    }
}
