package adiii

class Campaign {

    String name
    Integer dailyBudget
    Currency currency = 'NTD'
    Date startDatetime
    Boolean hasEndDatetime = false
    Date endDatetime
    Date createdDatetime = new Date()
    String productType
    String status

    static belongsTo = [user: User]
    static hasMany = [creatives: Creative, impressions: Impression]

    static constraints = {
        name(blank: false, size: 1..30, unique: true)
        dailyBudget(min: 50)
        hasEndDatetime validator: {val, obj ->
            if (val == true && obj.startDatetime.after(obj.endDatetime)) {
                return false
            }
        }
        productType blank: true
        status blank: true
    }

    static mapping = {
        creatives sort: "id", order: "desc"
    }

    enum Currency {
        NTD, USD
    }

    def beforeUpdate() {
        def todaty = new Date()

        if (this.endDatetime < todaty)
        {
            this.status = "END"
        }
        else if (this.creatives.size() == 0)
        {
            this.status = "DRAFT"
        }
    }

    def getVideoCreativeCount() {
        int count = 0
        this.creatives.each { creative->
            if (creative instanceof adiii.VideoAdCreative)
            {
                count ++
            }
        }
    }

    def getMobileCreativeCount() {
        int count = 0
        this.creatives.each { creative->
            if (creative instanceof adiii.MobileAdCreative)
            {
                count ++
            }
        }
    }
}
