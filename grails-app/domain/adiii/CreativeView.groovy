package adiii

class CreativeView {
    String deviceId
    String ipAddress
    Date createdDatetime = new Date()

    static belongsTo = [creative: Creative]

    static constraints = {
        ipAddress(blank: false)
    }
}
