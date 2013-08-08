package adiii

class DemoController
{
    /*
     *  URL: /advertiser/demo/index
     *  效果呈現頁面, 讓平台功能能較簡單的做出呈現.
     */
    def index()
    {
        render(view: "index")
    }

    def device() {}

    def ad() {}
}
