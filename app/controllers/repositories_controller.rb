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
        release = repository.releases.where(github_id: parsed_release['id']).first_or_create
        release_assets_request = access_token.get parsed_release['assets_url']
        release.update_attributes body:        parsed_release['body'],
                                  name:        parsed_release['name'],
                                  tag_name:    parsed_release['tag_name'],
                                  github_etag: release_assets_request.response['ETag']
        parsed_release_assets = MultiJson.load(release_assets_request.response.body)
        parsed_release_assets.each do |parsed_release_asset|
          if parsed_release_asset['name'] =~ /\.ipa$/
            bundle = release.bundles.where(github_id: parsed_release_asset['id']).first_or_create
            bundle.update_attributes url: parsed_release_asset['url'],
                                     repository: repository
            ipa = Ipa.new("/Users/james/Desktop/#{parsed_release_asset['id']}.ipa")
            bundle.update_attributes minimum_os_version:  ipa.minimum_os_version,
                                     bundle_display_name: ipa.bundle_display_name,
                                     bundle_version:      ipa.bundle_version,
                                     bundle_identifier:   ipa.bundle_identifier,
                                     enterprise:          ipa.enterprise,
                                     ipad_only:           ipa.ipad_only,
                                     armv6:  ipa.armv6,
                                     armv7:  ipa.armv7,
                                     armv7s: ipa.armv7s,
                                     fatal_errors:    ipa.errors,
                                     md5:             [],
                                     capabilities:    ipa.capabilities,
                                     expiration_date: ipa.expiration_date
          end
        end
      end
    end
    redirect_to root_url
  end

end
