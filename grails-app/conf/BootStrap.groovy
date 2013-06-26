import adiii.User
import adiii.Role
import adiii.UserRole

class BootStrap {

    def init = { servletContext ->
        Role.findByAuthority('DEVELOPER') ?: new Role(authority: 'DEVELOPER').save(flush: true)
        Role.findByAuthority('ADVERTISER') ?: new Role(authority: 'ADVERTISER').save(flush: true)
        def adminRole = Role.findByAuthority('ADMIN') ?: new Role(authority: 'ADMIN').save(flush: true)

        def adminUser = User.findByEmail('admin@iii.org') ?: new User(
                firstname: 'admin',
                lastname: 'admin',
                password: 'admin',
                email: 'admin@iii.org',
                country: 'Taiwan',
                company: 'III',
                apikey: 'ADMIN',
                enabled: true).save(failOnError: true)

        if (!adminUser.authorities.contains(adminRole)) {
            UserRole.create adminUser, adminRole
        }
    }
    def destroy = {
    }
}
