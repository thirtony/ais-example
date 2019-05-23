defmodule OlympicsWeb.ResultsController do
    use OlympicsWeb, :controller

    NimbleCSV.define(CSVParser, separator: ",", escape: "\"")

    def get_all_results() do
        "./1896_2008-AllMedals.csv"
        |> File.stream!(read_ahead: 10_000)
        |> CSVParser.parse_stream
        |> Enum.map(fn([city, edition, _sport, _discipline, athlete, noc, _gender, _event, _event_gender, medal]) ->
          %{host: city, year: edition, medal: medal, country: noc, athlete: athlete}
        end)
    end

    def organise_results_by_year(results) do
        results
        |> Enum.reduce(%{}, fn(result, acc) ->
            if Map.has_key?(acc, result.year) do
                Map.put(acc, result.year, acc[result.year] ++ [result])
            else
                Map.put_new(acc, result.year, [result])
            end
        end)
    end

    def filter_results_to_year(results, year) do
        results_by_year = organise_results_by_year(results)

        cond do
            Map.has_key?(results_by_year, year) ->
                results_by_year[year]
            true ->
                []
        end
    end

    def index(conn, _params) do
      results = get_all_results()
      conn
        |> put_resp_content_type("application/json; charset=utf-8")
        |> send_resp(200, Jason.encode!(results))
    end

    def get_for_year(conn, %{"year" => year}) do
        results_for_year = filter_results_to_year(get_all_results(), year)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200,  Jason.encode!(results_for_year))
    end

    def get_for_year_with_country(conn,  %{"year" => year, "country" => country}) do
        results = Enum.filter(get_all_results(), fn(result) -> result.country == country end)
        filtered_results_for_year = filter_results_to_year(results, year)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200,  Jason.encode!(filtered_results_for_year))
    end
end
