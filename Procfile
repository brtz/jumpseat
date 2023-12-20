web: RUBYOPT="--yjit" bin/docker-entrypoint ./bin/rails server -p ${PORT:-5000} -e $RAILS_ENV -b 0.0.0.0
sidekiq: sleep 15 && bundle exec sidekiq
