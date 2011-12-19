require 'setlistfm.rb'

class SetlistManager
  include Typhoeus
  include Fm

  remote_defaults :on_success => lambda {|response| JSON.parse(response.body)},
                  :on_failure => lambda {|response| puts "error code: #{response.code}"},
                  :base_uri   => "http://api.setlist.fm/rest/0.1"
  
  define_remote_method :artist_search, :path => '/search/artists.json'
  define_remote_method :setlist_search, :path => '/search/setlists.json'

  def self.search_artists(artist_name)
    artists_response = artist_search(:params => {:artistName => URI.escape(artist_name)})
    parsed_artists = Setlist::Api::Model::Artists.from_json(artists_response['artists'])

    parsed_artists.nil? ? [] : parsed_artists.list
  end

  def self.get_recent_setlists(artist_mbid, time_range)
    setlists_response = setlist_search(:params => {:artistMbid => URI.escape(artist_mbid)})
    parsed_setlists = Setlist::Api::Model::Setlists.from_json(setlists_response['setlists'])
    if parsed_setlists.nil?
      []
    else
      parsed_setlists.list.select do |sl| 
        time_range >= Date.today - Date.parse(sl.eventDate) && sl.song_list.size > 5 
      end    
    end
  end

  def self.song_frequency_hash(artist_mbid, time_range = SR_CONFIG['setlists']['fresh_time'])
    song_freq = {}
    setlists = get_recent_setlists(artist_mbid, time_range)

    return nil if setlists.empty?
    avg_set_length = setlists.inject(0.0) { |sum, el| sum + el.song_list.size } / setlists.size

    setlists.each do |sl|
      song_list = sl.song_list
      song_list.each do |s|
        song_freq[s] = song_freq.key?(s) ? song_freq[s] + 1 : 1
      end
    end

    sorted_song_freq = song_freq.sort_by { |k, v| -v }
    sorted_song_freq.take(avg_set_length.to_i).map { |pair| pair[0] }
  end
end