class SessionsController < ApplicationController

  def new
  end

  def create
    reset_session

    rdio = Rdio.new([MUSIC_CREDS['rdio']['consumer_key'], MUSIC_CREDS['rdio']['consumer_secret']])
    callback_url = (URI.join request.url, '/rdio_callback').to_s
    url = rdio.begin_authentication(callback_url)

    # save our request token in the session
    session[:rt] = rdio.token[0]
    session[:rts] = rdio.token[1]

    # go to Rdio to authenticate the app
    redirect_to url
  end
  
  def destroy
    reset_session
    redirect_to root_path
  end

  def rdio_callback
    # get the state from cookies and the query string
    request_token = session[:rt]
    request_token_secret = session[:rts]
    verifier = params[:oauth_verifier]
    
    # make sure we have everything we need
    if request_token and request_token_secret and verifier
      # exchange the verifier and request token for an access token
      rdio = Rdio.new([MUSIC_CREDS['rdio']['consumer_key'], MUSIC_CREDS['rdio']['consumer_secret']], 
                      [request_token, request_token_secret])
      rdio.complete_authentication(verifier)
      
      # grab the user
      current_user = rdio.call('currentUser', {"extras" => "collectionUrl, username"})['result']
      existing_user = User.find_by_account_id(current_user['key'])

      if existing_user
        session[:user_id] = existing_user.id
      else
        User.create_from_music_api(:rdio, current_user.merge(params))
      end

      # save the access token in cookies (and discard the request token)
      session[:at] = rdio.token[0]
      session[:ats] = rdio.token[1]
      session[:rt] = nil
      session[:rts] = nil

      redirect_to root_path
    else
      redirect_to login_path
    end
  end 
end