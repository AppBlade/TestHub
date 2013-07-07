class RepositoriesController < ApplicationController

  def new
    access_token = current_user_session.access_token.to_oauth2(GithubClient)
    repository_request = access_token.get 'https://api.github.com/user/repos', params: {per_page: 500, sort: 'updated'}
    @repositories = MultiJson.load(repository_request.response.body).map do |repository|
      repository.select {|k| %w(id name full_name description language).include? k }
    end
  end

  def create
    params[:repository_full_names].each do |repository_full_name|
      access_token = current_user_session.access_token.to_oauth2(GithubClient)
      repository_request = access_token.get "https://api.github.com/repos/#{repository_full_name}"
      parsed_repository = MultiJson.load(repository_request.response.body)
      owner = User.where(github_id: parsed_repository['owner']['id']).first_or_create
      owner.update_attributes github_login: parsed_repository['owner']['login'],
                              avatar_url:   parsed_repository['owner']['avatar_url']
      repository = Repository.where(github_id: parsed_repository['id']).first_or_create
      repository.update_attributes name:        parsed_repository['name'],
                                   full_name:   parsed_repository['full_name'],
                                   description: parsed_repository['description'],
                                   github_etag: repository_request.response['ETag'],
                                   owner:       owner
      collaborators_request = access_token.get "https://api.github.com/repos/#{repository_full_name}/collaborators"
      parsed_collaborators = MultiJson.load(collaborators_request.response.body)
      parsed_collaborators.each do |parsed_collaborator|
        user = User.where(github_id: parsed_collaborator['id']).first_or_create
        user.update_attributes github_login: parsed_collaborator['login'],
                               avatar_url:   parsed_collaborator['avatar_url']
        Collaborator.create user: user, repository: repository
      end
      releases_request = access_token.get "https://api.github.com/repos/#{repository_full_name}/releases"
      parsed_releases = MultiJson.load(releases_request.response.body)
      parsed_releases.each do |parsed_release|
        release_assets_request = access_token.get parsed_release['assets_url']
        parsed_release_assets = MultiJson.load(release_assets_request.response.body)
        parsed_release_assets.each do |parsed_release_asset|
          Rails.logger.info parsed_release_asset['url'] if parsed_release_asset['name'] =~ /\.ipa$/
        end
      end
    end
    redirect_to root_url
  end

end
