class User < ActiveRecord::Base
  
  def self.create_from_music_api(service = :rdio, user_object)
    user_attrs = case service
      when :rdio
        {:username => user_object['username'],
          :first_name => user_object['firstName'],
          :last_name => user_object['lastName'],
          :profile_url => user_object['url'],
          :avatar_url => user_object['icon'],
          :account_id => user_object['key'],
          :account_type => 'rdio',
          :token => user_object['oauth_token'],
          :token_secret => user_object['oauth_verifier']
        }
      end
    create(user_attrs)
  end

end