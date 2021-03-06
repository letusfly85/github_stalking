defmodule GithubStalking.IssueTest do
  use ExUnit.Case
  alias GithubStalking.Github.Issue

  setup_all do
    prob_issues = Riak.Bucket.keys("issue_history")
    case prob_issues do
      {:ok, issues} ->
        Enum.each(issues, fn(issue) ->
          if Regex.match?(~r/awesome-elixir/, issue) == false do
            Riak.delete("issue_history", issue)
          end
        end)
    end
  end

  test "issue 3 should be updated after 2016-02-13T01:05:18Z" do
    issue_number = 3
    pre_issue = %Issue{owner: "letusfly85", repo: "github_stalking_test", 
                                             number: issue_number, updated_at: "2016-03-03T01:05:18Z"}
    pre_issues = %{issue_number => pre_issue} 
    
    response = Issue.updated_open_issues("letusfly85", "github_stalking_test", pre_issues)
    case response do
      {:ok, issues} -> 
        assert length(Enum.sort(issues)) == 4
        assert hd(Enum.sort(issues)).title == "test issue 1"
      {:error, _}   -> raise("connection to Github is refused!!!")
    end

  end

  test "issue 2 should be updated after 2016-02-13T01:05:18Z" do
    pre_issue = %Issue{number: 2}
    pre_issues = %{2 => pre_issue} 

    response = Issue.closed_issues("letusfly85", "github_stalking_test", pre_issues)
    case response do
      {:ok, issues} -> 
        assert length(issues) >= 1
        assert hd(issues)["title"] == "test issue 2"
      {:error, _}   -> raise("connection to Github is refused!!!")
    end

  end

  test "issue 5 should be updated after 2016-02-13T01:05:18Z" do
    issue_number = 5
    pre_issue = %Issue{owner: "letusfly85", repo: "github_stalking_test", 
                                             number: issue_number, updated_at: "2016-03-29T01:05:18Z"}
    pre_issues = %{issue_number => pre_issue} 

    response = Issue.updated_open_issues("letusfly85", "github_stalking_test", pre_issues)
    case response do
      {:ok, issues} -> 
        assert length(issues) >= 1
        prob_issue = Enum.filter(issues, fn(issue) -> issue.number == 5 end)
        assert hd(prob_issue).title == "test"
        assert hd(prob_issue).comments.participant_count == 0

      {:error, _}   -> raise("connection to Github is refused!!!")
    end

  end

  test "should collect one item from a repository" do
    assert 1 == 1
  end

  test "issue 4 should be updated after 2016-02-13T01:05:18Z" do
    issue_number = 4
    pre_issue = %Issue{owner: "letusfly85", repo: "github_stalking_test", 
                                             number: issue_number, updated_at: "2016-03-29T01:05:18Z"}
    pre_issues = %{issue_number => pre_issue} 

    response = Issue.updated_open_issues("letusfly85", "github_stalking_test", pre_issues)
    case response do
      {:ok, issues} -> 
        assert length(issues) >= 1
        prob_issue = Enum.filter(issues, fn(issue) -> issue.number == 4 end)
        assert hd(prob_issue).title == "test issue 4"
        assert hd(prob_issue).comments.participant_count == 1
        assert hd(prob_issue).comments.comment_count     == 4

      {:error, _}   -> raise("connection to Github is refused!!!")
    end
  end

end
