defmodule Webapp.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, Webapp.Page.render(conn))
  end

  get "/contacto" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, Webapp.Contact.render())
  end

  match _ do
    send_resp(conn, 404, "Página no encontrada")
  end
end
