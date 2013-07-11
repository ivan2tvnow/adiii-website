package adiii

class DailyStat {

    Integer impression = 0
    Integer click = 0
    Date statDate = new Date()

    static belongsTo = [campaign: Campaign]

    static constraints = {
    }
}
