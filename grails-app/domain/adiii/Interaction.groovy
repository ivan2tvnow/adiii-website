package adiii

class Interaction {

    String accessKey
    Date accessTime = new Date()
    boolean impression = false
    boolean click = false
    MobileAdCreative creative

    static constraints = {
        accessKey unique: true
    }
}
