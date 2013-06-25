package adiii

class AdiiiController
{

    def index()
    {
//        if(session.user == null)
//        {
//            render(view: "index")
//        }
//         else
//        {
            redirect(controller: "advertiser", action: "index")
//        }
    }
}
