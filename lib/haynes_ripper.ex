defmodule HaynesRipper do
  def run(username, password) do
    session =
      "https://my.haynes.com/user?destination=cas/login"
      |> Scrappy.go_to()
      |> Scrappy.submit_form("#user-login", %{"name" => username, "pass" => password})
      |> Scrappy.go_to("https://my.haynes.com/user/subscriptions")

    manual_src = session.body |> Scrappy.find_element(".my-subscriptions a") |> Scrappy.element_attribute("href")

    session = Scrappy.go_to(session, manual_src)

    iframe_src = session.body |> Scrappy.find_element(".manual-container.reader iframe") |> Scrappy.element_attribute("src")

    session = Scrappy.go_to(session, iframe_src)

    Scrappy.save(
      session,
      fn body ->
        body
        |> String.replace("this.src = '/covers", "this.src = 'covers")
        |> Floki.attr("a[href*='manualOverview']", "href", &Scrappy.htmlize/1)
        |> Floki.raw_html()
      end
    )

    cover_url =
      session.body
      |> Scrappy.find_element("#front_cover img")
      |> Scrappy.element_attribute("src")
      |> String.replace("us-bikes", "default")

    Scrappy.save_asset(session, cover_url)

    session.body
    |> Floki.find(".menu__link")
    |> Enum.map(fn link -> Scrappy.element_attribute(link, "href") end)
    |> Enum.each(fn link_url ->
      session
      |> Scrappy.go_to(link_url)
      |> Scrappy.save(
        fn body ->
          body
          |> String.replace("this.src = '/covers", "this.src = 'covers")
          |> Floki.attr("a[href*='manualOverview']", "href", &Scrappy.htmlize/1)
          |> Floki.raw_html()
        end)
    end)
  end
end
