defmodule Gherkin.Parser do
  def parse(nil, _url) do
    empty_tokens = Gherkin.TokenScanner.get_raw_tokens([], 1)
    context      = %Gherkin.ParserContext{queue: empty_tokens, stack: [%Gherkin.AstNode{}], comments: []}

    {next_state, new_context} = build_ast({0, List.first(context.queue) |> Gherkin.TokenMatcher.match_token(context), context})
    {next_state_2, new_context_2} = build_ast({next_state, List.first(new_context.queue) |> Gherkin.TokenMatcher.match_token(new_context), new_context})
    new_context_2.stack
  end

  def parse(input, _url) do
    # Process the input into tokens
    token_queue = String.split(input, ~r/\n/) 
                    |> Gherkin.TokenScanner.get_raw_tokens(1)

    context     = %Gherkin.ParserContext{queue: token_queue, stack: [%Gherkin.AstNode{}], comments: []}

    {next_state, new_context} = build_ast({0, List.first(context.queue) |> Gherkin.TokenMatcher.match_token(context), context})

    {next_state_2, new_context_2} = build_ast({next_state, List.first(new_context.queue) |> Gherkin.TokenMatcher.match_token(new_context), new_context})

    {next_state_3, new_context_3} = build_ast({next_state_2, List.first(new_context_2.queue) |> Gherkin.TokenMatcher.match_token(new_context_2), new_context_2})

    new_context_3.stack
  end

  def build_ast({0, token = %{matched_type: :EOF}, context}) do
    {27, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({0, token = %{matched_type: :Language}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Feature) 
                  |> Gherkin.AstBuilder.start_rule(:FeatureHeader)
                  |> Gherkin.AstBuilder.build(token)

    {1, new_context}
  end

  def build_ast({0, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Feature)
                  |> Gherkin.AstBuilder.start_rule(:FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {2, new_context}
  end

  def build_ast({0, token = %{matched_type: :FeatureLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Feature)
                  |> Gherkin.AstBuilder.start_rule(:FeatureHeader)
                  |> Gherkin.AstBuilder.build(token)

    {3, new_context}
  end

  def build_ast({0, token = %{matched_type: :Comment}, context}) do
    {0, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({0, token = %{matched_type: :Empty}, context}) do
    {0, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({0, _token, context}) do
    {0, context}
  end

  def build_ast({1, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Tags)
                  |> Gherkin.AstBuilder.build(token)

    {2, new_context}
  end

  def build_ast({1, token = %{matched_type: :FeatureLine}, context}) do
    {3, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({1, token = %{matched_type: :Comment}, context}) do
    {1, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({1, token = %{matched_type: :Empty}, context}) do
    {1, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({1, _token, context}) do
    {1, context}
  end

  def build_ast({2, token = %{matched_type: :TagLine}, context}) do
    {2, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({2, token = %{matched_type: :FeatureLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Tags)
                  |> Gherkin.AstBuilder.build(token)

    {3, new_context}
  end

  def build_ast({2, token = %{matched_type: :Comment}, context}) do
    {2, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({2, token = %{matched_type: :Empty}, context}) do
    {2, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({3, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :FeatureHeader)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({3, token = %{matched_type: :Empty}, context}) do
    {3, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({3, token = %{matched_type: :Comment}, context}) do
    {5, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({3, token = %{matched_type: :BackgroundLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:Background)
                  |> Gherkin.AstBuilder.build(token)

    {6, new_context}
  end

  def build_ast({3, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({3, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({3, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({3, token = %{matched_type: :Other}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Description)
                  |> Gherkin.AstBuilder.build(token)

    {4, new_context}
  end

  def build_ast({4, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:FeatureHeader)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({4, token = %{matched_type: :Comment}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.build(token)

    {5, new_context}
  end

  def build_ast({4, token = %{matched_type: :BackgroundLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:Background)
                  |> Gherkin.AstBuilder.build(token)

    {6, new_context}
  end

  def build_ast({4, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({4, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({4, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({4, token = %{matched_type: :Other}, context}) do
    {4, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({5, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :FeatureHeader)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({5, token = %{matched_type: :Comment}, context}) do
    {5, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({5, token = %{matched_type: :BackgroundLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:Background)
                  |> Gherkin.AstBuilder.build(token)

    {6, new_context}
  end

  def build_ast({5, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({5, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({5, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :FeatureHeader)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({5, token = %{matched_type: :Empty}, context}) do
    {5, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({6, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Background)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({6, token = %{matched_type: :Empty}, context}) do
    {6, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({6, token = %{matched_type: :Comment}, context}) do
    {8, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({6, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Step)
                  |> Gherkin.AstBuilder.build(token)

    {9, new_context}
  end

  def build_ast({6, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({6, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({6, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({6, token = %{matched_type: :Other}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Description)
                  |> Gherkin.AstBuilder.build(token)

    {7, new_context}
  end

  def build_ast({7, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({7, token = %{matched_type: :Comment}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.build(token)

    {8, new_context}
  end

  def build_ast({7, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {9, new_context}
  end

  def build_ast({7, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({7, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({7, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({7, token = %{matched_type: :Other}, context}) do
    {7, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({8, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Background)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({8, token = %{matched_type: :Comment}, context}) do
    {8, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({8, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Step)
                  |> Gherkin.AstBuilder.build(token)

    {9, new_context}
  end

  def build_ast({8, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({8, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({8, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({8, token = %{matched_type: :Empty}, context}) do
    {8, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({9, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({9, token = %{matched_type: :TableRow}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.build(token)

    {10, new_context}
  end

  def build_ast({9, token = %{matched_type: :DocStringSeparator}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :DocString)
                  |> Gherkin.AstBuilder.build(token)

    {32, new_context}
  end

  def build_ast({9, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {9, new_context}
  end

  def build_ast({9, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({9, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({9, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({9, token = %{matched_type: :Comment}, context}) do
    {9, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({9, token = %{matched_type: :Empty}, context}) do
    {9, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({10, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({10, token = %{matched_type: :TableRow}, context}) do
    {10, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({10, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {9, new_context}
  end

  def build_ast({10, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({10, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({10, token = %{matched_type: :Comment}, context}) do
    {10, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({10, token = %{matched_type: :Empty}, context}) do
    {10, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({11, token = %{matched_type: :TagLine}, context}) do
    {11, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({11, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Tags)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({11, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Tags)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({11, token = %{matched_type: :Comment}, context}) do
    {11, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({11, token = %{matched_type: :Empty}, context}) do
    {11, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({12, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({12, token = %{matched_type: :Empty}, context}) do
    {12, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({12, token = %{matched_type: :Comment}, context}) do
    {14, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({12, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Step)
                  |> Gherkin.AstBuilder.build(token)

    {15, new_context}
  end

  def build_ast({12, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({12, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({12, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({12, token = %{matched_type: :Other}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Description)
                  |> Gherkin.AstBuilder.build(token)

    {13, new_context}
  end

  def build_ast({13, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefintion)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({13, token = %{matched_type: :Comment}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.build(token)

    {14, new_context}
  end

  def build_ast({13, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {15, new_context}
  end

  def build_ast({13, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({13, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({13, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({13, token = %{matched_type: :Other}, context}) do
    {13, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({14, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({14, token = %{matched_type: :Comment}, context}) do
    {14, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({14, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Step)
                  |> Gherkin.AstBuilder.build(token)

    {15, new_context}
  end

  def build_ast({14, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({14, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({14, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({14, token = %{matched_type: :Empty}, context}) do
    {14, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({15, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({15, token = %{matched_type: :TableRow}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.build(token)

    {16, new_context}
  end

  def build_ast({15, token = %{matched_type: :DocStringSeparator}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :DocString)
                  |> Gherkin.AstBuilder.build(token)

    {30, new_context}
  end

  def build_ast({15, token = %{matched_type: :Step}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {15, new_context}
  end

  def build_ast({15, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({15, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({15, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({15, token = %{matched_type: :Comment}, context}) do
    {15, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({15, token = %{matched_type: :Empty}, context}) do
    {15, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({16, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({16, token = %{matched_type: :TableRow}, context}) do
    {16, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({16, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {15, new_context}
  end

  def build_ast({16, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({16, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({16, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({16, token = %{matched_type: :Comment}, context}) do
    {16, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({16, token = %{matched_type: :Empty}, context}) do
    {16, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({17, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({17, token = %{matched_type: :Empty}, context}) do
    {17, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({17, token = %{matched_type: :Comment}, context}) do
    {18, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({17, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Step)
                  |> Gherkin.AstBuilder.build(token)

    {20, new_context}
  end

  def build_ast({17, _token = %{matched_type: :TagLine}, _context}) do
    # TODO: Lookahead
  end

  def build_ast({17, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({17, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({17, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({17, token = %{matched_type: :Other}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Description)
                  |> Gherkin.AstBuilder.build(token)

    {18, new_context}
  end

  def build_ast({18, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({18, token = %{matched_type: :Comment}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.build(token)

    {19, new_context}
  end

  def build_ast({18, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {20, new_context}
  end

  def build_ast({18, _token = %{matched_type: :TagLine}, _context}) do
    # TODO: Lookahead
  end

  def build_ast({18, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.start_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({18, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({18, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({18, token = %{matched_type: :Other}, context}) do
    {18, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({19, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({19, token = %{matched_type: :Comment}, context}) do
    {19, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({19, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Step)
                  |> Gherkin.AstBuilder.build(token)

    {20, new_context}
  end

  def build_ast({19, _token = %{matched_type: :TagLine}, _context}) do
    # TODO: Lookahead
  end

  def build_ast({19, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({19, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({19, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({19, token = %{matched_type: :Empty}, context}) do
    {19, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({20, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({20, token = %{matched_type: :TableRow}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.build(token)

    {21, new_context}
  end

  def build_ast({20, token = %{matched_type: :DocStringSeparator}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :DocString)
                  |> Gherkin.AstBuilder.build(token)

    {28, new_context}
  end

  def build_ast({20, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {20, new_context}
  end

  def build_ast({20, token = %{matched_type: :TagLine}, context}) do
    # TODO: Lookahead
  end

  def build_ast({20, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.start_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({20, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({20, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Step)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({20, token = %{matched_type: :Comment}, context}) do
    {20, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({20, token = %{matched_type: :Empty}, context}) do
    {20, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({21, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({21, token = %{matched_type: :TableRow}, context}) do
    {21, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({21, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {20, new_context}
  end

  def build_ast({21, _token = %{matched_type: :TagLine}, _context}) do
    # TODO: Lookahead
  end

  def build_ast({21, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.start_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({21, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({21, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DataTable)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({21, token = %{matched_type: :Comment}, context}) do
    {21, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({21, token = %{matched_type: :Empty}, context}) do
    {21, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({22, token = %{matched_type: :TagLine}, context}) do
    {22, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({22, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Tags)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({22, token = %{matched_type: :Comment}, context}) do
    {22, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({22, token = %{matched_type: :Empty}, context}) do
    {22, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({23, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({23, token = %{matched_type: :Empty}, context}) do
    {23, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({23, token = %{matched_type: :Comment}, context}) do
    {25, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({23, token = %{matched_type: :TableRow}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :ExamplesTable)
                  |> Gherkin.AstBuilder.build(token)

    {26, new_context}
  end

  def build_ast({23, token = %{matched_type: :TagLine}, context}) do
    # TODO: Lookahead
  end

  def build_ast({23, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({23, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({23, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({23, token = %{matched_type: :Other}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :Description)
                  |> Gherkin.AstBuilder.build(token)

    {24, new_context}
  end

  def build_ast({24, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({24, token = %{matched_type: :Comment}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.build(token)

    {25, new_context}
  end

  def build_ast({24, token = %{matched_type: :TableRow}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.start_rule(:ExamplesTable)
                  |> Gherkin.AstBuilder.build(token)

    {26, new_context}
  end

  def build_ast({24, token = %{matched_type: :TagLine}, context}) do
    # TODO: Lookahead
  end

  def build_ast({24, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({24, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({24, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Description)
                  |> Gherkin.AstBuilder.end_rule(:Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({24, token = %{matched_type: :Other}, context}) do
    {24, new_context = Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({24, token = %{matched_type: :Other}, context}) do
    {24, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({25, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({25, token = %{matched_type: :Comment}, context}) do
    {25, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({25, token = %{matched_type: :TableRow}, context}) do
    new_context = Gherkin.AstBuilder.start_rule(context, :ExamplesTable)
                  |> Gherkin.AstBuilder.build(token)

    {26, new_context}
  end

  def build_ast({25, token = %{matched_type: :TagLine}, context}) do
    # TODO: Lookahead
  end

  def build_ast({25, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({25, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({25, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({25, token = %{matched_type: :Empty}, context}) do
    {25, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({26, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :ExamplesTable)
                  |> Gherkin.AstBuilder.end_rule(:Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({26, token = %{matched_type: :TableRow}, context}) do
    {26, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({26, token = %{matched_type: :TagLine}, context}) do
    # TODO: Lookahead
  end

  def build_ast({26, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :ExamplesTable)
                  |> Gherkin.AstBuilder.end_rule(:Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({26, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :ExamplesTable)
                  |> Gherkin.AstBuilder.end_rule(:Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({26, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :ExamplesTable)
                  |> Gherkin.AstBuilder.end_rule(:Examples)
                  |> Gherkin.AstBuilder.end_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({26, token = %{matched_type: :Comment}, context}) do
    {26, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({26, token = %{matched_type: :Empty}, context}) do
    {26, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({28, token = %{matched_type: :DocStringSeparator}, context}) do
    {29, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({28, token = %{matched_type: :Other}, context}) do
    {28, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({29, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({29, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {20, new_context}
  end

  def build_ast({29, token = %{matched_type: :TagLine}, context}) do
    # TODO: Lookahead
  end

  def build_ast({29, token = %{matched_type: :ExamplesLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.start_rule(:ExamplesDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Examples)
                  |> Gherkin.AstBuilder.build(token)

    {23, new_context}
  end

  def build_ast({29, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({29, token = %{matched_type: :ScenarioOutineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutine)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({29, token = %{matched_type: :Comment}, context}) do
    {29, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({29, token = %{matched_type: :Empty}, context}) do
    {29, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({30, token = %{matched_type: :DocStringSeparator}, context}) do
    {31, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({30, token = %{matched_type: :Other}, context}) do
    {30, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({31, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({31, token = %{matched_type: :Step}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {15, new_context}
  end

  def build_ast({31, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({31, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({31, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Scenario)
                  |> Gherkin.AstBuilder.end_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({31, token = %{matched_type: :Comment}, context}) do
    {31, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({31, token = %{matched_type: :Empty}, context}) do
    {31, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({32, token = %{matched_type: :DocStringSeparator}, context}) do
    {33, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({32, token = %{matched_type: :Other}, context}) do
    {32, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({33, token = %{matched_type: :EOF}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.end_rule(:Feature)
                  |> Gherkin.AstBuilder.build(token)

    {27, new_context}
  end

  def build_ast({33, token = %{matched_type: :StepLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.start_rule(:Step)
                  |> Gherkin.AstBuilder.build(token)

    {9, new_context}
  end

  def build_ast({33, token = %{matched_type: :TagLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Tags)
                  |> Gherkin.AstBuilder.build(token)

    {11, new_context}
  end

  def build_ast({33, token = %{matched_type: :ScenarioLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:Scenario)
                  |> Gherkin.AstBuilder.build(token)

    {12, new_context}
  end

  def build_ast({33, token = %{matched_type: :ScenarioOutlineLine}, context}) do
    new_context = Gherkin.AstBuilder.end_rule(context, :DocString)
                  |> Gherkin.AstBuilder.end_rule(:Step)
                  |> Gherkin.AstBuilder.end_rule(:Background)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioDefinition)
                  |> Gherkin.AstBuilder.start_rule(:ScenarioOutline)
                  |> Gherkin.AstBuilder.build(token)

    {17, new_context}
  end

  def build_ast({33, token = %{matched_type: :Comment}, context}) do
    {33, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({33, token = %{matched_type: :Empty}, context}) do
    {33, Gherkin.AstBuilder.build(context, token)}
  end

  def build_ast({_state, token, context}) do
    {27, Gherkin.AstBuilder.build(context, token)}
  end
end