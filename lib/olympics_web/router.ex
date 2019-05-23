defmodule OlympicsWeb.Router do
  use OlympicsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OlympicsWeb do
    pipe_through :api

    get "/", ResultsController, :index

    get "/:year/", ResultsController, :get_by_year
    get "/:year/:country", ResultsController, :get_by_country
  end
end
