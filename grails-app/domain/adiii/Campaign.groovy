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
    }

    static mapping = {
        creatives sort: "id", order: "desc"
    }

    enum Currency{
        NTD, USD
    }

    enum ProductType {
        FOOD, COSMETICS, ENTERTAINMENT, MALE_CLOTHES, FEMALE_CLOTHES, WEB_SITE, ANDROID_APP, IOS_APP
    }
}
