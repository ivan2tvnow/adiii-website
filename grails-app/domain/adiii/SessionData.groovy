package adiii

import groovy.time.TimeCategory

class SessionData {

    String accessKey
    String deviceId
    Date expireTime = new Date()
    boolean impression = false
    boolean click = false

    static belongsTo = [campaign: Campaign, creative: Creative]

    static constraints = {
        accessKey unique: true, blank: false
        deviceId blank: false
        expireTime nullable: false
        impression blank: false
        click blank: false
        campaign nullable: false
        creative nullable: false
    }

    static mapping = {
        creative cascade:'all-delete-orphan'
    }

    def beforeInsert() {
        use(TimeCategory) {
            this.expireTime += 1.hours
        }
    }
}
