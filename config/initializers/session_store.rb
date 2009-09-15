# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_grape_session',
  :secret      => 'c123235e241c7985a4d3f4c9dbfe1dc4bdfbf33d1a534bf9dfbeabb666566a5d73a7d49bac8b49c3c0e6d377a80a72633e43e4a7145fa4408a3c5d4ea1aef149'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
