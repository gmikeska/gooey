source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in gooey.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gem 'activesupport'
group :development, :test do
    gem "byebug"
    # There may be other lines in this block already. Simply append the following after:
    %w[rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support].each do |lib|
        gem lib, git: "https://github.com/rspec/#{lib}.git", branch: 'master' # Previously '4-0-dev' or '4-0-maintenance' branch
    end
end
group :test do
  # Might be other lines here, so simply add after them
  gem 'factory_bot_rails'
end
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]
