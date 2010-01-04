# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_agilebrazil_session',
  :secret      => '27a9c35910b0eab08d12d9837c5460caae4b83c5898888cf36804082711894f32a7389e97ed16bef01e59c1d0db38783183b7b24dbd3014501a35761e5574a25'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
