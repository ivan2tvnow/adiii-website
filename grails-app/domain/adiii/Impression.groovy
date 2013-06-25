package adiii

class Impression
{
    String deviceId
    String ipAddress
    Date createdDatetime = new Date()

    static belongsTo = Creative

    static constraints = {
        ipAddress(blank: false)
    }
}
