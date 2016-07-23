defmodule Gherkin do
  @rule_type [
    :None,
    :_EOF,
    :_Empty,
    :_Comment,
    :_TagLine,
    :_FeatureLine,
    :_BackgroundLine,
    :_ScenarioLine,
    :_ScenarioOutlineLine,
    :_ExamplesLine,
    :_StepLine,
    :_DocStringSeparator,
    :_TableRow,
    :_Language,
    :_Other,
    :GherkinDocument,
    :Feature,
    :Feature_Header,
    :Background,
    :Scenario_Definition,
    :Scenario,
    :ScenarioOutline,
    :Examples_Definition,
    :Examples,
    :Examples_Table,
    :Scenario_Step,
    :ScenarioOutline_Step,
    :Step,
    :Step_Arg,
    :DataTable,
    :DocString,
    :Tags,
    :Feature_Description,
    :Background_Description,
    :Scenario_Description,
    :ScenarioOutline_Description,
    :Examples_Description,
    :Description_Helper,
    :Description
  ]

  defmodule Parser do 
  end
end