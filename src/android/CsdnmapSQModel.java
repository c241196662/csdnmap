package cordova.plugin.bakaan.csdnmap.model;

/**
 * Created by cdkj on 2019/6/3.
 */

public class CsdnmapSQModel {


    /**
     * sqid : 1000103
     * sqmc : 浦沿
     * cqid : 330108
     * gisx : 120.155189
     * gisy : 30.177148
     * sellnum : 1861
     * gwnum : 4
     * rentnum : 440
     */

    private Long sqid;
    private String sqmc;
    private Long cqid;
    private String gisx;
    private String gisy;
    private Long sellnum;
    private Long gwnum;
    private Long rentnum;

    public Long getSqid() {
        return sqid;
    }

    public void setSqid(Long sqid) {
        this.sqid = sqid;
    }

    public String getSqmc() {
        return sqmc;
    }

    public void setSqmc(String sqmc) {
        this.sqmc = sqmc;
    }

    public Long getCqid() {
        return cqid;
    }

    public void setCqid(Long cqid) {
        this.cqid = cqid;
    }

    public String getGisx() {
        return gisx;
    }

    public void setGisx(String gisx) {
        this.gisx = gisx;
    }

    public String getGisy() {
        return gisy;
    }

    public void setGisy(String gisy) {
        this.gisy = gisy;
    }

    public Long getSellnum() {
        return sellnum;
    }

    public void setSellnum(Long sellnum) {
        this.sellnum = sellnum;
    }

    public Long getGwnum() {
        return gwnum;
    }

    public void setGwnum(Long gwnum) {
        this.gwnum = gwnum;
    }

    public Long getRentnum() {
        return rentnum;
    }

    public void setRentnum(Long rentnum) {
        this.rentnum = rentnum;
    }
}
