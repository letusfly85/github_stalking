defmodule GithubStalking.Github.User do
  @moduledoc"""
  """
  require Logger

  alias GithubStalking.Github.Repository
    
  @client Tentacat.Client.new(%{access_token: System.get_env("access_token")})

  @derive [Poison.Encoder]
  defstruct [:login, :star_number, :repository_number, :popular_language, :starred_repositories]

  @doc"""
  """
  def find(login) do
    Tentacat.Users.find(login, @client)
  end

  @doc"""
  """
  def collect_participants_starred_urls(participants) do
    Enum.reduce(participants, %{}, fn(login, acc) ->
      Map.put(acc, login ,starred_urls(login))
    end)
  end

  @doc"""
  {
  "id":40952209
  "name":"alchemist-server"
  "full_name":"tonini/alchemist-server"
  "owner":{
    "login":"tonini"
    "id":55331
    "avatar_url":"https://avatars.githubusercontent.com/u/55331?v=3"
    "gravatar_id":""
    "url":"https://api.github.com/users/tonini"
    "html_url":"https://github.com/tonini"
    "followers_url":"https://api.github.com/users/tonini/followers"
    "following_url":"https://api.github.com/users/tonini/following{/other_user}"
    "gists_url":"https://api.github.com/users/tonini/gists{/gist_id}"
    "starred_url":"https://api.github.com/users/tonini/starred{/owner}{/repo}"
    "subscriptions_url":"https://api.github.com/users/tonini/subscriptions"
    "organizations_url":"https://api.github.com/users/tonini/orgs"
    "repos_url":"https://api.github.com/users/tonini/repos"
    "events_url":"https://api.github.com/users/tonini/events{/privacy}"
    "received_events_url":"https://api.github.com/users/tonini/received_events"
    "type":"User"
    "site_admin":false
  }
  "private":false
  "html_url":"https://github.com/tonini/alchemist-server"
  "description":"Editor/IDE independent background server to inform about Elixir mix projects"
  "fork":false
  "url":"https://api.github.com/repos/tonini/alchemist-server"
  "forks_url":"https://api.github.com/repos/tonini/alchemist-server/forks"
  "keys_url":"https://api.github.com/repos/tonini/alchemist-server/keys{/key_id}"
  "collaborators_url":"https://api.github.com/repos/tonini/alchemist-server/collaborators{/collaborator}"
  "teams_url":"https://api.github.com/repos/tonini/alchemist-server/teams"
  "hooks_url":"https://api.github.com/repos/tonini/alchemist-server/hooks"
  "issue_events_url":"https://api.github.com/repos/tonini/alchemist-server/issues/events{/number}"
  "events_url":"https://api.github.com/repos/tonini/alchemist-server/events"
  "assignees_url":"https://api.github.com/repos/tonini/alchemist-server/assignees{/user}"
  "branches_url":"https://api.github.com/repos/tonini/alchemist-server/branches{/branch}"
  "tags_url":"https://api.github.com/repos/tonini/alchemist-server/tags"
  "blobs_url":"https://api.github.com/repos/tonini/alchemist-server/git/blobs{/sha}"
  "git_tags_url":"https://api.github.com/repos/tonini/alchemist-server/git/tags{/sha}"
  "git_refs_url":"https://api.github.com/repos/tonini/alchemist-server/git/refs{/sha}"
  "trees_url":"https://api.github.com/repos/tonini/alchemist-server/git/trees{/sha}"
  "statuses_url":"https://api.github.com/repos/tonini/alchemist-server/statuses/{sha}"
  "languages_url":"https://api.github.com/repos/tonini/alchemist-server/languages"
  "stargazers_url":"https://api.github.com/repos/tonini/alchemist-server/stargazers"
  "contributors_url":"https://api.github.com/repos/tonini/alchemist-server/contributors"
  "subscribers_url":"https://api.github.com/repos/tonini/alchemist-server/subscribers"
  "subscription_url":"https://api.github.com/repos/tonini/alchemist-server/subscription"
  "commits_url":"https://api.github.com/repos/tonini/alchemist-server/commits{/sha}"
  "git_commits_url":"https://api.github.com/repos/tonini/alchemist-server/git/commits{/sha}"
  "comments_url":"https://api.github.com/repos/tonini/alchemist-server/comments{/number}"
  "issue_comment_url":"https://api.github.com/repos/tonini/alchemist-server/issues/comments{/number}"
  "contents_url":"https://api.github.com/repos/tonini/alchemist-server/contents/{+path}"
  "compare_url":"https://api.github.com/repos/tonini/alchemist-server/compare/{base}...{head}"
  "merges_url":"https://api.github.com/repos/tonini/alchemist-server/merges"
  "archive_url":"https://api.github.com/repos/tonini/alchemist-server/{archive_format}{/ref}"
  "downloads_url":"https://api.github.com/repos/tonini/alchemist-server/downloads"
  "issues_url":"https://api.github.com/repos/tonini/alchemist-server/issues{/number}"
  "pulls_url":"https://api.github.com/repos/tonini/alchemist-server/pulls{/number}"
  "milestones_url":"https://api.github.com/repos/tonini/alchemist-server/milestones{/number}"
  "notifications_url":"https://api.github.com/repos/tonini/alchemist-server/notifications{?sinceallparticipating}"
  "labels_url":"https://api.github.com/repos/tonini/alchemist-server/labels{/name}"
  "releases_url":"https://api.github.com/repos/tonini/alchemist-server/releases{/id}"
  "deployments_url":"https://api.github.com/repos/tonini/alchemist-server/deployments"
  "created_at":"2015-08-18T05:16:33Z"
  "updated_at":"2016-04-12T08:16:44Z"
  "pushed_at":"2016-03-31T07:56:54Z"
  "git_url":"git://github.com/tonini/alchemist-server.git"
  "ssh_url":"git@github.com:tonini/alchemist-server.git"
  "clone_url":"https://github.com/tonini/alchemist-server.git"
  "svn_url":"https://github.com/tonini/alchemist-server"
  "homepage":""
  "size":52
  "stargazers_count":54
  "watchers_count":54
  "language":"Elixir"
  "has_issues":true
  "has_downloads":true
  "has_wiki":true
  "has_pages":false
  "forks_count":8
  "mirror_url":null
  "open_issues_count":4
  "forks":8
  "open_issues":4
  "watchers":54
  "default_branch":"master"
  }
"""
  def starred_urls(login) do
    url = "https://api.github.com/users/" <> login <> "/starred"

    headers = []
    case HTTPoison.get(url, headers) do
      {:ok, response} ->
        start_urls = Enum.reduce(response.body |> Poison.decode!, [], fn(json, acc) ->
          repo = %Repository{
            id:               json["id"],
            owner:            json["owner"]["login"],
            full_name:        json["full_name"],
            html_url:         json["html_url"],
            description:      json["description"],
            language:         json["language"],
            stargazers_count: json["stargazers_count"],
            created_at:       json["created_at"],
            updated_at:       json["updated_at"],
            pushed_at:        json["pushed_at"]
          }
          [repo|acc]
        end)
        Enum.sort(start_urls, fn(repo1, repo2) -> repo1.updated_at < repo2.updated_at end)

      {:error, error} ->
        Logger.error(error)
        []
    end
  end

  def summary_repos_by_language(repos) do
    Enum.reduce(repos, %{}, fn(repo, acc) ->
      case acc[repo.language] do
        nil -> Map.put(acc, repo.language, [repo.full_name])
        ary -> Map.put(acc, repo.language, [repo.full_name|ary])
      end
    end)
  end

  def sort_repos_by_star_counts(repos) do
      Enum.sort(repos, fn(repo1, repo2) -> repo1.stargazers_count > repo2.stargazers_count end)
  end
end
