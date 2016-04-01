require "spec_helper"
require "bunto"
require "bunto-github-metadata/ghp_metadata_generator"

RSpec.describe("integration into a bunto site") do
  SOURCE_DIR = Pathname.new(File.expand_path("../test-site", __FILE__))
  DEST_DIR = Pathname.new(File.expand_path("../../tmp/test-site-build", __FILE__))

  def dest_dir(*files)
    DEST_DIR.join(*files)
  end

  class ApiStub
    attr_reader :path, :file
    attr_accessor :stub

    def initialize(path, file)
      @path = path
      @file = file
    end
  end

  API_STUBS = {
    "/users/bunto/repos?per_page=100&type=public"            => "owner_repos",
    "/repos/bunto/github-metadata"                           => "repo",
    "/orgs/bunto"                                            => "org",
    "/orgs/bunto/public_members?per_page=100"                => "org_members",
    "/repos/bunto/github-metadata/pages"                     => "repo_pages",
    "/repos/bunto/github-metadata/releases?per_page=100"     => "repo_releases",
    "/repos/bunto/github-metadata/contributors?per_page=100" => "repo_contributors",
    "/repos/bunto/bunto.github.io"                          => "not_found",
    "/repos/bunto/bunto.github.com"                         => "repo",
    "/repos/bunto/bunto.github.com/pages"                   => "repo_pages",
    "/repos/bunto/bunto.github.io/pages"                    => "repo_pages"
  }.map { |path, file| ApiStub.new(path, file) }

  before(:each) do
    # Reset some stuffs
    ENV['NO_NETRC'] = "true"
    ENV['BUNTO_GITHUB_TOKEN'] = "1234abc"
    ENV['PAGES_REPO_NWO'] = "bunto/github-metadata"
    ENV['PAGES_ENV'] = "dotcom"
    Bunto::GitHubMetadata.reset!

    # Stub Requests
    API_STUBS.each { |stub| stub.stub = stub_api(stub.path, stub.file) }

    # Run Bunto
    Bunto.logger.log_level = :error
    Bunto::Commands::Build.process({
      "source" => SOURCE_DIR.to_s,
      "destination" => DEST_DIR.to_s,
      "gems" => %w{bunto-github-metadata}
    })
  end
  subject { SafeYAML::load(dest_dir("rendered.txt").read) }

  {
    "environment"          => "dotcom",
    "hostname"             => "github.com",
    "pages_env"            => "dotcom",
    "pages_hostname"       => "github.io",
    "help_url"             => "https://help.github.com",
    "api_url"              => "https://api.github.com",
    "versions"             => proc {
      begin
        require 'github-pages'
        GitHubPages.versions
      rescue LoadError
        {}
      end
    }.call,
    "public_repositories"  => Regexp.new('"id"=>17261694, "name"=>"atom-bunto"'),
    "organization_members" => Regexp.new('"login"=>"parkr", "id"=>237985'),
    "build_revision"       => /[a-f0-9]{40}/,
    "project_title"        => "github-metadata",
    "project_tagline"      => ":octocat: `site.github`",
    "owner_name"           => "bunto",
    "owner_url"            => "https://github.com/bunto",
    "owner_gravatar_url"   => "https://github.com/bunto.png",
    "repository_url"       => "https://github.com/bunto/github-metadata",
    "repository_nwo"       => "bunto/github-metadata",
    "repository_name"      => "github-metadata",
    "zip_url"              => "https://github.com/bunto/github-metadata/zipball/gh-pages",
    "tar_url"              => "https://github.com/bunto/github-metadata/tarball/gh-pages",
    "clone_url"            => "https://github.com/bunto/github-metadata.git",
    "releases_url"         => "https://github.com/bunto/github-metadata/releases",
    "issues_url"           => "https://github.com/bunto/github-metadata/issues",
    "wiki_url"             => nil, # disabled
    "language"             => "Ruby",
    "is_user_page"         => false,
    "is_project_page"      => true,
    "show_downloads"       => true,
    "url"                  => "http://bunto.github.io/github-metadata",
    "contributors"         => /"login"=>"parkr", "id"=>237985/,
    "releases"             => /"tag_name"=>"v1.1.0"/,
  }.each do |key, value|
    it "contains the correct #{key}" do
      expect(subject).to have_key(key)
      if value.is_a? Regexp
        expect(subject[key].to_s).to match value
      else
        expect(subject[key]).to eql value
      end
    end
  end

  it "calls all the stubs" do
    API_STUBS.each do |stub|
      expect(stub.stub).to have_been_requested
    end
  end

end
