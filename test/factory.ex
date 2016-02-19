defmodule Factory do
  use FactoryGirlElixir.Factory

  factory :issue do
    field :number, 99
    field :number, fn(n) ->
      "number#{n}"
    end

    field :title , "test issue"
    field :title, fn(t) ->
      "title#{t}"
    end
  end
end
