defmodule Foodmap.Seeds do
  def get_helsinki_locations do
    [
      %{
        name: "Helsinki Cathedral",
        address: "Unioninkatu 29, 00170 Helsinki",
        lat: 60.1702,
        lng: 24.9522
      },
      %{
        name: "Old Market Hall",
        address: "Eteläranta, 00130 Helsinki",
        lat: 60.1666,
        lng: 24.9529
      },
      %{
        name: "Kamppi Chapel",
        address: "Simonkatu 7, 00100 Helsinki",
        lat: 60.1699,
        lng: 24.9359
      }
    ]
  end
end
