package adiii

class DailyStat {

    Integer impression = 0
    Integer click = 0
    String statDate = new Date().format("yyyy/MM/dd")

    static belongsTo = [campaign: Campaign]

    static constraints = {
    }
}
