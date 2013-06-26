package adiii

class AdiiiController
{
    def springSecurityService

    def index()
    {
        if (springSecurityService.isLoggedIn())
        {
            def auth = springSecurityService.authentication
            String username = auth.name
            def authorities = auth.authorities // a Collection of GrantedAuthority
            if (authorities == ['ROLE_ADVERTISER'])
            {
                redirect(controller: "advertiser", action: "index")
            }

            render view: 'index'
        }
        else
        {
            render view: 'index'
        }

    }
}
