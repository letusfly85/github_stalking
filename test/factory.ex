defmodule Factory do
  use FactoryGirlElixir.Factory

  factory :issue do
    field :number, 99
    field :number, fn(n) ->
      "number#{n}"
    end

    field :updated_at, "2016-02-13T01:05:18Z"
    field :updated_at, fn(ua) ->
      "updated_at#{ua}"
    end

    field :title , "test issue"
    field :title, fn(t) ->
      "title#{t}"
    end
  end
end
