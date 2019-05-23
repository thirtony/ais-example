# Olympics
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Learn more (Getting started/Setup Install/Etc)

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix


## Attribution
This project relies on a CSV file from The Guardian for its results:
https://www.theguardian.com/sport/datablog/2012/jun/25/olympic-medal-winner-list-data


## JSON API Server
This is really a very simple JSON server that allows the following queries:

  * __/__ : returns the raw data as parsed from the CSV in JSON format
  * __/:year__ : where year is in the format yyyy (e.g. 2000). Note for results it should be an Olympic Year and be between 1896 and 2008. 
  * __/:year/:country__ : where year follows the rules above and country is a 3 letter NOC/IOC code for a country (e.g. USA)


## Noteable files
The main code file worth looking at for this project is lib/olympics_web/controllers/results_controller.ex

It has been kept simple and tries to limit its use of some elixir specific functions like the |> operator to make it easier to read without substantial elixir experience.

This file loads and processes the CSV file for each request. It isn't designed to be optimised, simply a demonstration of collecting the data required for each query. It maps a limited subset of the data required for future queries and renames some during processing. Below shows the mapping between the json structure and the original csv fields:

```
%{host: city, year: edition, medal: medal, country: noc, athlete: athlete}
```

The following code was added to process the CSV results (one line per medal) into a structure organised around year. It was designed to take a list of results to allow composition of filtering prior to reorganisation.
```
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
```

A good example of this is the results for a country in a particular year, which first filters the csv data using built in Enum methods before organising the data.

```
results = Enum.filter(get_all_results(), fn(result) -> result.country == country end)
filtered_results_for_year = filter_results_to_year(results, year)
```

 This methodology could be extended to the YEAR filter too, reducing the data size before reorganisation.

