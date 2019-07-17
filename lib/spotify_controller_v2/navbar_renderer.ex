defmodule SpotifyControllerV2.NavbarRenderer do
  use Phoenix.HTML
  
  def renderNavBar() do
    if SpotifyControllerV2.AuthManager.is_authed? do
      renderOnAuth()
    else
      renderOnNoAuth()
    end
  end
  
  defp renderOnAuth() do
    content_tag(:ul, [
      content_tag(:li, content_tag(:a, "see queue", href: "/queue")),
      content_tag(:li, content_tag(:a, "search", href: "/search"))
    ])
  end

  defp renderOnNoAuth() do
    content_tag(:ul, "")
  end

end