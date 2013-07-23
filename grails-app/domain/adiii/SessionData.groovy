package adiii

import groovy.time.TimeCategory

class SessionData {

    String accessKey
    String deviceId
    Date expireTime = new Date()
    boolean impression = false
    boolean click = false

    static belongsTo = [campaign: Campaign]

    static constraints = {
        accessKey unique: true, blank: false
        deviceId blank: false
        expireTime nullable: false
        impression blank: false
        click blank: false
        campaign nullable: true
    }

    static mapping = {
    }

    def beforeInsert() {
        use(TimeCategory) {
            this.expireTime += 1.hours
        }
    }
}
