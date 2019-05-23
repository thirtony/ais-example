defmodule OlympicsWeb.Router do
  use OlympicsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OlympicsWeb do
    pipe_through :api

    get "/", ResultsController, :index

    get "/:year/", ResultsController, :get_for_year
    get "/:year/:country", ResultsController, :get_for_year_with_country
  end
end
