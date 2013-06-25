class UrlMappings {

	static mappings =
    {
        "/"(controller: "adiii", action: "index")

        "/api/$user_id/campaigns"(controller: "api", action: "campaigns")

        "/imp"(controller: "tracking", action: "impression")
        "/red"(controller: "tracking", action: "handleRedirect")

		"/$controller/$action?/$id?"
        {
			constraints
            {
				// apply constraints here
			}
		}

		"500"(view:'/error')
	}
}
