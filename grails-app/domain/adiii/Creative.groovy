package adiii

class Creative
{
    String name
    String link
    String displayText
    String imageUrl
    Float price

    static belongsTo = Campaign
    static hasMany = [impressions: Impression, clicks: Click]

    static constraints = {
        name(blank: false, size: 1..30, unique: true)
        link blank: false, url: true, validator: {val, obj ->
            try {
                new URL(val).openStream()
                return true
            } catch (Exception e) {
                return false
            }
        }
        displayText(blank:false, size: 1..48)
        imageUrl(blank:false)
    }
}
