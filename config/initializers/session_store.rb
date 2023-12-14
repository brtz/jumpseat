# frozen_string_literal: true

Rails.application.config.session_store :redis_session_store,
 key: "jumpseat_session",
 redis: {
   expire_after: 60.minutes,  # cookie expiration
   key_prefix: "jumpseat:session:",
   url: ENV["REDISCLOUD_URL"],
 }
