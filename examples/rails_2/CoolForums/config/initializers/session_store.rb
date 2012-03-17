# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_CoolForums_session',
  :secret      => '5271bffd006e95e1b0f746cad7b83d68103df38e7ea72df13f905c491d1f06145f7e5a4666610e99b86ee164e6f51c27db87a62f378cd718540cade844205f4e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
