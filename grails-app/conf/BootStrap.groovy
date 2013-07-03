import adiii.Role

class BootStrap {

    def init = { servletContext ->
        Role.findByAuthority('ROLE_ADMIN') ?: new Role(authority: 'ROLE_ADMIN').save(flush: true)
        Role.findByAuthority('ROLE_DEVELOPER') ?: new Role(authority: 'ROLE_DEVELOPER').save(flush: true)
        Role.findByAuthority('ROLE_ADVERTISER') ?: new Role(authority: 'ROLE_ADVERTISER').save(flush: true)
    }

    def destroy = {
    }
}
