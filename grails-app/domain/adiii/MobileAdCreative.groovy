package adiii

class MobileAdCreative extends Creative {

    static constraints = {
        imageUrl blank: false, validator: {val, obj ->
            if (val == "reject") {
                return false
            }
        }
    }
}
