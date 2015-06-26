LKP_SRC ||= ENV['LKP_SRC']

require "#{LKP_SRC}/lib/common.rb"
require "#{LKP_SRC}/lib/lkp_git"
require "#{LKP_SRC}/lib/git-tag.rb"
git_update_rb = "#{LKP_SRC}/lib/git-update.rb"
require git_update_rb if File.exists? git_update_rb

class Commit
	def initialize(commit)
		@commit = commit
	end

	def to_s
		@commit
	end

	def parents
		@parents ||= git_parent_commits(@commit).map { |cstr| Commit.open cstr }
	end

	def committer_date
		@committer_date ||= git_commit_time @commit
	end

	def author
		@author ||= git_commit_author @commit
	end

	def subject
		@subject ||= git_commit_subject @commit
	end

	def base_tag
		@base_tag ||= Commit.tag_finder.last_release_tag(@commit)
	end
end

class << Commit
	include SimpleCacheMethod

	def open(commit, branch = nil)
		git_update branch if branch
		lcommit = git_commit commit
		unless is_commit lcommit
			raise ArgumentError, "Invalid commit: #{commit}"
		end

		self.new(lcommit)
	end

	cache_method :open

	def open_branch(branch)
		git_update branch
		commit = git_commit branch
		unless is_commit commit
			raise ArgumentError, "Invalid branch: #{branch}"
		end

		self.new(commit)
	end

	def tag_finder
		@tag_finder ||= GitTag.new(remote:"default")
	end
end
