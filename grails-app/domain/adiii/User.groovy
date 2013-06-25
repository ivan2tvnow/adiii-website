package adiii

class User {

    String email
    String password
    String firstName
    String lastName
    String company
    String country = "台灣"

    String apiKey

    static hasMany = [campaigns: Campaign]

    static constraints = {
        email(blank: false)
        password(blank: false)
        lastName(blank: false)
        firstName(blank: false)
        company(blank: false)

        apiKey(blank: false)
    }
}
