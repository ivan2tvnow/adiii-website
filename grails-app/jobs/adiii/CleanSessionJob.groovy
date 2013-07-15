package adiii



class CleanSessionJob {
    static triggers = {
        simple startDelay: 60000, repeatInterval: 600000 // execute job once in 600 seconds
    }

    def execute() {
        // execute job
        Date now = new Date()
        def querry = SessionData.where {
            expireTime < now
        }

        def sessionDatas = querry.list()
        for (sessionData in sessionDatas) {
            sessionData.campaign = null
            sessionData.creative = null
            sessionData.delete()
        }
    }
}
