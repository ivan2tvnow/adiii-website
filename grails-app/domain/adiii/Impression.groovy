package adiii

class Impression
{
    String deviceId
    String ipAddress
    Date createdDatetime = new Date()

    static belongsTo = [campaign: Campaign]

    static constraints = {
        ipAddress(blank: false)
    }
}
