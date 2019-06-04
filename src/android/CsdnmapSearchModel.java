package cordova.plugin.bakaan.csdnmap.model;

/**
 * Created by cdkj on 2019/6/2.
 */

public class CsdnmapSearchModel {

    /**
     * name : 余杭
     * py : YUHANG
     * py2 : YH
     * areaid : 330184
     * pareaid : 33
     * cscount : 18970
     * czcount : 1521
     * xqcount : 1536
     */

    private String name;
    private String py;
    private String py2;
    private Integer type;

    // 区域
    private Long areaid;
    private Long pareaid;
    private Long xqcount;

    // 小区
    private Long communityid;
    private Long fylx;
    private Long apid;
    private Long allkzts;

    // 小区、区域公用
    private Long cscount;
    private Long czcount;

    // 地铁
    private Long subid;
    private Long psubid;
    private String subname;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPy() {
        return py;
    }

    public void setPy(String py) {
        this.py = py;
    }

    public String getPy2() {
        return py2;
    }

    public void setPy2(String py2) {
        this.py2 = py2;
    }

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public Long getAreaid() {
        return areaid;
    }

    public void setAreaid(Long areaid) {
        this.areaid = areaid;
    }

    public Long getPareaid() {
        return pareaid;
    }

    public void setPareaid(Long pareaid) {
        this.pareaid = pareaid;
    }

    public Long getXqcount() {
        return xqcount;
    }

    public void setXqcount(Long xqcount) {
        this.xqcount = xqcount;
    }

    public Long getCommunityid() {
        return communityid;
    }

    public void setCommunityid(Long communityid) {
        this.communityid = communityid;
    }

    public Long getFylx() {
        return fylx;
    }

    public void setFylx(Long fylx) {
        this.fylx = fylx;
    }

    public Long getApid() {
        return apid;
    }

    public void setApid(Long apid) {
        this.apid = apid;
    }

    public Long getAllkzts() {
        return allkzts;
    }

    public void setAllkzts(Long allkzts) {
        this.allkzts = allkzts;
    }

    public Long getCscount() {
        return cscount;
    }

    public void setCscount(Long cscount) {
        this.cscount = cscount;
    }

    public Long getCzcount() {
        return czcount;
    }

    public void setCzcount(Long czcount) {
        this.czcount = czcount;
    }

    public Long getSubid() {
        return subid;
    }

    public void setSubid(Long subid) {
        this.subid = subid;
    }

    public Long getPsubid() {
        return psubid;
    }

    public void setPsubid(Long psubid) {
        this.psubid = psubid;
    }

    public String getSubname() {
        return subname;
    }

    public void setSubname(String subname) {
        this.subname = subname;
    }
}
