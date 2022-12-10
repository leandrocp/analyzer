# Analyzer

Data Quality for Elixir. Ensuring your data meets expectations, it's  like unit-testing but for data.

Common use cases include, but not limited to:

  - Establishing a contract for consumed APIs.
  - Validating the structure and content of CSV files.
  - Ensuring data quality in a ETL or ELT pipeline.

**NOTE** this is very early stage, most features are not implemented yet.

## Features

* [Profiling](#profiling) - evaluate a set of data returning a summary of its structure and content to help you understand the shape of the data and identify potential expectations and failures.

* [Testing](#testing) - apply a set of expectations to test your data is conforming to a contract.

* [Reports](#reports) - expose the result of expectations visually.

* [Anomaly Detection](#anomaly-detection) - compare past and current expectation results to identify outliers and potential risks.

* [Normalization](#normalization) - transform a complex data structure into tabular format.

## Usage

Install or add to your project dependencies:

```elixir
Mix.install([{:analyzer, git: "git@github.com:leandrocp/analyzer.git"}])
```

Let's learn by example. Given a list of customers from an external source that you should validate, transform, and ingest:

```elixir
customers = [
  %{id: 1, name: "José", email: "jose@gmail.com", email_mkt: true},
  %{id: 2, name: "Julius", email: "julius@", email_mkt: false},
  %{id: 3, name: "Lara", email: "lara@personal.io", email_mkt: false},
  %{id: 4, name: "Arnold", email: "arnold@gmail.com", email_mkt: false}
]
```

### Profiling

Very often that data is either unknown or too big to grasp in a first look, the first step is to profile it to extract valuable statistics:

```elixir
Analyzer.profile(customer)
#=> TODO
```

### Testing

Now that you know a bit more about that data, it's time to validate it in order to make sure your data pipeline won't break or you won't ingest invalid data into your system. Think about it as unit-testing your data.

Let's suppose we need to make sure the following expectations are valid:

   - ID is unique
   - Email is valid
   - Email Marketing Opt-in is true for at least 50% records

And that's how we can enforce them:

```elixir
Analyzer.Expectation.new(
  backend: Analyzer.Backend.List,
  data: customers
)
|> Analyzer.expect_column_values_to_be_unique(column: :id)
|> Analyzer.expect_column_values_to_contain_valid_email(column: :email)
|> Analyzer.expect_column_values_to_be(column: :email_mkt, value: true, at_least: 0.5)
|> Analyzer.Expectation.run()
#=> 
# %Analyzer.Result{
#   status: :invalid,
#   expectations: [
#     {:expect_column_values_to_be_unique, [column: :id], :ok},
#     {:expect_column_values_to_contain_valid_email, [column: :email], {:error, %{observed_values: ["julius@"]}},
#     {:expect_column_values_to_be, [column: :email_mkt, value: true, at_least: 0.5], {:error, %{observed_values: [false], invalid_records: 3, invalid_records_pct: 0.75}}
#   ]
# }
```

For each expectation, it does return the expectation name, args, and result with metadata. One can inspect why and where the data is falling, and in this case the result is marked as invalid for not passing all expectations.

To make it more clear or aligned to a business need, it's possible to rename expectations or provide a hint, both optional:

```elixir
Analyzer.Expectation.new(
  backend: Analyzer.Backend.List,
  data: customers
)
|> Analyzer.expect_column_values_to_be(
  column: :email_mkt,
  value: true,
  at_least: 0.5,
  as: :expect_email_marketing_min_opt_in,
  hint: "Expected to have at least 50% of customers opt in to email marketing."
)
|> Analyzer.Expectation.run()
#=>
# %Analyzer.Result{
#   status: :invalid,
#   expectations: [
#     {
#       :expect_email_marketing_min_opt_in,
#       [column: :email_mkt, value: true, at_least: 0.5, hint: "Expected to have at least 50% of customers opt in to email marketing."],
#       {:error, %{observed_values: [false], invalid_records: 3, invalid_records_pct: 0.75}
#     }
#   ]
# }
```

#### Backends

Analyzer is capable of handling multiple data source as regular Elixir Lists (as seen above), [Explorer.DataFrame](https://hexdocs.pm/explorer/Explorer.DataFrame.html), and [Ecto.Query](https://hexdocs.pm/ecto/Ecto.Query.html), just by passing the proper `:backend` or you can implement your own backend:

**DataFrame**

```elixir
data = Explorer.DataFrame.new([%{a: 1}, %{a: 2}])

Analyzer.Expectation.new(
  backend: Analyzer.Backend.Explorer,
  data: data
)
|> Analyzer.Expectation.expect_table_row_count_to_equal(count: 2)
|> Analyzer.Expectation.run()
#=>
# %Analyzer.Result{
#   status: :valid,
#   expectations: [
#     {:expect_table_row_count_to_equal, [count: 2], {:ok, %{observed_value: 2}}}
#   ]
# }
```

### Reports

Given a `%Analyzer.Result{}` struct, it can be used to generate a report:

```elixir
# expectations...
|> Analyzer.Expectation.run()
|> Analyzer.report()
```

TODO

### Anomaly Detection

By comparing two or more results it's possible to detect anomalies in the data over time:

```elixir
Analyzer.anomaly_check([result_1, result_2, result_3])
```

TODO

### Normalization

Last but not least, normalization is the process of flattening and linking related data, in other words transforming a complex data structure into a tabular format:

```elixir
Analyzer.normalize(
  %{
    first_name: "José",
    projects: [%{name: "elixir"}, %{name: "livebook"}]
  },
  %{
    first_name: "John",
    projects: []
  },
  as: "users"
)
#=>
# %{
#   "users" => [
#     %{
#       "__analyzer_id" => "Fy7u4w64m9W6YUdi",
#       "__analyzer_normalized_at" => "2022-12-08T21:32:50.772899Z",
#       "first_name" => "José"
#     },
#     %{
#       "__analyzer_id" => "Fy7u4w64m9W9TIdy",
#       "__analyzer_normalized_at" => "2022-12-08T21:32:50.772899Z",
#       "first_name" => "John"
#     },
#   ],
#   "projects" => [
#     %{
#       "__analyzer_id" => "Fy7u4w7MKoKBNkeC",
#       "__analyzer_normalized_at" => "2022-12-08T21:32:50.774179Z",
#       "__analyzer_users_id" => "Fy7u4w64m9W6YUdi",
#       "name" => "elixir"
#     },
#     %{
#       "__analyzer_id" => "Fy7u4w7MPOZHPEei",
#       "__analyzer_normalized_at" => 2022-12-08T21:32:50.774183Z",
#       "__analyzer_users_id" => "Fy7u4w64m9W6YUdi",
#       "name" => "livebook"
#     }
#   ]
# }
```

Check out `Analyzer.normalize/2` for more options to customize it.

With that data transformed into a tabular format, you can ingest it into a data frame:

```elixir
result = Analyzer.normalize(...)
Explorer.DataFrame.new(result["users"])
#=>
# #Explorer.DataFrame<
#   Polars[2 x 3]
#   __analyzer_id string ["Fy7u4w64m9W6YUdi", "Fy7u4w64m9W9TIdy"]
#   __analyzer_normalized_at string ["2022-12-08T21:32:50.772899Z", "2022-12-08T21:32:50.772899Z"]
#   first_name string ["José", "John"]
# >
```

## Acknowledgments

Analyzer is inspired by [changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html), [explorer](https://github.com/elixir-nx/explorer), [great_expectations](https://github.com/great-expectations/great_expectations), and [deequ](https://github.com/awslabs/deequ).
