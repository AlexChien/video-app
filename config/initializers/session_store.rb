# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :session_key => '_ey_videoapp_session',
  :secret      => 'a29be8f90992b46b2bdff04733702249282b25361df793ccf607e60496b44dd6a2130fb400f164340cd5b405c1716c258c707f1d8fe86ca43e97cd1ef63447fe'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

# 将flash提交的cookie信息放在rails之前由rack middleware处理
ActionController::Dispatcher.middleware.insert_before(
  ActionController::Session::CookieStore, 
  FlashSessionCookieMiddleware, 
  ActionController::Base.session_options[:session_key]
)