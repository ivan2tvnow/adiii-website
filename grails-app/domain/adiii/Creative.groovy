package adiii

class Creative
{
    String name
    String link
    String displayText
    String imageUrl

    static belongsTo = Campaign
    static hasMany = [impressions: Impression, clicks: Click]

    static constraints = {
        name(blank: false, size: 1..30, unique: true)
        link(blank: false, url: true)
        displayText(blank:false, size: 1..48)
        imageUrl(blank:false)
    }
}
