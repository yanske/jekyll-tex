build: ## Compile jekyll-tex gem
	gem build jekyll-tex.gemspec 

test: ## Run specs
	bundle exec rspec

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##";printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
