package cordova.plugin.bakaan.csdnmap.model;

/**
 * Created by cdkj on 2019/6/3.
 */

public class CsdnmapCQModel {


    /**
     * cqid : 330108
     * cqmc : 滨江
     * gisx : 120.218175
     * gisy : 30.212637
     * sellnum : 5422
     * gwnum : 24
     * signprice : 32060
     * rentnum : 1264
     */

    private Long cqid;
    private String cqmc;
    private String gisx;
    private String gisy;
    private Long sellnum;
    private Long gwnum;
    private Long signprice;
    private Long rentnum;

    public Long getCqid() {
        return cqid;
    }

    public void setCqid(Long cqid) {
        this.cqid = cqid;
    }

    public String getCqmc() {
        return cqmc;
    }

    public void setCqmc(String cqmc) {
        this.cqmc = cqmc;
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

    public Long getSignprice() {
        return signprice;
    }

    public void setSignprice(Long signprice) {
        this.signprice = signprice;
    }

    public Long getRentnum() {
        return rentnum;
    }

    public void setRentnum(Long rentnum) {
        this.rentnum = rentnum;
    }
}
