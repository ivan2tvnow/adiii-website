package adiii

/*
 *  處理各式ad tracking event的controller
 *  需處理的事件請參考VAST 3.0 spec.
 */
class TrackingController
{

    def impression()
    {
        //  以下4個URL取至Google的VAST sample response, 作為實作參考.
        //  http://127.0.0.1:8080/adiii/imp;v7;x;222296909;0-0;0;45922216;0/0;35460632/35478450/2;;~aopt=0/0/ff/0;~cs=h%3fhttp://127.0.0.1:8080/adiii/dot.gif
        //  http://127.0.0.1:8080/adiii/imp?data=HlUIB8s5lhs%2FEdizbnWfe03MoLNZwbiP4RXhAzjCRwE2womxknIOHwtmRDvprh5Kl70pGxbNRteWvqfeNcwny%2FOVqu%2B6va5HvapN21XoqOM4jQdfSrJchvY0GLgYikA%2BfIqu7lO1rE4BumugNTQYvh%2BjKL3iHIvD634zmlWdFlLsRs7pUK4g82pD67q2zfasFhVq1zW4VtTVXSgUdxAldNZEAgaQ6hk0oQFKhhoN1dvQHsAq9JBykzeH5%2FfXMbBZ1s5Ng91C9ElWCv2wo5fOvqp%2FuCOPPgbWJef%2FBmVrPsDwAc8mdac6YYjUKPmjP1nN4agplME0i9GpNw4Co4hCQw%3D%3D
        //  http://127.0.0.1:8080/adiii/imp?data=HlUIB8s5lhs%2FEdizbnWfe03MoLNZwbiP4RX%3fhttp://127.0.0.1:8080/adiii/dot.gif
        //  http://127.0.0.1:8080/adiii/imp?data=1%2FHlUIB8s5lhs/EdizbnWfe03MoLNZwbiP4RX?http://127.0.0.1:8080/adiii/dot.gif

        def dotUrl
        try
        {
            /*
             *  The decoded data string should be of following form:
             *  | creative id | ** other information ** | dot image url |
             */

            def data = URLDecoder.decode(params.data, 'UTF-8')
            def tokens = data.split(/\?/)
            // If the size of parsed tokens is greater than 2, do not add the impression number.
            if(tokens.size() != 2)
            {
                throw new IllegalArgumentException('Too few parameters in the request information.')
            }

            dotUrl = tokens[-1]

            // 1. verify the split data
            tokens = tokens[0].split(/\//)
            def creativeId = tokens[0]

            // 2. add the impression number of the viewed campaign and creative by one
            def creative = Creative.get(creativeId)
            creative.addToImpressions(deviceId: request.remoteHost,
                                      ipAddress: request.remoteAddr)
            creative.save(flush: true)
            Creative.withSession { session ->
                session.clear()
            }

            // TODO: The ad session cannot be viewed (impressed) again.
        }
        catch(any)
        {
            log.error(any.toString(), any)
        }
        finally
        {
            if(!dotUrl)
            {
                redirect(url: 'http://127.0.0.1:8080/adiii/dot.gif')
            }
            else
            {
                redirect(url: dotUrl)
            }
        }
    }

    def handleRedirect()
    {
        def link
        try
        {
            /*
             *  The decoded data string should be of following form:
             *  | creative id | ** other information ** | dot image url |
             */
            def data = URLDecoder.decode(params.data, 'UTF-8')

            // 1. verify the split data
            tokens = tokens[0].split(/\//)
            def creativeId = tokens[0]

            // 2. add the impression number of the viewed campaign and creative by one
            def creative = Creative.get(creativeId)
            link = creative.link
            creative.addToClicks(deviceId: request.remoteHost,
                                 ipAddress: request.remoteAddr)
            creative.save(flush: true)
            Creative.withSession { session ->
                session.clear()
            }

            // TODO: The ad session cannot be clicked again and should be invalidated.
        }
        catch(any)
        {
            log.error(any.toString(), any)
        }
        finally
        {
            redirect(url: link)
        }
    }
}
