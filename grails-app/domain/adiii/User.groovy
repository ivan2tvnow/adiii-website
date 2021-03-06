package adiii

class User {

	transient springSecurityService

	String firstname
    String lastname
	String password
    String email
    String country
    String company
    String apikey
	boolean enabled
	boolean accountExpired
	boolean accountLocked
	boolean passwordExpired

    static hasMany = [campaigns: Campaign]

	static constraints = {
        firstname blank: false
        lastname blank: false
        email blank: false, unique: true, email: true
		password blank: false
	}

	static mapping = {
		password column: '`password`'
        campaigns sort: "id", order: "desc"
	}

	Set<Role> getAuthorities() {
		UserRole.findAllByUser(this).collect { it.role } as Set
	}

	def beforeInsert() {
		encodePassword()
	}

	def beforeUpdate() {
		if (isDirty('password')) {
			encodePassword()
		}
	}

	protected void encodePassword() {
		password = springSecurityService.encodePassword(password)
	}
}
