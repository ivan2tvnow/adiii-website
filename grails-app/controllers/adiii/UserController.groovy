package adiii

/*
 *  進行與使用者帳號相關的操作, 麗如帳號資訊設定, 登出等等的controller.
 *  此controller中的操作皆與金錢無關.
 */
class UserController {

    def save()
    {
        def userRole
        if (params.user_type == "advertiser")
        {
            userRole = Role.findByAuthority('ROLE_ADVERTISER') ?: new Role(authority: 'ROLE_ADVERTISER').save(failOnError: true)
        }

        def guestUser = User.findByEmail(params.email) ?: new User(
                firstname: params.firstname,
                lastname: params.lastname,
                password: params.passwd,
                email: params.email,
                country: params.country,
                company: params.company,
                apikey: generateUserKey(),
                enabled: true)

        if (!guestUser.validate())
        {
            guestUser.errors.allErrors.each { println it }
            flash.message = "資料有錯!"
        } else
        {
            guestUser.save(flush: true)

            if (!guestUser.authorities.contains(userRole)) {
                UserRole.create guestUser, userRole
            }

            flash.message = '註冊成功: ' + guestUser.email
        }

        redirect controller: 'adiii', action: 'index'
    }

    def signup()
    {
        Map modelMap = [:]
        modelMap.countrylist = ['台灣']

        render(view: "signup", model: modelMap)
    }

    def account()
    {

    }

    def logout()
    {

    }

    def keyGenerator = { String alphabet, int n ->
        new Random().with {
            (1..n).collect { alphabet[ nextInt( alphabet.length() ) ] }.join()
        }
    }

    def generateUserKey() {
        return keyGenerator((('A'..'Z') + ('0'..'9')).join(), 9)
    }
}
