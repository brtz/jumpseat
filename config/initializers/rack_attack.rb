# frozen_string_literal: true

class Rack::Attack
  safe_ip = ENV.fetch("JUMPSEAT_RACKATTACK_SAFE_IP", "127.0.0.1")
  reqip_limit = ENV.fetch("JUMPSEAT_RACKATTACK_REQIP_LIMIT", 1000).to_i
  reqip_login_limit = ENV.fetch("JUMPSEAT_RACKATTACK_REQIP_LOGIN_LIMIT", 50).to_i

  ### Configure Cache ###

  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch("REDISCLOUD_URL"))

  ### Safe IP configuration ###
  Rack::Attack.safelist_ip(safe_ip)

  ### Throttle Spammy Clients ###

  throttle("req/ip", limit: reqip_limit, period: 1.minute) do |req|
    req.ip
  end

  ### Prevent Brute-Force Login Attacks ###

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  throttle("logins/ip", limit: reqip_login_limit, period: 1.minute) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end
end
