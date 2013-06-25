package adiii

class Campaign {

    String name
    Integer dailyBudget
    Currency currency = 'NTD'
    Date startDatetime
    Boolean hasEndDatetime = false
    Date endDatetime
    String campaignType

    Date createdDatetime = new Date()

    static belongsTo = [user: User]
    static hasMany = [creatives: Creative]

    static constraints = {
        name(blank: false, size: 1..30, unique: true)
        dailyBudget(min: 50)
    }

    enum Currency{
        NTD, USD
    }

    enum ProductType {
        FOOD, COSMETICS, ENTERTAINMENT, MALE_CLOTHES, FEMALE_CLOTHES, WEB_SITE, ANDROID_APP, IOS_APP
    }
}
